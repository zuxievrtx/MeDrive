@php
    $isActive = request()->routeIs($item['active']);
    $href = $item['href'] ?? route($item['route']);
@endphp
<li>
    <a href="{{ $href }}"
       title="{{ $item['label'] }}"
       @class([
           'flex min-h-10 items-center gap-3 rounded-lg px-3 text-sm transition-colors',
           'bg-mr-700 font-semibold text-white ring-1 ring-white/20 ring-inset' => $isActive,
           'text-white/85 hover:bg-mr-700/70 hover:text-white' => ! $isActive,
       ])
       @if ($isActive) aria-current="page" @endif>
        <i class="fa-solid fa-{{ $item['icon'] }} w-5 shrink-0 text-center" aria-hidden="true"></i>
        <span class="truncate" :class="{ 'lg:sr-only': $store.sidebar.collapsed }">{{ $item['label'] }}</span>
    </a>
</li>
