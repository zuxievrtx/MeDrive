<x-admin.layout title="Edit jenis laporan" :breadcrumbs="['Master jenis laporan' => route('admin.report-types.index')]">
    <div x-data="adminOptions('ambulance_types')">
        <div x-data="apiForm({ url: @js(route('api.v1.admin.report-types.update', $reportTypeId)), method: 'PUT', loadUrl: @js(route('api.v1.admin.report-types.show', $reportTypeId)), mapper: 'reportType', redirect: @js(route('admin.report-types.index')), successMessage: 'Jenis laporan diperbarui.' })">
            <div x-data="ambulanceTypeChecklist()">
                <x-admin.page-header title="Edit jenis laporan">
                    <x-slot:actions><span class="text-sm text-stone-700" x-show="form.code" x-text="`Kode ${form.code}: status darurat dan wajib tujuan mengikuti aplikasi mobile sehingga tidak diubah di sini.`"></span></x-slot:actions>
                </x-admin.page-header>

                <template x-if="loading"><div class="card"><x-admin.skeleton-rows :rows="6" /></div></template>

                <form id="report-type-form" @submit.prevent="confirmOrSubmit($event)" novalidate x-show="!loading" class="grid gap-6 xl:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]">
                    <section class="card space-y-5 p-6">
                        <x-admin.field name="name" label="Nama" required>
                            <input id="name" name="name" type="text" maxlength="100" required x-model="form.name" class="form-input">
                        </x-admin.field>
                        <x-admin.field name="description" label="Deskripsi">
                            <textarea id="description" name="description" maxlength="255" rows="2" x-model="form.description" class="form-input py-2"></textarea>
                        </x-admin.field>
                        <div class="grid gap-5 sm:grid-cols-2">
                            <x-admin.field name="priority" label="Prioritas" required hint="1 = paling mendesak. Prioritas 1 memicu bunyi notifikasi.">
                                <select id="priority" name="priority" x-model="form.priority" class="form-input">
                                    @for ($priority = 1; $priority <= 5; $priority++)
                                        <option value="{{ $priority }}" :selected="Number(form.priority) === {{ $priority }}">{{ $priority }}</option>
                                    @endfor
                                </select>
                            </x-admin.field>
                            <x-admin.field name="sort_order" label="Urutan tampil" required>
                                <input id="sort_order" name="sort_order" type="number" min="0" max="255" required x-model="form.sort_order" class="form-input tabular">
                            </x-admin.field>
                            <x-admin.field name="icon" label="Ikon" hint="Nama ikon Font Awesome (solid), mis. heart-pulse.">
                                <input id="icon" name="icon" type="text" maxlength="50" x-model="form.icon" class="form-input">
                            </x-admin.field>
                            <x-admin.field name="color" label="Warna">
                                <div class="flex gap-2">
                                    <input type="color" x-model="form.color" class="h-10 w-14 cursor-pointer rounded-lg border border-stone-300 bg-white p-1" aria-label="Pilih warna">
                                    <input id="color" name="color" type="text" maxlength="7" x-model="form.color" class="form-input tabular uppercase">
                                </div>
                            </x-admin.field>
                        </div>
                        <div>
                            <span class="form-label">Pratinjau badge</span>
                            <span class="inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 text-xs font-semibold" :style="`background:${form.color};color:${window.readableTextOn(form.color)}`">
                                <i class="fa-solid" :class="form.icon ? `fa-${form.icon}` : ''" aria-hidden="true"></i><span x-text="form.name"></span>
                            </span>
                        </div>
                        <div>
                            <input type="hidden" name="is_active" value="0">
                            <label class="inline-flex min-h-10 items-center gap-3 text-sm">
                                <input type="checkbox" name="is_active" value="1" class="size-4 accent-mr-600" x-model="form.is_active">
                                Jenis laporan aktif (bisa dipilih pelapor)
                            </label>
                        </div>
                    </section>

                    <section class="card p-6">
                        <h2 class="font-semibold">Jenis ambulans yang boleh melayani</h2>
                        <p class="mb-4 text-sm text-stone-600">Broadcast laporan jenis ini hanya dikirim ke driver yang shift-nya memakai ambulans dengan jenis tercentang.</p>
                        <div class="space-y-2">
                            <template x-for="type in options.ambulance_types ?? []" :key="type.id">
                                <label class="flex min-h-11 cursor-pointer items-start gap-3 rounded-lg border border-stone-200 p-3 has-[:checked]:border-mr-600 has-[:checked]:bg-mr-50">
                                    <input type="checkbox" name="ambulance_type_ids[]" :value="String(type.id)" x-model="form.ambulance_type_ids" class="mt-0.5 size-4 accent-mr-600">
                                    <span>
                                        <span class="block text-sm font-semibold" x-text="type.name"></span>
                                        <span class="block text-xs text-stone-600" x-text="type.description"></span>
                                    </span>
                                </label>
                            </template>
                        </div>
                        <p class="form-error" x-show="error('ambulance_type_ids')" x-text="error('ambulance_type_ids')"></p>
                    </section>

                    <div class="flex justify-end gap-2 xl:col-span-2">
                        <a href="{{ route('admin.report-types.index') }}" class="btn-secondary">Batal</a>
                        <button type="submit" class="btn-primary" :disabled="submitting">Simpan perubahan</button>
                    </div>
                </form>

                <x-admin.modal show="confirmOpen" title="Ubah penerima broadcast?">
                    <div class="flex gap-3 rounded-lg border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
                        <i class="fa-solid fa-triangle-exclamation mt-0.5" aria-hidden="true"></i>
                        <p>Perubahan jenis ambulans <strong>memengaruhi penerima broadcast</strong> untuk laporan baru jenis ini. Driver dengan jenis ambulans yang tidak dicentang tidak akan menerima notifikasi.</p>
                    </div>
                    <div class="mt-6 flex justify-end gap-2">
                        <button type="button" class="btn-secondary" @click="confirmOpen = false">Periksa lagi</button>
                        <button type="button" class="btn-primary" @click="confirmOrSubmit({ target: document.getElementById('report-type-form') })">Ya, simpan perubahan</button>
                    </div>
                </x-admin.modal>
            </div>
        </div>
    </div>
</x-admin.layout>
