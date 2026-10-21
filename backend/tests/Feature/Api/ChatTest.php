<?php

use App\Events\ChatMessageRead;
use App\Events\ChatMessageSent;
use App\Jobs\SendFcmNotification;
use App\Models\ChatMessage;
use App\Models\Report;
use App\Models\User;
use App\Services\FcmService;
use Illuminate\Database\QueryException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;

/*
 * Data contoh: laporan #3 sedang "dalam perjalanan" milik Budi (#1) ditangani Rina (#4);
 * laporan #1 milik Budi sudah selesai (driver Andi #3). Sari (#2) pelapor lain.
 */
beforeEach(function () {
    $this->admin = seedDemoAndGetAdmin();
    Storage::fake('local');
    Queue::fake([SendFcmNotification::class]);
    $this->budi = User::query()->findOrFail(1);
    $this->sari = User::query()->findOrFail(2);
    $this->andi = User::query()->findOrFail(3);
    $this->rina = User::query()->findOrFail(4);
});

function chatUrl(User $user, int $reportId, string $suffix = ''): string
{
    return '/api/v1/'.($user->isDriver() ? 'driver' : 'reporter')."/reports/{$reportId}/chat{$suffix}";
}

it('stores a text message, broadcasts it on the chat channel and pushes it to the other participant', function () {
    Event::fake([ChatMessageSent::class]);
    actingAsMobile($this->budi);

    $this->postJson(chatUrl($this->budi, 3), ['type' => 'text', 'body' => '  Pasien di lantai 2, pintu samping.  '])
        ->assertCreated()
        ->assertJsonPath('data.type', 'text')
        ->assertJsonPath('data.body', 'Pasien di lantai 2, pintu samping.')
        ->assertJsonPath('data.sender_name', $this->budi->name)
        ->assertJsonPath('data.is_mine', true)
        ->assertJsonPath('data.image_url', null);

    $message = ChatMessage::query()->sole();
    expect($message->report_id)->toBe(3)->and($message->sender_id)->toBe(1)->and($message->read_at)->toBeNull();

    Event::assertDispatched(ChatMessageSent::class, function (ChatMessageSent $event) use ($message): bool {
        return $event->message->is($message)
            && collect($event->broadcastOn())->map->name->all() === ['private-chat.3']
            && $event->broadcastWith()['body'] === 'Pasien di lantai 2, pintu samping.';
    });

    Queue::assertPushed(SendFcmNotification::class, fn (SendFcmNotification $job): bool => $job->userId === 4
        && $job->title === $this->budi->name
        && $job->body === 'Pasien di lantai 2, pintu samping.'
        && $job->data['type'] === 'chat'
        && $job->data['report_id'] === 3);
});

it('stores an image in the private chat folder and streams it only to the two participants', function () {
    actingAsMobile($this->rina);

    $response = $this->post(chatUrl($this->rina, 3), ['type' => 'image', 'image' => UploadedFile::fake()->image('lokasi.jpg', 800, 600)->size(300)], ['Accept' => 'application/json'])
        ->assertCreated()
        ->assertJsonPath('data.type', 'image')
        ->assertJsonPath('data.body', null);

    $message = ChatMessage::query()->sole();
    expect($message->file_path)->toStartWith('chat/3/')
        ->and($message->mime_type)->toBe('image/jpeg');
    Storage::disk('local')->assertExists($message->file_path);
    Queue::assertPushed(SendFcmNotification::class, fn (SendFcmNotification $job): bool => $job->userId === 1 && $job->body === 'Mengirim foto');

    $mediaUrl = parse_url($response->json('data.image_url'), PHP_URL_PATH);
    expect($mediaUrl)->toBe("/api/v1/media/chat/{$message->id}");

    $this->get($mediaUrl)->assertOk();
    actingAsMobile($this->budi);
    $this->get($mediaUrl)->assertOk();

    foreach ([$this->sari, $this->andi] as $outsider) {
        actingAsMobile($outsider);
        $this->getJson($mediaUrl)->assertForbidden()->assertJsonPath('error.code', 'chat_forbidden');
    }

    $this->actingAs($this->admin);
    $this->getJson($mediaUrl)->assertForbidden();
});

it('rejects images over 1 MB and other file types', function (UploadedFile $file) {
    actingAsMobile($this->budi);

    $this->post(chatUrl($this->budi, 3), ['type' => 'image', 'image' => $file], ['Accept' => 'application/json'])
        ->assertStatus(400)
        ->assertJsonPath('error.code', 'validation_failed');

    expect(ChatMessage::query()->count())->toBe(0);
})->with([
    'too large' => fn () => UploadedFile::fake()->image('besar.jpg')->size(1500),
    'pdf' => fn () => UploadedFile::fake()->create('surat.pdf', 100, 'application/pdf'),
]);

it('keeps other reporters and drivers out of the chat', function (string $who) {
    $outsider = $this->{$who};
    actingAsMobile($outsider);

    $this->getJson(chatUrl($outsider, 3))->assertForbidden()->assertJsonPath('error.code', 'chat_forbidden');
    $this->postJson(chatUrl($outsider, 3), ['type' => 'text', 'body' => 'Halo'])->assertForbidden();
    $this->postJson(chatUrl($outsider, 3, '/read'))->assertForbidden();

    expect(ChatMessage::query()->count())->toBe(0);
})->with(['other reporter' => 'sari', 'other driver' => 'andi']);

it('gives admins no access to any chat endpoint, channel or image', function () {
    $message = ChatMessage::query()->create(['report_id' => 3, 'sender_id' => 1, 'type' => 'text', 'body' => 'Rahasia pelapor']);
    $endpoints = [
        ['GET', '/api/v1/reporter/reports/3/chat'],
        ['POST', '/api/v1/reporter/reports/3/chat'],
        ['POST', '/api/v1/reporter/reports/3/chat/read'],
        ['GET', '/api/v1/reporter/chat/unread-count'],
        ['GET', '/api/v1/driver/reports/3/chat'],
        ['POST', '/api/v1/driver/reports/3/chat'],
        ['POST', '/api/v1/driver/reports/3/chat/read'],
        ['GET', '/api/v1/driver/chat/unread-count'],
        ['GET', "/api/v1/media/chat/{$message->id}"],
    ];

    // Sesi dashboard (cookie) dan token dengan semua ability sama-sama ditolak.
    foreach ([fn () => $this->actingAs($this->admin), fn () => Sanctum::actingAs($this->admin, ['*'])] as $login) {
        $login();

        foreach ($endpoints as [$method, $uri]) {
            $this->json($method, $uri, ['type' => 'text', 'body' => 'Halo'])->assertForbidden();
        }
    }

    $authorize = Broadcast::getChannels()->get('chat.{report}');
    $report = Report::query()->findOrFail(3);
    expect($authorize($this->admin, $report))->toBeFalse()
        ->and($authorize($this->budi, $report))->toBeTrue()
        ->and($authorize($this->rina, $report))->toBeTrue()
        ->and($authorize($this->sari, $report))->toBeFalse()
        ->and($authorize($this->andi, $report))->toBeFalse()
        ->and(ChatMessage::query()->count())->toBe(1);

    // Detail laporan admin tidak memuat isi chat.
    $this->actingAs($this->admin)->getJson('/api/v1/admin/reports/3')->assertOk()->assertDontSee('Rahasia pelapor');
});

it('closes the chat once the report is finished but keeps the history readable', function () {
    ChatMessage::query()->create(['report_id' => 1, 'sender_id' => 3, 'type' => 'text', 'body' => 'Sudah sampai RS.']);
    actingAsMobile($this->budi);

    $this->postJson(chatUrl($this->budi, 1), ['type' => 'text', 'body' => 'Terima kasih'])
        ->assertStatus(409)
        ->assertJsonPath('error.code', 'chat_closed')
        ->assertJsonPath('error.message', 'Chat ditutup karena laporan sudah selesai.');

    $this->getJson(chatUrl($this->budi, 1))
        ->assertOk()
        ->assertJsonCount(1, 'data')
        ->assertJsonPath('meta.is_open', false);

    expect(ChatMessage::query()->count())->toBe(1);
});

it('pages the history oldest first with before_id', function () {
    foreach (range(1, 35) as $number) {
        ChatMessage::query()->create(['report_id' => 3, 'sender_id' => $number % 2 ? 1 : 4, 'type' => 'text', 'body' => "Pesan {$number}"]);
    }
    actingAsMobile($this->rina);

    $first = $this->getJson(chatUrl($this->rina, 3))->assertOk()->assertJsonCount(30, 'data');
    expect($first->json('data.0.body'))->toBe('Pesan 6')
        ->and($first->json('data.29.body'))->toBe('Pesan 35')
        ->and($first->json('meta.cursor.has_more'))->toBeTrue()
        ->and($first->json('meta.cursor.next_before_id'))->toBe($first->json('data.0.id'));

    $older = $this->getJson(chatUrl($this->rina, 3).'?before_id='.$first->json('meta.cursor.next_before_id'))->assertOk()->assertJsonCount(5, 'data');
    expect($older->json('data.0.body'))->toBe('Pesan 1')
        ->and($older->json('data.4.body'))->toBe('Pesan 5')
        ->and($older->json('meta.cursor.has_more'))->toBeFalse();
});

it('counts unread messages per report and marks them read', function () {
    Event::fake([ChatMessageRead::class]);
    $fromRina = collect([1, 2])->map(fn (int $n) => ChatMessage::query()->create(['report_id' => 3, 'sender_id' => 4, 'type' => 'text', 'body' => "Driver {$n}"]));
    ChatMessage::query()->create(['report_id' => 3, 'sender_id' => 1, 'type' => 'text', 'body' => 'Pelapor 1']);
    ChatMessage::query()->create(['report_id' => 1, 'sender_id' => 3, 'type' => 'text', 'body' => 'Laporan lama']);

    actingAsMobile($this->budi);
    $this->getJson('/api/v1/reporter/chat/unread-count')
        ->assertOk()
        ->assertJsonPath('data.total', 3)
        ->assertJsonPath('data.reports.0.report_id', 3)
        ->assertJsonPath('data.reports.0.code', 'MDR-261009-0001')
        ->assertJsonPath('data.reports.0.count', 2)
        ->assertJsonPath('data.reports.1.report_id', 1)
        ->assertJsonPath('data.reports.1.count', 1);

    actingAsMobile($this->rina);
    $this->getJson('/api/v1/driver/chat/unread-count')->assertJsonPath('data.total', 1);

    actingAsMobile($this->budi);
    $this->postJson(chatUrl($this->budi, 3, '/read'))->assertOk()->assertJsonPath('data.marked', 2);
    $this->postJson(chatUrl($this->budi, 3, '/read'))->assertOk()->assertJsonPath('data.marked', 0);

    $this->getJson('/api/v1/reporter/chat/unread-count')->assertJsonPath('data.total', 1);
    expect($fromRina->every(fn (ChatMessage $message): bool => $message->fresh()->read_at !== null))->toBeTrue()
        ->and(ChatMessage::query()->where('sender_id', 1)->value('read_at'))->toBeNull();

    Event::assertDispatchedTimes(ChatMessageRead::class, 1);
    Event::assertDispatched(ChatMessageRead::class, fn (ChatMessageRead $event): bool => $event->readerId === 1
        && $event->lastReadId === $fromRina->last()->id
        && collect($event->broadcastOn())->map->name->all() === ['private-chat.3']);
});

it('enforces the type/body/file CHECK constraint in the database', function () {
    expect(fn () => ChatMessage::query()->create(['report_id' => 3, 'sender_id' => 1, 'type' => 'text', 'body' => null]))
        ->toThrow(QueryException::class)
        ->and(fn () => ChatMessage::query()->create(['report_id' => 3, 'sender_id' => 1, 'type' => 'image', 'body' => 'tanpa berkas']))
        ->toThrow(QueryException::class);
});

it('rate limits chat messages to 30 per minute per token', function () {
    actingAsMobile($this->budi);

    foreach (range(1, 30) as $number) {
        $this->postJson(chatUrl($this->budi, 3), ['type' => 'text', 'body' => "Pesan {$number}"])->assertCreated();
    }

    $this->postJson(chatUrl($this->budi, 3), ['type' => 'text', 'body' => 'Kelebihan'])->assertStatus(429);
    expect(ChatMessage::query()->count())->toBe(30);
});

it('keeps chat text out of the log-only FCM output', function () {
    Log::spy();
    config(['medrive.fcm.project_id' => null]);

    app(FcmService::class)->sendToToken('token-uji-123456', 'Budi', 'Alamat rumah saya Jl. Mawar 5', ['type' => 'chat', 'report_id' => 3]);

    Log::shouldHaveReceived('info')->withArgs(fn (string $message, array $context): bool => $context['body'] === '[isi chat disembunyikan]'
        && ! str_contains(json_encode($context), 'Mawar'))->once();
});
