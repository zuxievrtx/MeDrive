<section class="card overflow-hidden">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-stone-100 px-5 py-3">
        <h2 class="font-semibold">Sertifikat driver</h2>
        <button type="button" class="btn-primary" @click="openCertForm()"><i class="fa-solid fa-plus" aria-hidden="true"></i> Tambah sertifikat</button>
    </div>
    <template x-if="(driver.certifications ?? []).length === 0">
        <x-admin.empty-state icon="certificate" title="Belum ada sertifikat" description="Tambahkan sertifikat pelatihan seperti BTCLS atau PPGD." />
    </template>
    <div class="relative overflow-x-auto" x-show="(driver.certifications ?? []).length > 0">
        <table class="data-table">
            <thead><tr><th>Nama</th><th>Nomor</th><th>Penerbit</th><th>Terbit</th><th>Kedaluwarsa</th><th>Berkas</th><th><span class="sr-only">Aksi</span></th></tr></thead>
            <tbody>
                <template x-for="item in driver.certifications ?? []" :key="item.id">
                    <tr>
                        <td class="font-medium" x-text="item.name"></td>
                        <td class="tabular" x-text="item.certificate_number ?? '-'"></td>
                        <td x-text="item.issuer ?? '-'"></td>
                        <td class="tabular whitespace-nowrap" x-text="window.formatDay(item.issued_at)"></td>
                        <td class="whitespace-nowrap">
                            <span x-show="item.expires_at" class="tabular" x-text="window.formatDay(item.expires_at)"></span>
                            <span x-show="item.expiry_state === 'expired'" class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone('red')">Kedaluwarsa</span>
                            <span x-show="item.expiry_state === 'expiring'" class="inline-flex rounded-md px-2 py-0.5 text-xs font-semibold ring-1 ring-inset" :class="window.badgeTone('amber')">Segera habis</span>
                            <span x-show="item.expiry_state === 'lifetime'" class="text-stone-600">Seumur hidup</span>
                        </td>
                        <td>
                            <a x-show="item.file_url" :href="`${item.file_url}?download=1`" class="font-semibold whitespace-nowrap text-mr-700 hover:underline"><i class="fa-solid fa-download" aria-hidden="true"></i> Unduh</a>
                            <span x-show="!item.file_url" class="text-stone-600">-</span>
                        </td>
                        <td>
                            <div class="flex justify-end gap-1">
                                <button type="button" class="btn-ghost min-h-9 px-2.5 text-xs" @click="openCertForm(item)">Edit</button>
                                <button type="button" class="btn-ghost min-h-9 px-2.5 text-xs text-mr-700" @click="removeCert = { open: true, item }">Hapus</button>
                            </div>
                        </td>
                    </tr>
                </template>
            </tbody>
        </table>
    </div>
</section>
