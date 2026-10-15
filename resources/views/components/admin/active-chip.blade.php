@props(['active' => 'row.is_active'])
<span {{ $attributes->class('inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold whitespace-nowrap ring-1 ring-inset') }}
      :class="window.badgeTone({!! $active !!} ? 'green' : 'gray')" x-text="{!! $active !!} ? 'Aktif' : 'Nonaktif'"></span>
