@props(['show', 'title', 'maxWidth' => 'max-w-lg'])
{{-- Dipakai di dalam scope x-data yang memiliki properti boolean $show. --}}
<div x-cloak x-show="{{ $show }}" x-transition.opacity
     class="fixed inset-0 z-[70] flex items-end justify-center bg-stone-950/50 p-4 sm:items-center"
     @keydown.escape.window="{{ $show }} = false" role="dialog" aria-modal="true" aria-label="{{ $title }}">
    <div class="card w-full {{ $maxWidth }} p-6" @click.outside="{{ $show }} = false" x-trap.noscroll="{{ $show }}">
        <div class="mb-4 flex items-start justify-between gap-4">
            <h2 class="text-lg font-bold text-stone-900">{{ $title }}</h2>
            <button type="button" class="grid size-9 place-items-center rounded-lg text-stone-500 hover:bg-stone-100" @click="{{ $show }} = false" aria-label="Tutup">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        {{ $slot }}
    </div>
</div>
