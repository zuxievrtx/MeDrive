@props(['type' => 'row.report_type'])
{{-- Versi Alpine dari type-badge: warna & ikon dari report_types (API). --}}
<span {{ $attributes->class('inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 text-xs font-semibold whitespace-nowrap') }}
      :style="window.typeStyle({!! $type !!})">
    <i class="fa-solid" :class="window.typeIcon({!! $type !!})" aria-hidden="true"></i>
    <span x-text="{!! $type !!}?.name ?? 'Jenis tidak diketahui'"></span>
</span>
