@props(['action', 'resetUrl'])
<form method="GET" action="{{ $action }}" {{ $attributes->class('card mb-4 grid gap-3 p-4 sm:grid-cols-2 lg:grid-cols-[repeat(auto-fit,minmax(11rem,1fr))] lg:items-end') }} role="search">
    {{ $slot }}
    <div class="flex gap-2 sm:col-span-2 lg:col-span-1">
        <button type="submit" class="btn-primary flex-1"><i class="fa-solid fa-filter" aria-hidden="true"></i> Terapkan</button>
        <a href="{{ $resetUrl }}" class="btn-ghost">Reset</a>
    </div>
</form>
