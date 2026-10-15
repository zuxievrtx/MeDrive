{{-- Pagination untuk komponen apiList (meta.pagination dari API). --}}
<nav x-show="pagination && pagination.last_page > 1" x-cloak aria-label="Navigasi halaman"
     {{ $attributes->class('flex flex-col items-center justify-between gap-3 border-t border-stone-100 px-4 py-3 sm:flex-row') }}>
    <p class="tabular text-sm text-stone-600" x-text="rangeLabel"></p>
    <ul class="flex flex-wrap items-center gap-1">
        <li><button type="button" class="btn-ghost" :disabled="page <= 1" @click="goTo(page - 1)"><i class="fa-solid fa-chevron-left" aria-hidden="true"></i><span class="sr-only">Sebelumnya</span></button></li>
        <template x-for="(item, index) in pageNumbers" :key="`${item}-${index}`">
            <li>
                <span x-show="item === '...'" class="px-2 text-stone-500">...</span>
                <button type="button" x-show="item !== '...'" @click="goTo(item)" class="btn tabular min-w-10 px-3"
                        :class="item === page ? 'bg-mr-600 text-white' : 'text-stone-700 hover:bg-stone-100'"
                        :aria-current="item === page ? 'page' : null" :aria-label="`Halaman ${item}`" x-text="item"></button>
            </li>
        </template>
        <li><button type="button" class="btn-ghost" :disabled="page >= (pagination?.last_page ?? 1)" @click="goTo(page + 1)"><i class="fa-solid fa-chevron-right" aria-hidden="true"></i><span class="sr-only">Berikutnya</span></button></li>
    </ul>
</nav>
