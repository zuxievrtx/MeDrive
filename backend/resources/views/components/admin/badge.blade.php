@props(['tone' => 'gray', 'icon' => null])
@php
    $tones = [
        'amber' => 'bg-amber-100 text-amber-900 ring-amber-200',
        'blue' => 'bg-blue-100 text-blue-900 ring-blue-200',
        'violet' => 'bg-violet-100 text-violet-900 ring-violet-200',
        'cyan' => 'bg-cyan-100 text-cyan-900 ring-cyan-200',
        'teal' => 'bg-teal-100 text-teal-900 ring-teal-200',
        'green' => 'bg-green-100 text-green-900 ring-green-200',
        'gray' => 'bg-stone-100 text-stone-700 ring-stone-200',
        'red' => 'bg-mr-50 text-mr-800 ring-mr-300',
        'brand' => 'bg-mr-600 text-white ring-mr-600',
    ];
@endphp
<span {{ $attributes->class(['inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold whitespace-nowrap ring-1 ring-inset', $tones[$tone] ?? $tones['gray']]) }}>
    @if ($icon)<i class="fa-solid fa-{{ $icon }} text-[10px]" aria-hidden="true"></i>@endif
    {{ $slot }}
</span>
