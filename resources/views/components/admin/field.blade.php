@props(['name', 'label', 'required' => false, 'hint' => null, 'client' => true])
{{-- client=true: error validasi dari API (apiForm.errors); false: error session untuk form web biasa. --}}
<div {{ $attributes }}>
    <label for="{{ $name }}" class="form-label">{{ $label }} @if ($required)<span class="text-mr-700" aria-hidden="true">*</span>@endif</label>
    {{ $slot }}
    @if ($hint)
        <p class="form-hint">{{ $hint }}</p>
    @endif
    @if ($client)
        <p class="form-error" x-cloak x-show="error(@js($name))" x-text="error(@js($name))"></p>
    @else
        @error($name)
            <p class="form-error">{{ $message }}</p>
        @enderror
    @endif
</div>
