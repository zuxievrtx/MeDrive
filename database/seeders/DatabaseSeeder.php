<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

/**
 * Medrive — urutan seeder sesuai medrive_db_v3.sql.
 * Jalankan: php artisan migrate:fresh --seed
 */
class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            MasterDataSeeder::class,   // data master (wajib)
            DemoDataSeeder::class,     // data contoh untuk demo (boleh dilewati di produksi)
        ]);
    }
}
