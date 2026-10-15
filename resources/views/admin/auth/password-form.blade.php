<form method="POST" action="{{ route('admin.password.update') }}" class="space-y-5">
    @csrf
    @method('PUT')
    <x-admin.field name="current_password" label="Password saat ini" required :client="false">
        <input id="current_password" name="current_password" type="password" required autocomplete="current-password" class="form-input">
    </x-admin.field>
    <x-admin.field name="password" label="Password baru" required :client="false" hint="Minimal 8 karakter dan berbeda dari password saat ini.">
        <input id="password" name="password" type="password" required minlength="8" autocomplete="new-password" class="form-input">
    </x-admin.field>
    <x-admin.field name="password_confirmation" label="Ulangi password baru" required :client="false">
        <input id="password_confirmation" name="password_confirmation" type="password" required autocomplete="new-password" class="form-input">
    </x-admin.field>
    <button type="submit" class="btn-primary">Simpan password baru</button>
</form>
