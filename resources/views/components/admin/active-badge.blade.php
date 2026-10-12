@props(['active'])
<x-admin.badge :tone="$active ? 'green' : 'gray'">{{ $active ? 'Aktif' : 'Nonaktif' }}</x-admin.badge>
