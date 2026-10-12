@php $bind = $bind ?? null; @endphp
<div>
    <label for="{{ $prefix }}-cert-name" class="form-label">Nama sertifikat <span class="text-mr-700" aria-hidden="true">*</span></label>
    <input id="{{ $prefix }}-cert-name" name="name" type="text" maxlength="100" required class="form-input"
           @if ($bind) x-model="{{ $bind }}.name" @else value="{{ old('name') }}" @endif>
    @if (! $bind) @error('name')<p class="form-error">{{ $message }}</p>@enderror @endif
</div>
<div class="grid gap-4 sm:grid-cols-2">
    <div>
        <label for="{{ $prefix }}-cert-number" class="form-label">Nomor</label>
        <input id="{{ $prefix }}-cert-number" name="certificate_number" type="text" maxlength="50" class="form-input"
               @if ($bind) x-model="{{ $bind }}.certificate_number" @else value="{{ old('certificate_number') }}" @endif>
    </div>
    <div>
        <label for="{{ $prefix }}-cert-issuer" class="form-label">Penerbit</label>
        <input id="{{ $prefix }}-cert-issuer" name="issuer" type="text" maxlength="150" class="form-input"
               @if ($bind) x-model="{{ $bind }}.issuer" @else value="{{ old('issuer') }}" @endif>
    </div>
    <div>
        <label for="{{ $prefix }}-cert-issued" class="form-label">Tanggal terbit <span class="text-mr-700" aria-hidden="true">*</span></label>
        <input id="{{ $prefix }}-cert-issued" name="issued_at" type="date" max="{{ today()->toDateString() }}" required class="form-input"
               @if ($bind) x-model="{{ $bind }}.issued_at" @else value="{{ old('issued_at') }}" @endif>
        @if (! $bind) @error('issued_at')<p class="form-error">{{ $message }}</p>@enderror @endif
    </div>
    <div>
        <label for="{{ $prefix }}-cert-expires" class="form-label">Kedaluwarsa</label>
        <input id="{{ $prefix }}-cert-expires" name="expires_at" type="date" class="form-input"
               @if ($bind) x-model="{{ $bind }}.expires_at" @else value="{{ old('expires_at') }}" @endif>
        @if (! $bind) @error('expires_at')<p class="form-error">{{ $message }}</p>@enderror @endif
    </div>
</div>
<div>
    <label for="{{ $prefix }}-cert-file" class="form-label">Berkas {{ $bind ? 'pengganti ' : '' }}(PDF/JPG/PNG, maks 5 MB)</label>
    <input id="{{ $prefix }}-cert-file" name="file" type="file" accept=".pdf,image/jpeg,image/png"
           class="block w-full text-sm file:mr-3 file:min-h-10 file:rounded-lg file:border-0 file:bg-stone-100 file:px-4 file:text-sm file:font-semibold">
    @if (! $bind) @error('file')<p class="form-error">{{ $message }}</p>@enderror @endif
</div>
