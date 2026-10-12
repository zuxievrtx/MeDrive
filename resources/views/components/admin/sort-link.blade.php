@props(['column', 'label', 'sort', 'direction'])
@php
    $isActive = $sort === $column;
    $nextDirection = $isActive && $direction === 'asc' ? 'desc' : 'asc';
@endphp
<a href="{{ request()->fullUrlWithQuery(['sort' => $column, 'direction' => $nextDirection, 'page' => null]) }}"
   class="inline-flex items-center gap-1 hover:text-mr-700 {{ $isActive ? 'text-stone-900' : '' }}"
   @if ($isActive) aria-sort="{{ $direction === 'asc' ? 'ascending' : 'descending' }}" @endif>
    {{ $label }}
    <i class="fa-solid {{ $isActive ? ($direction === 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort text-stone-400' }} text-[10px]" aria-hidden="true"></i>
</a>
