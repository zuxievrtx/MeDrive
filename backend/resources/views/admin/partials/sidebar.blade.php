@php
    $menu = [
        ['label' => 'Dashboard', 'icon' => 'gauge-high', 'route' => 'admin.dashboard', 'active' => 'admin.dashboard'],
        ['label' => 'Laporan Darurat', 'icon' => 'truck-medical', 'children' => [
            ['label' => 'Daftar Laporan', 'icon' => 'file-medical', 'route' => 'admin.reports.index', 'active' => 'admin.reports.*'],
            ['label' => 'Peta Live', 'icon' => 'map-location-dot', 'route' => 'admin.tracking.index', 'active' => 'admin.tracking.*'],
            ['label' => 'Log Lokasi', 'icon' => 'route', 'route' => 'admin.location-logs.index', 'active' => 'admin.location-logs.*'],
        ]],
        ['label' => 'Manajemen Armada', 'icon' => 'warehouse', 'children' => [
            ['label' => 'Driver', 'icon' => 'id-card', 'route' => 'admin.drivers.index', 'active' => 'admin.drivers.*'],
            ['label' => 'Ambulans', 'icon' => 'van-shuttle', 'route' => 'admin.ambulances.index', 'active' => 'admin.ambulances.*'],
            ['label' => 'Jenis Ambulans', 'icon' => 'tags', 'route' => 'admin.ambulance-types.index', 'active' => 'admin.ambulance-types.*'],
        ]],
        ['label' => 'Organisasi', 'icon' => 'sitemap', 'children' => [
            ['label' => 'Instansi', 'icon' => 'building', 'route' => 'admin.institutions.index', 'active' => 'admin.institutions.*'],
            ['label' => 'Klinik', 'icon' => 'house-medical', 'route' => 'admin.clinics.index', 'active' => 'admin.clinics.*'],
        ]],
        ['label' => 'Master Jenis Laporan', 'icon' => 'list-check', 'route' => 'admin.report-types.index', 'active' => 'admin.report-types.*'],
        ['label' => 'Statistik dan Grafik', 'icon' => 'chart-column', 'route' => 'admin.statistics.index', 'active' => 'admin.statistics.*'],
        ['label' => 'Sistem', 'icon' => 'gear', 'children' => [
            ['label' => 'Log Aktivitas Admin', 'icon' => 'clock-rotate-left', 'route' => 'admin.activity-logs.index', 'active' => 'admin.activity-logs.*'],
            ['label' => 'Pengguna Pelapor', 'icon' => 'users', 'route' => 'admin.users.index', 'active' => 'admin.users.*'],
        ]],
    ];
@endphp

{{-- Latar gelap untuk sidebar mobile --}}
<div x-cloak x-show="$store.sidebar.mobileOpen" x-transition.opacity
     class="fixed inset-0 z-40 bg-stone-950/50 lg:hidden"
     @click="$store.sidebar.mobileOpen = false"></div>

<aside
    class="sidebar-surface fixed inset-y-0 left-0 z-50 flex w-64 shrink-0 -translate-x-full flex-col text-white transition-[width,transform] duration-200 lg:sticky lg:top-0 lg:h-screen lg:translate-x-0"
    :class="{ 'translate-x-0': $store.sidebar.mobileOpen, 'lg:w-[4.5rem]': $store.sidebar.collapsed }"
    @keydown.escape.window="$store.sidebar.mobileOpen = false"
    aria-label="Navigasi utama">
    <div class="flex h-16 items-center gap-3 px-4">
        <span class="grid size-9 shrink-0 place-items-center rounded-lg bg-mr-600 text-base" aria-hidden="true"><i class="fa-solid fa-truck-medical"></i></span>
        <div class="min-w-0" :class="{ 'lg:hidden': $store.sidebar.collapsed }">
            <div class="text-lg leading-tight font-bold tracking-tight">Medrive</div>
            <div class="text-xs text-white/80">Admin pusat dispatch</div>
        </div>
        <button type="button" class="ml-auto grid size-10 place-items-center rounded-lg text-white/90 hover:bg-white/10 lg:hidden"
                @click="$store.sidebar.mobileOpen = false" aria-label="Tutup menu">
            <i class="fa-solid fa-xmark"></i>
        </button>
    </div>

    <nav class="flex-1 overflow-y-auto px-3 pb-4">
        <ul class="space-y-1">
            @foreach ($menu as $item)
                @if (isset($item['children']))
                    <li class="pt-4">
                        <div class="px-3 pb-1 text-xs font-semibold text-white/75" :class="{ 'lg:sr-only': $store.sidebar.collapsed }">{{ $item['label'] }}</div>
                        <ul class="space-y-1">
                            @foreach ($item['children'] as $child)
                                @include('admin.partials.sidebar-link', ['item' => $child])
                            @endforeach
                        </ul>
                    </li>
                @else
                    @include('admin.partials.sidebar-link', ['item' => $item])
                @endif
            @endforeach
        </ul>
    </nav>

    <div class="hidden border-t border-white/15 p-3 lg:block">
        <button type="button" @click="$store.sidebar.toggle()"
                class="flex min-h-10 w-full items-center gap-3 rounded-lg px-3 text-sm text-white/85 hover:bg-white/10"
                :aria-label="$store.sidebar.collapsed ? 'Lebarkan sidebar' : 'Ciutkan sidebar'">
            <i class="fa-solid w-5 text-center" :class="$store.sidebar.collapsed ? 'fa-angles-right' : 'fa-angles-left'"></i>
            <span :class="{ 'lg:hidden': $store.sidebar.collapsed }">Ciutkan menu</span>
        </button>
    </div>
</aside>
