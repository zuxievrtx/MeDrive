@props(['status' => 'row.status'])
{{-- Versi Alpine dari badge: tone status dikirim API ({ value, label, tone }). --}}
<span {{ $attributes->class('inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold whitespace-nowrap ring-1 ring-inset') }}
      :class="window.badgeTone({!! $status !!}?.tone)" x-text="{!! $status !!}?.label"></span>
