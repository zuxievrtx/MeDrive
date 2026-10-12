@props(['type'])
{{-- Warna & ikon jenis laporan selalu dari report_types (bukan hardcode); chip solid membedakannya dari badge status. --}}
@php
    $color = $type?->color ?: '#57534e';
@endphp
<span {{ $attributes->class('inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 text-xs font-semibold whitespace-nowrap') }}
      style="background-color: {{ $color }}; color: {{ \App\Support\Color::readableTextOn($color) }}">
    @if ($type?->icon)<i class="fa-solid fa-{{ $type->icon }}" aria-hidden="true"></i>@endif
    {{ $type?->name ?? 'Jenis tidak diketahui' }}
</span>
