@props(['status'])
<x-admin.badge :tone="$status->tone()" {{ $attributes }}>{{ $status->label() }}</x-admin.badge>
