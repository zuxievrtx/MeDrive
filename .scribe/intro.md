# Introduction

API untuk aplikasi Pelapor, aplikasi Driver, dan dashboard Admin Medrive.

<aside>
    <strong>Base URL</strong>: <code>http://localhost:8000</code>
</aside>

    Semua endpoint berada di `/api/v1` dan wajib mengirim header `Accept: application/json`.

    **Format respons sukses**: `{ "success": true, "data": ..., "meta": { "pagination": {...} } }`.
    **Format error**: `{ "success": false, "error": { "code": "...", "message": "...", "details": {...} } }`.
    Kode HTTP: 400 validasi, 401 belum masuk, 403 dilarang, 404 tidak ditemukan, 409 konflik, 422 aturan bisnis, 429 terlalu sering.

    Aplikasi mobile memakai token Bearer dari `POST /api/v1/auth/login`. Dashboard admin memakai cookie session (Sanctum SPA).
    Panduan integrasi Flutter (autentikasi, FCM, interval lokasi adaptif, batching, kanal realtime, Idempotency-Key) ada di `docs/api.md`.

