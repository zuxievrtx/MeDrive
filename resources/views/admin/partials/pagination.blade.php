@if ($paginator->hasPages())
    <nav role="navigation" aria-label="Navigasi halaman" class="flex flex-col items-center justify-between gap-3 sm:flex-row">
        <p class="text-sm text-stone-600">
            Menampilkan <span class="tabular font-semibold text-stone-900">{{ $paginator->firstItem() }}</span>
            sampai <span class="tabular font-semibold text-stone-900">{{ $paginator->lastItem() }}</span>
            dari <span class="tabular font-semibold text-stone-900">{{ $paginator->total() }}</span> data
        </p>
        <ul class="flex flex-wrap items-center gap-1">
            <li>
                @if ($paginator->onFirstPage())
                    <span class="btn-ghost pointer-events-none opacity-40" aria-disabled="true"><i class="fa-solid fa-chevron-left" aria-hidden="true"></i><span class="sr-only">Sebelumnya</span></span>
                @else
                    <a href="{{ $paginator->previousPageUrl() }}" rel="prev" class="btn-ghost"><i class="fa-solid fa-chevron-left" aria-hidden="true"></i><span class="sr-only">Sebelumnya</span></a>
                @endif
            </li>
            @foreach ($elements as $element)
                @if (is_string($element))
                    <li><span class="px-2 text-stone-500">{{ $element }}</span></li>
                @endif
                @if (is_array($element))
                    @foreach ($element as $page => $url)
                        <li>
                            @if ($page == $paginator->currentPage())
                                <span aria-current="page" class="btn tabular min-w-10 bg-mr-600 px-3 text-white">{{ $page }}</span>
                            @else
                                <a href="{{ $url }}" class="btn-ghost tabular min-w-10" aria-label="Halaman {{ $page }}">{{ $page }}</a>
                            @endif
                        </li>
                    @endforeach
                @endif
            @endforeach
            <li>
                @if ($paginator->hasMorePages())
                    <a href="{{ $paginator->nextPageUrl() }}" rel="next" class="btn-ghost"><i class="fa-solid fa-chevron-right" aria-hidden="true"></i><span class="sr-only">Berikutnya</span></a>
                @else
                    <span class="btn-ghost pointer-events-none opacity-40" aria-disabled="true"><i class="fa-solid fa-chevron-right" aria-hidden="true"></i><span class="sr-only">Berikutnya</span></span>
                @endif
            </li>
        </ul>
    </nav>
@endif
