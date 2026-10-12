<x-admin.layout title="Daftarkan driver" :breadcrumbs="['Driver' => route('admin.drivers.index')]">
    <x-admin.page-header title="Daftarkan driver" description="Akun driver, profil kepegawaian, foto, dan sertifikat disimpan sekaligus dalam satu transaksi." />

    @if ($errors->any())
        <div class="mb-4 flex gap-3 rounded-lg border border-mr-300 bg-mr-50 p-3 text-sm text-mr-800" role="alert">
            <i class="fa-solid fa-circle-exclamation mt-0.5" aria-hidden="true"></i>
            <p>Periksa kembali isian yang ditandai. {{ $errors->count() }} isian belum valid.</p>
        </div>
    @endif

    <form method="POST" action="{{ route('admin.drivers.store') }}" enctype="multipart/form-data" class="space-y-6">
        @csrf
        @include('admin.drivers.partials.form-fields')

        <section class="card p-6" aria-labelledby="section-certifications"
                 x-data="{ rows: @js(collect(old('certifications', []))->map(fn ($row, $index) => ['uid' => 'old-'.$index, ...\Illuminate\Support\Arr::except((array) $row, 'file')])->values()) }">
            <div class="mb-5 flex flex-wrap items-start justify-between gap-3">
                <div>
                    <h2 id="section-certifications" class="text-base font-bold">4. Sertifikat (opsional)</h2>
                    <p class="text-sm text-stone-600">Misalnya BTCLS, PPGD, atau BHD. Bisa juga ditambahkan nanti dari halaman detail driver.</p>
                </div>
                <button type="button" class="btn-secondary" @click="rows.push({ uid: Date.now() })"><i class="fa-solid fa-plus" aria-hidden="true"></i> Tambah sertifikat</button>
            </div>
            <p x-show="rows.length === 0" class="text-sm text-stone-600">Belum ada sertifikat yang ditambahkan.</p>
            <template x-for="(row, index) in rows" :key="row.uid">
                <fieldset class="mb-4 grid gap-4 rounded-lg border border-stone-200 p-4 md:grid-cols-3">
                    <legend class="px-1 text-sm font-semibold" x-text="`Sertifikat ${index + 1}`"></legend>
                    <div>
                        <label class="form-label" :for="`cert-name-${row.uid}`">Nama sertifikat <span class="text-mr-700">*</span></label>
                        <input :id="`cert-name-${row.uid}`" :name="`certifications[${index}][name]`" :value="row.name ?? ''" type="text" maxlength="100" required class="form-input">
                    </div>
                    <div>
                        <label class="form-label" :for="`cert-number-${row.uid}`">Nomor</label>
                        <input :id="`cert-number-${row.uid}`" :name="`certifications[${index}][certificate_number]`" :value="row.certificate_number ?? ''" type="text" maxlength="50" class="form-input">
                    </div>
                    <div>
                        <label class="form-label" :for="`cert-issuer-${row.uid}`">Penerbit</label>
                        <input :id="`cert-issuer-${row.uid}`" :name="`certifications[${index}][issuer]`" :value="row.issuer ?? ''" type="text" maxlength="150" class="form-input">
                    </div>
                    <div>
                        <label class="form-label" :for="`cert-issued-${row.uid}`">Tanggal terbit <span class="text-mr-700">*</span></label>
                        <input :id="`cert-issued-${row.uid}`" :name="`certifications[${index}][issued_at]`" :value="row.issued_at ?? ''" type="date" max="{{ today()->toDateString() }}" required class="form-input">
                    </div>
                    <div>
                        <label class="form-label" :for="`cert-expires-${row.uid}`">Kedaluwarsa</label>
                        <input :id="`cert-expires-${row.uid}`" :name="`certifications[${index}][expires_at]`" :value="row.expires_at ?? ''" type="date" class="form-input">
                    </div>
                    <div>
                        <label class="form-label" :for="`cert-file-${row.uid}`">Berkas (PDF/JPG/PNG, maks 5 MB)</label>
                        <input :id="`cert-file-${row.uid}`" :name="`certifications[${index}][file]`" type="file" accept=".pdf,image/jpeg,image/png" class="block w-full text-sm">
                    </div>
                    <div class="md:col-span-3">
                        <button type="button" class="btn-ghost px-2 text-sm text-mr-700" @click="rows.splice(index, 1)"><i class="fa-solid fa-trash" aria-hidden="true"></i> Hapus baris ini</button>
                    </div>
                </fieldset>
            </template>
            @if ($errors->has('certifications.*'))
                <ul class="form-error list-inside list-disc">
                    @foreach ($errors->get('certifications.*') as $messages)
                        @foreach ($messages as $message)<li>{{ $message }}</li>@endforeach
                    @endforeach
                </ul>
            @endif
        </section>

        <div class="flex flex-wrap justify-end gap-2">
            <a href="{{ route('admin.drivers.index') }}" class="btn-secondary">Batal</a>
            <button type="submit" class="btn-primary"><i class="fa-solid fa-floppy-disk" aria-hidden="true"></i> Simpan dan daftarkan</button>
        </div>
    </form>
</x-admin.layout>
