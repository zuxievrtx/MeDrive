{{-- Field bersama form tambah & edit driver. $driver/$profile null saat tambah. --}}
@php
    $isEdit = isset($driver);
@endphp

<section class="card p-6" aria-labelledby="section-account">
    <h2 id="section-account" class="text-base font-bold">1. Data akun</h2>
    <p class="mb-5 text-sm text-stone-600">Dipakai driver untuk masuk ke aplikasi Driver.</p>
    <div class="grid gap-5 md:grid-cols-2">
        <x-admin.field name="name" label="Nama lengkap" required>
            <input id="name" name="name" type="text" maxlength="100" required value="{{ old('name', $driver->name ?? '') }}" class="form-input">
        </x-admin.field>
        <x-admin.field name="phone" label="Nomor telepon" required>
            <input id="phone" name="phone" type="tel" maxlength="20" required value="{{ old('phone', $driver->phone ?? '') }}" placeholder="08xxxxxxxxxx" class="form-input">
        </x-admin.field>
        <x-admin.field name="email" label="Email" required hint="Harus unik, dipakai sebagai username login.">
            <input id="email" name="email" type="email" maxlength="100" required value="{{ old('email', $driver->email ?? '') }}" autocomplete="off" class="form-input">
        </x-admin.field>

        @php $passwordName = $isEdit ? 'new_password' : 'password'; @endphp
        <x-admin.field :name="$passwordName" :label="$isEdit ? 'Reset password (opsional)' : 'Password sementara'" :required="! $isEdit"
                       :hint="$isEdit ? 'Kosongkan bila tidak direset. Password baru membuat driver wajib ganti password saat login.' : 'Minimal 8 karakter. Password ini ditampilkan sekali setelah disimpan.'">
            <div x-data="passwordField(@js(old($passwordName, '')))" class="flex gap-2">
                <div class="relative flex-1">
                    <input id="{{ $passwordName }}" name="{{ $passwordName }}" x-model="password" :type="visible ? 'text' : 'password'" minlength="8"
                           @if (! $isEdit) required @endif autocomplete="new-password" class="form-input pr-11">
                    <button type="button" @click="visible = !visible" class="absolute inset-y-0 right-0 grid w-11 place-items-center text-stone-600 hover:text-stone-900"
                            :aria-label="visible ? 'Sembunyikan password' : 'Tampilkan password'">
                        <i class="fa-solid" :class="visible ? 'fa-eye-slash' : 'fa-eye'"></i>
                    </button>
                </div>
                <button type="button" @click="generate()" class="btn-secondary whitespace-nowrap"><i class="fa-solid fa-dice" aria-hidden="true"></i> Buat acak</button>
            </div>
        </x-admin.field>

        @unless ($isEdit)
            <div class="md:col-span-2">
                <input type="hidden" name="must_change_password" value="0">
                <label class="inline-flex min-h-10 items-center gap-3 text-sm">
                    <input type="checkbox" name="must_change_password" value="1" class="size-4 rounded border-stone-400 accent-mr-600" @checked(old('must_change_password', true))>
                    Wajib ganti password saat login pertama
                </label>
            </div>
        @endunless
    </div>
</section>

<section class="card p-6" aria-labelledby="section-employment">
    <h2 id="section-employment" class="text-base font-bold">2. Data kepegawaian</h2>
    <p class="mb-5 text-sm text-stone-600">Klinik menentukan ambulans yang bisa dipilih driver saat membuka shift.</p>
    <div class="grid gap-5 md:grid-cols-2">
        <x-admin.field name="clinic_id" label="Klinik - Instansi" required>
            <select id="clinic_id" name="clinic_id" required class="form-input">
                <option value="">Pilih klinik</option>
                @foreach ($clinics as $clinic)
                    <option value="{{ $clinic->id }}" @selected(old('clinic_id', $profile->clinic_id ?? null) == $clinic->id)>
                        {{ $clinic->labelWithInstitution() }}{{ $clinic->is_active ? '' : ' (nonaktif)' }}
                    </option>
                @endforeach
            </select>
        </x-admin.field>
        <x-admin.field name="employee_number" label="Nomor pegawai" hint="Opsional. Tidak boleh sama dengan driver lain di klinik yang sama.">
            <input id="employee_number" name="employee_number" type="text" maxlength="30" value="{{ old('employee_number', $profile->employee_number ?? '') }}" class="form-input">
        </x-admin.field>
    </div>
</section>

<section class="card p-6" aria-labelledby="section-license">
    <h2 id="section-license" class="text-base font-bold">3. Data SIM dan foto</h2>
    <p class="mb-5 text-sm text-stone-600">Foto driver ditampilkan ke pelapor saat laporan diambil.</p>
    <div class="grid gap-5 md:grid-cols-3">
        <x-admin.field name="license_number" label="Nomor SIM" required>
            <input id="license_number" name="license_number" type="text" maxlength="30" required value="{{ old('license_number', $profile->license_number ?? '') }}" class="form-input">
        </x-admin.field>
        <x-admin.field name="license_class" label="Golongan SIM" required>
            <select id="license_class" name="license_class" required class="form-input">
                <option value="">Pilih golongan</option>
                @foreach ($licenseClasses as $class)
                    <option value="{{ $class->value }}" @selected(old('license_class', isset($profile) ? $profile->license_class->value : null) === $class->value)>{{ $class->label() }}</option>
                @endforeach
            </select>
        </x-admin.field>
        <x-admin.field name="license_expires_at" label="Berlaku sampai" required :hint="$isEdit ? null : 'Minimal besok.'">
            <input id="license_expires_at" name="license_expires_at" type="date" required
                   @unless ($isEdit) min="{{ today()->addDay()->toDateString() }}" @endunless
                   value="{{ old('license_expires_at', isset($profile) ? $profile->license_expires_at->toDateString() : '') }}" class="form-input">
        </x-admin.field>
    </div>

    <div class="mt-5" x-data="photoPreview(@js(isset($profile) && $profile->photo_path ? route('admin.drivers.photo', $driver) : null))">
        <x-admin.field name="photo" label="Foto driver" hint="JPG atau PNG, maksimal 2 MB.">
            <div class="flex items-center gap-4">
                <div class="grid size-20 shrink-0 place-items-center overflow-hidden rounded-full bg-stone-100 ring-1 ring-stone-200">
                    <img x-show="previewUrl" :src="previewUrl" alt="Pratinjau foto driver" class="size-full object-cover">
                    <i x-show="!previewUrl" class="fa-solid fa-user text-2xl text-stone-400" aria-hidden="true"></i>
                </div>
                <input id="photo" name="photo" type="file" accept="image/jpeg,image/png" @change="pick($event)"
                       class="block min-w-0 flex-1 text-sm text-stone-700 file:mr-3 file:min-h-10 file:rounded-lg file:border-0 file:bg-stone-100 file:px-4 file:text-sm file:font-semibold hover:file:bg-stone-200">
            </div>
            <p x-show="tooLarge" x-cloak class="form-error">Ukuran foto melebihi 2 MB.</p>
        </x-admin.field>
    </div>
</section>
