@props(['name', 'label', 'required' => false, 'hint' => null])
<div {{ $attributes }}>
    <label for="{{ $name }}" class="form-label">{{ $label }} @if ($required)<span class="text-mr-700" aria-hidden="true">*</span>@endif</label>
    {{ $slot }}
    @if ($hint)
        <p class="form-hint">{{ $hint }}</p>
    @endif
    @error($name)
        <p class="form-error">{{ $message }}</p>
    @enderror
</div>
