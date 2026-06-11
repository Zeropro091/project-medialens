# Struktur Proyek & Workflow LIN

Dokumen ini dirancang untuk memberikan pemahaman mendalam tentang bagaimana komponen-komponen dalam proyek LIN saling berinteraksi, serta memudahkan navigasi bagi pengembang atau sistem administrator.

## 1. Arsitektur Folder (Project Map)

```text
lin/
├── .kiro/                  # Spesifikasi produk & rencana tugas (PRD)
├── public/                 # Aset statis yang dapat diakses publik
├── src/                    # Source code utama aplikasi
│   ├── components/         # Komponen UI modular (Auth, Markdown, dll)
│   ├── lib/                # Konfigurasi library & utilities
│   │   ├── firebase.ts     # Konfigurasi Otentikasi
│   │   ├── supabase.ts     # Konfigurasi Database & Storage
│   │   └── ssrUtils.ts     # Helper untuk Server-Side Rendering
│   ├── pages/              # Halaman utama aplikasi (Routing level)
│   ├── App.tsx             # Root component & Client Routing
│   ├── entry-client.tsx    # Client-side hydration untuk SSR
│   └── entry-server.tsx    # Server-side rendering entry point
├── supabase/               # Konfigurasi backend Supabase
│   ├── migrations/         # Skema database (SQL) - PENTING untuk migrasi
│   └── seed.sql            # Data awal (Kategori, Role default)
├── server.ts               # Express server yang menangani SSR & API
├── vite.config.ts          # Konfigurasi build Vite
├── MIGRATION_GUIDE.md      # Panduan setup server
└── README.md               # Overview proyek & cara menjalankan
```

---

## 2. Workflow Cara Kerja (Technical Workflow)

### A. SSR (Server-Side Rendering) Flow
Aplikasi ini tidak hanya berjalan di browser, tetapi juga dirender di server untuk SEO.
1.  **Request Masuk:** User mengakses `domain.com/artikel/judul-A`.
2.  **Express Server (`server.ts`):** Menangkap request dan memanggil `entry-server.tsx`.
3.  **Data Fetching:** Server mengambil data artikel dari Supabase.
4.  **HTML Generation:** React merender komponen menjadi string HTML di server.
5.  **Response:** Server mengirimkan HTML lengkap ke browser (bagus untuk SEO).
6.  **Hydration:** Browser menerima HTML, lalu `entry-client.tsx` mengambil alih agar halaman menjadi interaktif (React Hydrate).

### B. Authentication Workflow (Hybrid)
Proyek ini menggunakan pendekatan hybrid:
1.  **Firebase:** Menangani pendaftaran dan login (Email/Password).
2.  **Supabase:** Menyimpan profil pengguna tambahan dan menangani Role-Based Access Control (RBAC).
3.  **Sync:** Saat user login, UID Firebase dicocokkan dengan tabel `profiles` di Supabase untuk menentukan apakah user adalah `Writer` atau `Admin`.

### C. Article Lifecycle (Data Flow)
1.  **Drafting:** Penulis menulis artikel di `BecomeWriterPage` atau Dashboard menggunakan Markdown Editor.
2.  **Media Upload:** Gambar diunggah ke Supabase Storage, URL disimpan di tabel `media`.
3.  **Submission:** Data artikel (judul, konten, SEO meta) disimpan ke tabel `articles` di Supabase.
4.  **Retrieval:** Halaman publik mengambil artikel berdasarkan `slug` untuk optimasi URL.

---

## 3. Panduan Navigasi Cepat

- **Ingin mengubah tampilan UI?** Cek `src/components` dan `src/index.css`.
- **Ingin menambah fitur database?** Tambahkan file baru di `supabase/migrations` dan update `src/lib/supabase.ts`.
- **Ingin memperbaiki SEO/SSR?** Cek `server.ts` dan `src/entry-server.tsx`.
- **Ingin mengubah flow login?** Cek `src/components/AuthProvider.tsx` dan `src/lib/firebase.ts`.

---

## 4. Tips Pemahaman
1.  **SQL First:** Sebelum coding fitur baru, lihat folder `supabase/migrations`. Struktur database adalah "kebenaran utama" (Source of Truth) di aplikasi ini.
2.  **Environment Variables:** Pastikan `.env` selalu lengkap, karena aplikasi akan gagal render di server jika URL database hilang.
3.  **Build Check:** Selalu jalankan `npm run build:ssr` sebelum deploy untuk memastikan tidak ada error pada sisi server rendering.

---
Dokumen ini dibuat untuk membantu mempercepat proses onboarding dan migrasi.
