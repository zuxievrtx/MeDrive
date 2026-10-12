@props(['title'])
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $title }} · Medrive Admin</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="min-h-screen">
    <div class="grid min-h-screen lg:grid-cols-[minmax(0,5fr)_minmax(0,6fr)]">
        <section class="sidebar-surface relative hidden flex-col justify-between overflow-hidden p-10 text-white lg:flex">
            <div class="flex items-center gap-3">
                <span class="grid size-11 place-items-center rounded-xl bg-mr-600 text-lg" aria-hidden="true"><i class="fa-solid fa-truck-medical"></i></span>
                <span class="text-2xl font-bold tracking-tight">Medrive</span>
            </div>
            <div class="max-w-md">
                <p class="text-3xl leading-tight font-bold">Pusat kendali laporan darurat dan armada ambulans.</p>
                <p class="mt-4 text-base text-white/85">Pantau laporan yang masuk, posisi ambulans, dan data master driver dari satu tempat. Penugasan tetap berjalan lewat broadcast ke aplikasi driver.</p>
            </div>
            <p class="text-sm text-white/75">Akses khusus admin pusat.</p>
        </section>

        <main class="flex items-center justify-center px-4 py-10 sm:px-8">
            <div class="w-full max-w-md">
                <div class="mb-8 flex items-center gap-3 lg:hidden">
                    <span class="grid size-10 place-items-center rounded-xl bg-mr-600 text-white" aria-hidden="true"><i class="fa-solid fa-truck-medical"></i></span>
                    <span class="text-xl font-bold tracking-tight">Medrive</span>
                </div>
                {{ $slot }}
            </div>
        </main>
    </div>
</body>
</html>
