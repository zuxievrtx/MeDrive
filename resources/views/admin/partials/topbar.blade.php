<header class="sticky top-0 z-30 flex h-16 items-center gap-3 border-b border-stone-200 bg-white/95 px-4 backdrop-blur sm:px-6 lg:px-8">
    <button type="button" class="grid size-10 place-items-center rounded-lg text-stone-700 hover:bg-stone-100 lg:hidden"
            @click="$store.sidebar.mobileOpen = true" aria-label="Buka menu">
        <i class="fa-solid fa-bars"></i>
    </button>

    <nav aria-label="Breadcrumb" class="min-w-0 flex-1">
        <ol class="flex min-w-0 items-center gap-1.5 text-sm">
            <li class="hidden sm:block"><a href="{{ route('admin.dashboard') }}" class="text-stone-600 hover:text-mr-700">Beranda</a></li>
            @foreach ($breadcrumbs as $label => $url)
                <li class="hidden items-center gap-1.5 sm:flex"><i class="fa-solid fa-chevron-right text-[10px] text-stone-400" aria-hidden="true"></i>
                    <a href="{{ $url }}" class="text-stone-600 hover:text-mr-700">{{ $label }}</a></li>
            @endforeach
            <li class="flex min-w-0 items-center gap-1.5">
                <span class="hidden sm:inline" aria-hidden="true"><i class="fa-solid fa-chevron-right text-[10px] text-stone-400"></i></span>
                <span class="truncate font-semibold text-stone-900" aria-current="page">{{ $title }}</span>
            </li>
        </ol>
    </nav>

    <div x-data="clock" class="hidden text-right leading-tight md:block" aria-label="Waktu sekarang (WIB)">
        <div class="tabular text-sm font-semibold text-stone-900"><span x-text="time"></span> <span class="text-xs font-medium text-stone-600">WIB</span></div>
        <div class="text-xs text-stone-600" x-text="date"></div>
    </div>

    <div class="relative" x-data="notifications(@js(['url' => route('admin.notifications'), 'pendingCount' => $pendingReportCount, 'lastReportId' => $lastReportId]))"
         @keydown.escape.window="open = false" @click.outside="open = false">
        <button type="button" @click="toggle()" class="relative grid size-10 place-items-center rounded-lg text-stone-700 hover:bg-stone-100"
                :aria-expanded="open" aria-haspopup="true"
                :aria-label="`Notifikasi, ${pendingCount} laporan menunggu`">
            <i class="fa-solid fa-bell"></i>
            <span x-show="pendingCount > 0" x-cloak
                  class="tabular absolute -top-0.5 -right-0.5 grid min-w-5 place-items-center rounded-full bg-mr-600 px-1 text-[11px] font-bold text-white"
                  x-text="pendingCount > 99 ? '99+' : pendingCount"></span>
        </button>

        <div x-show="open" x-cloak x-transition.origin.top.right
             class="card absolute right-0 mt-2 w-[min(22rem,calc(100vw-2rem))] overflow-hidden">
            <div class="flex items-center justify-between border-b border-stone-100 px-4 py-3">
                <div>
                    <div class="text-sm font-semibold">Laporan menunggu</div>
                    <div class="text-xs text-stone-600">
                        <span x-text="mode === 'realtime' ? 'Terhubung realtime' : 'Cadangan: diperbarui tiap 10 detik'"></span>
                    </div>
                </div>
                <button type="button" @click="toggleSound()" class="btn-ghost min-h-9 px-2 text-xs"
                        :aria-pressed="soundEnabled" title="Bunyi untuk laporan prioritas 1">
                    <i class="fa-solid" :class="soundEnabled ? 'fa-volume-high' : 'fa-volume-xmark'"></i>
                    <span x-text="soundEnabled ? 'Bunyi aktif' : 'Bunyi mati'"></span>
                </button>
            </div>
            <div class="max-h-80 overflow-y-auto">
                <template x-if="loading">
                    <div class="space-y-3 p-4"><div class="skeleton h-4 w-3/4"></div><div class="skeleton h-4 w-1/2"></div></div>
                </template>
                <template x-if="!loading && error">
                    <p class="p-4 text-sm text-mr-700" x-text="error"></p>
                </template>
                <template x-if="!loading && !error && items.length === 0">
                    <p class="p-4 text-sm text-stone-600">Tidak ada laporan yang menunggu driver.</p>
                </template>
                <template x-for="item in items" :key="item.id">
                    <a :href="item.url" class="block border-b border-stone-100 px-4 py-3 last:border-0 hover:bg-mr-50">
                        <div class="flex items-center justify-between gap-2">
                            <span class="tabular text-sm font-semibold" x-text="item.code"></span>
                            <span class="text-xs text-stone-600" x-text="item.age"></span>
                        </div>
                        <div class="text-xs text-stone-700"><span x-text="item.type.name"></span> · <span x-text="item.address"></span></div>
                    </a>
                </template>
            </div>
            <a href="{{ route('admin.reports.index', ['status' => 'menunggu']) }}" class="block border-t border-stone-100 px-4 py-2.5 text-center text-sm font-semibold text-mr-700 hover:bg-mr-50">
                Lihat semua laporan menunggu
            </a>
        </div>
    </div>

    <div class="relative" x-data="{ open: false }" @keydown.escape.window="open = false" @click.outside="open = false">
        <button type="button" @click="open = !open" class="flex min-h-10 items-center gap-2 rounded-lg px-2 hover:bg-stone-100" :aria-expanded="open" aria-haspopup="true">
            <span class="grid size-8 place-items-center rounded-full bg-mr-900 text-xs font-bold text-white">{{ auth()->user()->initials() }}</span>
            <span class="hidden max-w-40 truncate text-sm font-medium sm:block">{{ auth()->user()->name }}</span>
            <i class="fa-solid fa-chevron-down text-xs text-stone-500" aria-hidden="true"></i>
        </button>
        <div x-show="open" x-cloak x-transition.origin.top.right class="card absolute right-0 mt-2 w-60 p-1.5">
            <div class="px-3 py-2">
                <div class="truncate text-sm font-semibold">{{ auth()->user()->name }}</div>
                <div class="truncate text-xs text-stone-600">{{ auth()->user()->email }}</div>
            </div>
            <a href="{{ route('admin.password.edit') }}" class="flex min-h-10 items-center gap-2 rounded-lg px-3 text-sm hover:bg-stone-100">
                <i class="fa-solid fa-key w-4 text-stone-500" aria-hidden="true"></i> Ganti password
            </a>
            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit" class="flex min-h-10 w-full items-center gap-2 rounded-lg px-3 text-sm text-mr-700 hover:bg-mr-50">
                    <i class="fa-solid fa-right-from-bracket w-4" aria-hidden="true"></i> Keluar
                </button>
            </form>
        </div>
    </div>
</header>
