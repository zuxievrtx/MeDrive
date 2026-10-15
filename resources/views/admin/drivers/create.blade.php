<x-admin.layout title="Daftarkan driver" :breadcrumbs="['Driver' => route('admin.drivers.index')]">
    <x-admin.page-header title="Daftarkan driver" description="Akun driver, profil kepegawaian, foto, dan sertifikat disimpan sekaligus dalam satu transaksi." />

    <div x-data="adminOptions('clinics,license_classes')">
        <form x-ref="form" x-data="apiForm({ url: @js(route('api.v1.admin.drivers.store')), redirect: '/admin/drivers/:id', idPath: 'driver.id', rememberCredentials: true, successMessage: 'Driver berhasil didaftarkan.' })"
              @submit.prevent="submit($event)" enctype="multipart/form-data" class="space-y-6" novalidate>
            <div x-show="errorCount > 0" x-cloak class="flex gap-3 rounded-lg border border-mr-300 bg-mr-50 p-3 text-sm text-mr-800" role="alert">
                <i class="fa-solid fa-circle-exclamation mt-0.5" aria-hidden="true"></i>
                <p x-text="`Periksa kembali isian yang ditandai. ${errorCount} isian belum valid.`"></p>
            </div>

            @include('admin.drivers.partials.form-fields', ['isEdit' => false])

            <section class="card p-6" aria-labelledby="section-certifications" x-data="{ rows: [] }">
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
                        @foreach ([
                            ['name', 'Nama sertifikat', 'text', true, 'maxlength="100"'],
                            ['certificate_number', 'Nomor', 'text', false, 'maxlength="50"'],
                            ['issuer', 'Penerbit', 'text', false, 'maxlength="150"'],
                            ['issued_at', 'Tanggal terbit', 'date', true, 'max="'.today()->toDateString().'"'],
                            ['expires_at', 'Kedaluwarsa', 'date', false, ''],
                        ] as [$field, $label, $type, $required, $extra])
                            <div>
                                <label class="form-label" :for="`cert-{{ $field }}-${row.uid}`">{{ $label }} @if ($required)<span class="text-mr-700">*</span>@endif</label>
                                <input :id="`cert-{{ $field }}-${row.uid}`" :name="`certifications[${index}][{{ $field }}]`" type="{{ $type }}" {!! $extra !!} @if ($required) required @endif class="form-input">
                                <p class="form-error" x-show="error(`certifications.${index}.{{ $field }}`)" x-text="error(`certifications.${index}.{{ $field }}`)"></p>
                            </div>
                        @endforeach
                        <div>
                            <label class="form-label" :for="`cert-file-${row.uid}`">Berkas (PDF/JPG/PNG, maks 5 MB)</label>
                            <input :id="`cert-file-${row.uid}`" :name="`certifications[${index}][file]`" type="file" accept=".pdf,image/jpeg,image/png" class="block w-full text-sm">
                            <p class="form-error" x-show="error(`certifications.${index}.file`)" x-text="error(`certifications.${index}.file`)"></p>
                        </div>
                        <div class="md:col-span-3">
                            <button type="button" class="btn-ghost px-2 text-sm text-mr-700" @click="rows.splice(index, 1)"><i class="fa-solid fa-trash" aria-hidden="true"></i> Hapus baris ini</button>
                        </div>
                    </fieldset>
                </template>
            </section>

            <div class="flex flex-wrap justify-end gap-2">
                <a href="{{ route('admin.drivers.index') }}" class="btn-secondary">Batal</a>
                <button type="submit" class="btn-primary" :disabled="submitting">
                    <i class="fa-solid" :class="submitting ? 'fa-spinner fa-spin' : 'fa-floppy-disk'" aria-hidden="true"></i>
                    <span x-text="submitting ? 'Menyimpan...' : 'Simpan dan daftarkan'"></span>
                </button>
            </div>
        </form>
    </div>
</x-admin.layout>
