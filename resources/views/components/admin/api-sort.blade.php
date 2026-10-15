@props(['column', 'label'])
<button type="button" @click="sortBy('{{ $column }}')" class="inline-flex items-center gap-1 hover:text-mr-700"
        :class="filters.sort === '{{ $column }}' ? 'text-stone-900' : ''"
        :aria-sort="filters.sort === '{{ $column }}' ? (filters.direction === 'desc' ? 'descending' : 'ascending') : null">
    {{ $label }} <i class="fa-solid text-[10px]" :class="sortIcon('{{ $column }}')" aria-hidden="true"></i>
</button>
