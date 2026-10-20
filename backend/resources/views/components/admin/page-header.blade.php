@props(['title', 'description' => null])
<div {{ $attributes->class('mb-6 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between') }}>
    <div class="min-w-0">
        <h1 class="text-2xl font-bold tracking-tight text-stone-900">{{ $title }}</h1>
        @if ($description)
            <p class="mt-1 max-w-3xl text-sm text-stone-600">{{ $description }}</p>
        @endif
    </div>
    @isset($actions)
        <div class="flex flex-wrap items-center gap-2">{{ $actions }}</div>
    @endisset
</div>
