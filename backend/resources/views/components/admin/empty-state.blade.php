@props(['icon' => 'inbox', 'title', 'description' => null])
<div {{ $attributes->class('flex flex-col items-center justify-center px-6 py-12 text-center') }}>
    <span class="mb-3 grid size-12 place-items-center rounded-full bg-stone-100 text-stone-500"><i class="fa-solid fa-{{ $icon }}" aria-hidden="true"></i></span>
    <p class="text-sm font-semibold text-stone-900">{{ $title }}</p>
    @if ($description)
        <p class="mt-1 max-w-sm text-sm text-stone-600">{{ $description }}</p>
    @endif
    @isset($action)
        <div class="mt-4">{{ $action }}</div>
    @endisset
</div>
