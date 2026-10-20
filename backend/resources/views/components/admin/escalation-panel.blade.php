{{-- Panel eskalasi dispatch: laporan yang broadcast-nya sudah diperluas atau dialarmkan (semua ronde lewat).
     Sumber: $store.escalations (API /admin/escalations + event DispatchEscalated). --}}
<section {{ $attributes->class('card overflow-hidden') }} aria-labelledby="escalation-title" x-data>
    <div class="flex flex-wrap items-center justify-between gap-2 border-b border-stone-100 px-5 py-3"
         :class="$store.escalations.alarmCount > 0 ? 'bg-mr-600 text-white' : ''">
        <h2 id="escalation-title" class="flex items-center gap-2 font-semibold">
            <i class="fa-solid fa-tower-broadcast" aria-hidden="true"></i> Eskalasi dispatch
        </h2>
        <span x-show="$store.escalations.alarmCount > 0" x-cloak class="tabular rounded-md bg-white px-2 py-0.5 text-xs font-bold text-mr-700"
              x-text="`${$store.escalations.alarmCount} alarm aktif`"></span>
    </div>
    <template x-if="!$store.escalations.loaded">
        <x-admin.skeleton-rows :rows="2" />
    </template>
    <template x-if="$store.escalations.loaded && $store.escalations.items.length === 0">
        <p class="px-5 py-4 text-sm text-stone-600">Tidak ada laporan yang perlu perluasan broadcast. Laporan menunggu masih dalam ronde pertama.</p>
    </template>
    <ul class="max-h-80 divide-y divide-stone-100 overflow-y-auto">
        <template x-for="item in $store.escalations.items" :key="item.id">
            <li>
                <a :href="item.url" class="block px-5 py-3 hover:bg-mr-50" :class="item.is_final ? 'bg-mr-50' : ''">
                    <div class="flex flex-wrap items-center justify-between gap-2">
                        <span class="tabular text-sm font-semibold" x-text="item.code"></span>
                        <span class="text-xs font-semibold" :class="item.is_final ? 'text-mr-700' : 'text-amber-800'"
                              x-text="item.is_final ? 'Semua ronde lewat' : `Ronde ${item.round} dari ${item.total_rounds}`"></span>
                    </div>
                    <div class="mt-1 flex flex-wrap items-center gap-2 text-xs text-stone-700">
                        <x-admin.type-chip type="item.type" />
                        <span x-text="item.radius_km ? `radius ${item.radius_km} km` : 'seluruh area'"></span>
                        <span x-text="`menunggu ${item.waiting_minutes} menit`"></span>
                    </div>
                </a>
            </li>
        </template>
    </ul>
    <p class="border-t border-stone-100 px-5 py-2 text-xs text-stone-600">Admin tidak menugaskan driver manual. Gunakan panel ini untuk memantau dan menghubungi klinik bila perlu.</p>
</section>
