<div class="pointer-events-none fixed right-4 bottom-4 z-[60] flex w-[min(24rem,calc(100vw-2rem))] flex-col gap-2"
     x-data
     x-init="
        @if (session('success')) $store.toasts.push({ title: @js(session('success')), tone: 'success' }); @endif
        @if (session('error')) $store.toasts.push({ title: @js(session('error')), tone: 'error', timeout: 9000 }); @endif
     "
     aria-live="polite">
    <template x-for="toast in $store.toasts.items" :key="toast.id">
        <div x-transition class="card pointer-events-auto flex items-start gap-3 p-3"
             :class="{
                'border-green-300': toast.tone === 'success',
                'border-mr-300': toast.tone === 'error' || toast.tone === 'alert',
             }"
             role="status">
            <span class="mt-0.5 grid size-7 shrink-0 place-items-center rounded-full text-xs"
                  :class="{
                     'bg-green-100 text-green-800': toast.tone === 'success',
                     'bg-mr-600 text-white': toast.tone === 'alert',
                     'bg-mr-50 text-mr-700': toast.tone === 'error',
                     'bg-stone-100 text-stone-700': toast.tone === 'info',
                  }">
                <i class="fa-solid" :class="{
                    'fa-check': toast.tone === 'success',
                    'fa-bell': toast.tone === 'alert',
                    'fa-triangle-exclamation': toast.tone === 'error',
                    'fa-circle-info': toast.tone === 'info',
                }"></i>
            </span>
            <div class="min-w-0 flex-1">
                <div class="text-sm font-semibold" x-text="toast.title"></div>
                <div class="text-sm text-stone-700" x-show="toast.message" x-text="toast.message"></div>
                <a x-show="toast.url" :href="toast.url" class="mt-1 inline-block text-sm font-semibold text-mr-700 hover:underline">Buka laporan</a>
            </div>
            <button type="button" class="grid size-8 place-items-center rounded-lg text-stone-500 hover:bg-stone-100" @click="$store.toasts.dismiss(toast.id)" aria-label="Tutup notifikasi">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
    </template>
</div>
