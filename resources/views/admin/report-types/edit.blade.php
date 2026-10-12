@php $selected = collect(old('ambulance_type_ids', $reportType->ambulanceTypes->pluck('id')->all()))->map(fn ($id) => (int) $id); @endphp
<x-admin.layout title="Edit jenis laporan" :breadcrumbs="['Master jenis laporan' => route('admin.report-types.index')]">
    <x-admin.page-header :title="'Edit '.$reportType->name" :description="'Kode ('.$reportType->code.'), status darurat, dan wajib tujuan mengikuti aplikasi mobile sehingga tidak diubah di sini.'" />

    <div x-data="ambulanceTypeChecklist(@js($reportType->ambulanceTypes->pluck('id')))">
        <form method="POST" action="{{ route('admin.report-types.update', $reportType) }}" class="grid gap-6 xl:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]" @submit="submit($event)"
              x-data="{ icon: @js(old('icon', $reportType->icon)), color: @js(old('color', $reportType->color ?? '#57534E')), name: @js(old('name', $reportType->name)) }">
            @csrf
            @method('PUT')
            <section class="card space-y-5 p-6">
                <x-admin.field name="name" label="Nama" required>
                    <input id="name" name="name" type="text" maxlength="100" required x-model="name" class="form-input">
                </x-admin.field>
                <x-admin.field name="description" label="Deskripsi">
                    <textarea id="description" name="description" maxlength="255" rows="2" class="form-input py-2">{{ old('description', $reportType->description) }}</textarea>
                </x-admin.field>
                <div class="grid gap-5 sm:grid-cols-2">
                    <x-admin.field name="priority" label="Prioritas" required hint="1 = paling mendesak. Prioritas 1 memicu bunyi notifikasi.">
                        <select id="priority" name="priority" class="form-input">
                            @for ($priority = 1; $priority <= 5; $priority++)
                                <option value="{{ $priority }}" @selected((int) old('priority', $reportType->priority) === $priority)>{{ $priority }}</option>
                            @endfor
                        </select>
                    </x-admin.field>
                    <x-admin.field name="sort_order" label="Urutan tampil" required>
                        <input id="sort_order" name="sort_order" type="number" min="0" max="255" required value="{{ old('sort_order', $reportType->sort_order) }}" class="form-input tabular">
                    </x-admin.field>
                    <x-admin.field name="icon" label="Ikon" hint="Nama ikon Font Awesome (solid), mis. heart-pulse.">
                        <input id="icon" name="icon" type="text" maxlength="50" x-model="icon" class="form-input">
                    </x-admin.field>
                    <x-admin.field name="color" label="Warna">
                        <div class="flex gap-2">
                            <input type="color" x-model="color" class="h-10 w-14 cursor-pointer rounded-lg border border-stone-300 bg-white p-1" aria-label="Pilih warna">
                            <input id="color" name="color" type="text" maxlength="7" x-model="color" class="form-input tabular uppercase">
                        </div>
                    </x-admin.field>
                </div>
                <div>
                    <span class="form-label">Pratinjau badge</span>
                    <span class="inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 text-xs font-semibold" :style="`background:${color};color:${window.readableTextOn(color)}`"> { const v = (hex || '#57534e').replace('#', ''); const c = [0, 2, 4].map((o) => { const x = parseInt(v.substr(o, 2), 16) / 255; return x <= 0.03928 ? x / 12.92 : ((x + 0.055) / 1.055) ** 2.4; }); return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2] > 0.4 ? '#1c1917' : '#ffffff'; } }">
                        <i class="fa-solid" :class="icon ? `fa-${icon}` : ''" aria-hidden="true"></i><span x-text="name"></span>
                    </span>
                </div>
                <div>
                    <input type="hidden" name="is_active" value="0">
                    <label class="inline-flex min-h-10 items-center gap-3 text-sm">
                        <input type="checkbox" name="is_active" value="1" class="size-4 accent-mr-600" @checked(old('is_active', $reportType->is_active))>
                        Jenis laporan aktif (bisa dipilih pelapor)
                    </label>
                </div>
            </section>

            <section class="card p-6">
                <h2 class="font-semibold">Jenis ambulans yang boleh melayani</h2>
                <p class="mb-4 text-sm text-stone-600">Broadcast laporan jenis ini hanya dikirim ke driver yang shift-nya memakai ambulans dengan jenis tercentang.</p>
                <div class="space-y-2">
                    @foreach ($ambulanceTypes as $ambulanceType)
                        <label class="flex min-h-11 cursor-pointer items-start gap-3 rounded-lg border border-stone-200 p-3 has-[:checked]:border-mr-600 has-[:checked]:bg-mr-50">
                            <input type="checkbox" name="ambulance_type_ids[]" value="{{ $ambulanceType->id }}" class="mt-0.5 size-4 accent-mr-600" @checked($selected->contains($ambulanceType->id))>
                            <span>
                                <span class="block text-sm font-semibold">{{ $ambulanceType->name }}</span>
                                <span class="block text-xs text-stone-600">{{ $ambulanceType->description }}</span>
                            </span>
                        </label>
                    @endforeach
                </div>
                @error('ambulance_type_ids')<p class="form-error">{{ $message }}</p>@enderror
            </section>

            <div class="flex justify-end gap-2 xl:col-span-2">
                <a href="{{ route('admin.report-types.index') }}" class="btn-secondary">Batal</a>
                <button type="submit" class="btn-primary">Simpan perubahan</button>
            </div>
        </form>

        <x-admin.modal show="confirmOpen" title="Ubah penerima broadcast?">
            <div class="flex gap-3 rounded-lg border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
                <i class="fa-solid fa-triangle-exclamation mt-0.5" aria-hidden="true"></i>
                <p>Perubahan jenis ambulans <strong>memengaruhi penerima broadcast</strong> untuk laporan baru jenis ini. Driver dengan jenis ambulans yang tidak dicentang tidak akan menerima notifikasi.</p>
            </div>
            <div class="mt-6 flex justify-end gap-2">
                <button type="button" class="btn-secondary" @click="confirmOpen = false">Periksa lagi</button>
                <button type="button" class="btn-primary" @click="confirm()">Ya, simpan perubahan</button>
            </div>
        </x-admin.modal>
    </div>
</x-admin.layout>
