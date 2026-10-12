@props(['user', 'size' => 'md', 'photoUrl' => null])
@php
    $sizes = ['sm' => 'size-8 text-xs', 'md' => 'size-10 text-sm', 'lg' => 'size-16 text-lg', 'xl' => 'size-24 text-2xl'];
@endphp
@if ($photoUrl)
    <img src="{{ $photoUrl }}" alt="Foto {{ $user->name }}" loading="lazy" {{ $attributes->class([$sizes[$size], 'shrink-0 rounded-full object-cover ring-1 ring-stone-200']) }}>
@else
    <span {{ $attributes->class([$sizes[$size], 'grid shrink-0 place-items-center rounded-full bg-mr-50 font-bold text-mr-800 ring-1 ring-mr-300']) }} aria-hidden="true">{{ $user->initials() }}</span>
@endif
