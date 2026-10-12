<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Data master Medrive: jenis ambulans, jenis laporan, pemetaan jenis, instansi, klinik.
 * Dibuat otomatis dari medrive_db_v3.sql — nilai SAMA PERSIS dengan skrip SQL
 * (id, teks, angka desimal, tanggal, dan hash password tidak diubah).
 *
 * Tabel: ambulance_types, report_types, report_type_ambulance_types, institutions, clinics
 */
class MasterDataSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('ambulance_types')->insert([
            [
                'id'          => 1,
                'code'        => 'gawat_darurat',
                'name'        => 'Ambulans Gawat Darurat',
                'description' => 'Dilengkapi alat bantu napas & monitor, untuk pasien kritis',
            ],
            [
                'id'          => 2,
                'code'        => 'transport',
                'name'        => 'Ambulans Transport',
                'description' => 'Untuk pasien stabil, termasuk ibu hamil tanpa komplikasi',
            ],
            [
                'id'          => 3,
                'code'        => 'jenazah',
                'name'        => 'Ambulans Jenazah',
                'description' => 'Khusus pengantaran jenazah',
            ],
        ]);

        DB::table('report_types')->insert([
            [
                'id'                   => 1,
                'code'                 => 'kecelakaan',
                'name'                 => 'Kecelakaan',
                'description'          => 'Kecelakaan lalu lintas atau kecelakaan lain dengan korban',
                'priority'             => 1,
                'is_emergency'         => true,
                'requires_destination' => false,
                'icon'                 => 'car-crash',
                'color'                => '#B5523B',
                'sort_order'           => 1,
            ],
            [
                'id'                   => 2,
                'code'                 => 'medis_darurat',
                'name'                 => 'Medis Darurat',
                'description'          => 'Kondisi medis mendadak: jantung, stroke, sesak, kejang',
                'priority'             => 1,
                'is_emergency'         => true,
                'requires_destination' => false,
                'icon'                 => 'heart-pulse',
                'color'                => '#C2410C',
                'sort_order'           => 2,
            ],
            [
                'id'                   => 3,
                'code'                 => 'ibu_hamil',
                'name'                 => 'Ibu Hamil',
                'description'          => 'Ibu hamil yang akan melahirkan atau mengalami komplikasi',
                'priority'             => 2,
                'is_emergency'         => true,
                'requires_destination' => true,
                'icon'                 => 'baby',
                'color'                => '#2F6F6A',
                'sort_order'           => 3,
            ],
            [
                'id'                   => 4,
                'code'                 => 'pengantaran_jenazah',
                'name'                 => 'Pengantaran Jenazah',
                'description'          => 'Pengantaran jenazah, dapat dijadwalkan',
                'priority'             => 4,
                'is_emergency'         => false,
                'requires_destination' => true,
                'icon'                 => 'bed',
                'color'                => '#4E6A85',
                'sort_order'           => 4,
            ],
        ]);

        DB::table('report_type_ambulance_types')->insert([
            [
                'report_type_id'    => 1,
                'ambulance_type_id' => 1,
            ],  // kecelakaan       -> gawat darurat
            [
                'report_type_id'    => 2,
                'ambulance_type_id' => 1,
            ],
            [
                'report_type_id'    => 2,
                'ambulance_type_id' => 2,
            ],  // medis darurat    -> gawat darurat, transport
            [
                'report_type_id'    => 3,
                'ambulance_type_id' => 1,
            ],
            [
                'report_type_id'    => 3,
                'ambulance_type_id' => 2,
            ],  // ibu hamil        -> gawat darurat, transport
            [
                'report_type_id'    => 4,
                'ambulance_type_id' => 3,
            ],
        ]);

        DB::table('institutions')->insert([
            [
                'id'      => 1,
                'code'    => 'DINKES-SMG',
                'name'    => 'Dinas Kesehatan Kota Semarang',
                'type'    => 'pemerintah',
                'phone'   => '0248318070',
                'email'   => 'dinkes@semarangkota.test',
                'address' => 'Jl. Pandanaran No. 79, Semarang',
            ],
            [
                'id'      => 2,
                'code'    => 'PMI-SMG',
                'name'    => 'PMI Kota Semarang',
                'type'    => 'sosial',
                'phone'   => '0248415900',
                'email'   => 'pmi@pmismg.test',
                'address' => 'Jl. MT Haryono No. 488, Semarang',
            ],
            [
                'id'      => 3,
                'code'    => 'YSS',
                'name'    => 'Yayasan Sehat Sejahtera',
                'type'    => 'swasta',
                'phone'   => '0247600123',
                'email'   => 'info@yss.test',
                'address' => 'Jl. Majapahit No. 12, Semarang',
            ],
        ]);

        DB::table('clinics')->insert([
            [
                'id'             => 1,
                'institution_id' => 1,
                'code'           => 'PKM-TBL',
                'name'           => 'Puskesmas Tembalang',
                'type'           => 'puskesmas',
                'phone'          => '0247460001',
                'address'        => 'Jl. Tembalang Raya, Semarang',
                'latitude'       => '-7.0537000',
                'longitude'      => '110.4383000',
            ],
            [
                'id'             => 2,
                'institution_id' => 2,
                'code'           => 'POS-SL',
                'name'           => 'Pos Ambulans PMI Simpang Lima',
                'type'           => 'pos_ambulans',
                'phone'          => '0248415901',
                'address'        => 'Kawasan Simpang Lima, Semarang',
                'latitude'       => '-6.9900000',
                'longitude'      => '110.4227000',
            ],
            [
                'id'             => 3,
                'institution_id' => 3,
                'code'           => 'KLN-PDR',
                'name'           => 'Klinik Sehat Pedurungan',
                'type'           => 'klinik',
                'phone'          => '0247600124',
                'address'        => 'Jl. Majapahit No. 12, Pedurungan',
                'latitude'       => '-7.0012000',
                'longitude'      => '110.4645000',
            ],
        ]);
    }
}
