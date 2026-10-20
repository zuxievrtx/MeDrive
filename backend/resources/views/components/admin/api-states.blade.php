@props(['icon' => 'inbox', 'empty' => 'Belum ada data', 'emptyDescription' => null, 'rows' => 5])
{{-- State loading, error, dan kosong untuk komponen apiList. --}}
<template x-if="loading && rows.length === 0"><x-admin.skeleton-rows :rows="$rows" /></template>
<template x-if="!loading && error">
    <div class="flex flex-col items-center px-6 py-10 text-center" role="alert">
        <span class="mb-3 grid size-12 place-items-center rounded-full bg-mr-50 text-mr-700"><i class="fa-solid fa-triangle-exclamation" aria-hidden="true"></i></span>
        <p class="text-sm font-semibold" x-text="error"></p>
        <button type="button" class="btn-secondary mt-4" @click="load()">Muat ulang</button>
    </div>
</template>
<template x-if="isEmpty">
    <x-admin.empty-state :icon="$icon" :title="$empty" :description="$emptyDescription" />
</template>
