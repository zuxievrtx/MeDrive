@if ($errors->any())
    <div class="mb-4 rounded-lg border border-mr-300 bg-mr-50 p-3 text-sm text-mr-800" role="alert">
        <p class="font-semibold">Sertifikat belum tersimpan:</p>
        <ul class="list-inside list-disc">@foreach ($errors->all() as $message)<li>{{ $message }}</li>@endforeach</ul>
    </div>
@endif
<div class="grid gap-6 xl:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]"
     x-data="{ edit: { open: false, url: '', cert: {} }, remove: { open: false, url: '', name: '' } }">
    <section class="card overflow-hidden">
        <div class="border-b border-stone-100 px-5 py-3"><h2 class="font-semibold">Sertifikat driver</h2></div>
        @if ($certifications->isEmpty())
            <x-admin.empty-state icon="certificate" title="Belum ada sertifikat" description="Tambahkan sertifikat pelatihan seperti BTCLS atau PPGD lewat form di samping." />
        @else
            <div class="relative overflow-x-auto">
                <table class="data-table">
                    <thead><tr><th>Nama</th><th>Nomor</th><th>Penerbit</th><th>Terbit</th><th>Kedaluwarsa</th><th>Berkas</th><th><span class="sr-only">Aksi</span></th></tr></thead>
                    <tbody>
                        @foreach ($certifications as $certification)
                            <tr>
                                <td class="font-medium">{{ $certification->name }}</td>
                                <td class="tabular">{{ $certification->certificate_number ?? '-' }}</td>
                                <td>{{ $certification->issuer ?? '-' }}</td>
                                <td class="tabular whitespace-nowrap">{{ $certification->issued_at->translatedFormat('j M Y') }}</td>
                                <td class="whitespace-nowrap">
                                    @if ($certification->expires_at)
                                        <span class="tabular">{{ $certification->expires_at->translatedFormat('j M Y') }}</span>
                                        @if ($certification->expires_at->lt(today()))
                                            <x-admin.badge tone="red">Kedaluwarsa</x-admin.badge>
                                        @elseif ($certification->expires_at->lte(today()->addDays(config('medrive.expiry_warning_days'))))
                                            <x-admin.badge tone="amber">Segera habis</x-admin.badge>
                                        @endif
                                    @else
                                        <span class="text-stone-600">Seumur hidup</span>
                                    @endif
                                </td>
                                <td>
                                    @if ($certification->file_path)
                                        <a href="{{ route('admin.certifications.file', $certification) }}" class="font-semibold whitespace-nowrap text-mr-700 hover:underline"><i class="fa-solid fa-download" aria-hidden="true"></i> Unduh</a>
                                    @else
                                        <span class="text-stone-600">-</span>
                                    @endif
                                </td>
                                <td>
                                    <div class="flex justify-end gap-1">
                                        <button type="button" class="btn-ghost min-h-9 px-2.5 text-xs"
                                                @click="edit = { open: true, url: @js(route('admin.certifications.update', $certification)), cert: @js([
                                                    'name' => $certification->name,
                                                    'certificate_number' => $certification->certificate_number,
                                                    'issuer' => $certification->issuer,
                                                    'issued_at' => $certification->issued_at->toDateString(),
                                                    'expires_at' => $certification->expires_at?->toDateString(),
                                                ]) }">Edit</button>
                                        <button type="button" class="btn-ghost min-h-9 px-2.5 text-xs text-mr-700"
                                                @click="remove = { open: true, url: @js(route('admin.certifications.destroy', $certification)), name: @js($certification->name) }">Hapus</button>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </section>

    <section class="card p-5">
        <h2 class="mb-4 font-semibold">Tambah sertifikat</h2>
        <form method="POST" action="{{ route('admin.drivers.certifications.store', $driver) }}" enctype="multipart/form-data" class="space-y-4">
            @csrf
            @include('admin.drivers.partials.certification-fields', ['prefix' => 'new'])
            <button type="submit" class="btn-primary w-full">Simpan sertifikat</button>
        </form>
    </section>

    <x-admin.modal show="edit.open" title="Edit sertifikat">
        <form method="POST" :action="edit.url" enctype="multipart/form-data" class="space-y-4">
            @csrf
            @method('PUT')
            @include('admin.drivers.partials.certification-fields', ['prefix' => 'edit', 'bind' => 'edit.cert'])
            <div class="flex justify-end gap-2">
                <button type="button" class="btn-secondary" @click="edit.open = false">Batal</button>
                <button type="submit" class="btn-primary">Simpan perubahan</button>
            </div>
        </form>
    </x-admin.modal>

    <x-admin.modal show="remove.open" title="Hapus sertifikat">
        <p class="text-sm text-stone-700">Sertifikat <strong x-text="remove.name"></strong> beserta berkasnya akan dihapus permanen.</p>
        <form method="POST" :action="remove.url" class="mt-6 flex justify-end gap-2">
            @csrf
            @method('DELETE')
            <button type="button" class="btn-secondary" @click="remove.open = false">Batal</button>
            <button type="submit" class="btn-danger">Hapus sertifikat</button>
        </form>
    </x-admin.modal>
</div>
