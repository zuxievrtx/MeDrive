@php use App\Support\Label; @endphp
<section class="card p-5" x-data="{ lightbox: false, src: '', caption: '' }" aria-labelledby="attachments-title">
    <h2 id="attachments-title" class="mb-3 font-semibold">Lampiran</h2>
    @if ($report->attachments->isEmpty())
        <p class="text-sm text-stone-600">Tidak ada lampiran.</p>
    @else
        <ul class="grid grid-cols-2 gap-3 sm:grid-cols-3">
            @foreach ($report->attachments as $attachment)
                @php
                    $url = route('admin.reports.attachments.show', [$report, $attachment]);
                    $caption = Label::humanize($attachment->type).' ('.$attachment->size_kb.' KB)';
                @endphp
                <li class="overflow-hidden rounded-lg border border-stone-200">
                    @if ($attachment->isImage())
                        <button type="button" class="block aspect-[4/3] w-full bg-stone-100" x-data="{ failed: false }"
                                @click="if (!failed) { lightbox = true; src = @js($url); caption = @js($caption) }" :aria-label="failed ? 'Berkas tidak tersedia' : 'Perbesar {{ $caption }}'">
                            <img src="{{ $url }}" alt="{{ $caption }}" loading="lazy" class="size-full object-cover" x-show="!failed" x-on:error="failed = true">
                            <span x-show="failed" x-cloak class="grid size-full place-items-center p-2 text-center text-xs text-stone-600"><span><i class="fa-solid fa-image mb-1 block text-lg" aria-hidden="true"></i>Berkas tidak tersedia di penyimpanan</span></span>
                        </button>
                    @else
                        <a href="{{ $url }}" class="grid aspect-[4/3] place-items-center bg-stone-50 text-stone-600 hover:bg-mr-50 hover:text-mr-700">
                            <span class="text-center text-xs"><i class="fa-solid fa-file-pdf mb-1 block text-2xl" aria-hidden="true"></i>Unduh dokumen</span>
                        </a>
                    @endif
                    <div class="px-2 py-1.5 text-xs">
                        <div class="font-medium">{{ Label::humanize($attachment->type) }}</div>
                        <div class="text-stone-600">{{ $attachment->size_kb }} KB · {{ $attachment->created_at?->translatedFormat('j M H:i') }}</div>
                    </div>
                </li>
            @endforeach
        </ul>
    @endif

    <div x-show="lightbox" x-cloak x-transition.opacity class="fixed inset-0 z-[80] flex flex-col items-center justify-center bg-stone-950/90 p-4"
         @keydown.escape.window="lightbox = false" @click.self="lightbox = false" role="dialog" aria-modal="true" aria-label="Pratinjau lampiran">
        <img :src="src" :alt="caption" class="max-h-[80vh] max-w-full rounded-lg object-contain">
        <div class="mt-3 flex items-center gap-3 text-sm text-white">
            <span x-text="caption"></span>
            <a :href="`${src}?download=1`" class="btn-secondary min-h-9">Unduh</a>
            <button type="button" class="btn-secondary min-h-9" @click="lightbox = false">Tutup</button>
        </div>
    </div>
</section>
