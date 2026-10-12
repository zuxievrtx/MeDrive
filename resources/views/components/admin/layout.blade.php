@props(['title', 'breadcrumbs' => []])
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="poll-interval" content="{{ config('medrive.poll_interval_ms') }}">
    <meta name="signal-lost-seconds" content="{{ config('medrive.signal_lost_seconds') }}">
    <title>{{ $title }} · Medrive Admin</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="min-h-screen">
    <a href="#konten" class="sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-2 focus:z-[100] focus:rounded-lg focus:bg-white focus:px-4 focus:py-2">Lewati ke konten</a>

    <div class="flex min-h-screen" x-data>
        @include('admin.partials.sidebar')

        <div class="flex min-w-0 flex-1 flex-col">
            @include('admin.partials.topbar', ['title' => $title, 'breadcrumbs' => $breadcrumbs])

            <main id="konten" class="flex-1 px-4 py-6 sm:px-6 lg:px-8">
                {{ $slot }}
            </main>
        </div>
    </div>

    @include('admin.partials.toasts')
</body>
</html>
