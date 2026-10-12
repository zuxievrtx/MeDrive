@props(['rows' => 4])
<div {{ $attributes->class('space-y-3 p-4') }} aria-hidden="true">
    @for ($i = 0; $i < $rows; $i++)
        <div class="skeleton h-4" style="width: {{ 90 - ($i % 3) * 18 }}%"></div>
    @endfor
</div>
