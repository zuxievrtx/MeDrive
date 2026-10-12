@props(['current', 'previous', 'label' => 'dibanding periode sebelumnya', 'higherIsBetter' => false])
{{-- Untuk laporan darurat, kenaikan jumlah bukan kabar baik, jadi naik = merah secara default. --}}
@php
    $delta = \App\Support\Delta::percent($current, $previous);
    $isUp = $current > $previous;
    $isGood = $current === $previous ? null : ($higherIsBetter ? $isUp : ! $isUp);
@endphp
<p {{ $attributes->class('mt-2 flex flex-wrap items-center gap-1 text-xs text-stone-600') }}>
    @if ($current === $previous)
        <span class="font-semibold text-stone-700"><i class="fa-solid fa-equals" aria-hidden="true"></i> sama</span>
    @else
        <span @class(['font-semibold', 'text-green-700' => $isGood, 'text-mr-700' => ! $isGood])>
            <i class="fa-solid {{ $isUp ? 'fa-arrow-trend-up' : 'fa-arrow-trend-down' }}" aria-hidden="true"></i>
            {{ $isUp ? 'naik' : 'turun' }} {{ $delta === null ? 'dari 0' : abs($delta).'%' }}
        </span>
    @endif
    <span>{{ $label }} ({{ $previous }})</span>
</p>
