# LIN - Local Insight Network

LIN adalah platform pengelolaan konten artikel berbasis SEO yang dirancang untuk mendukung ekosistem penulis lokal dengan sistem otentikasi yang kuat dan performa tinggi menggunakan Server-Side Rendering (SSR).

## 🚀 Fitur Utama

- **SEO-Core Article System:** Pengelolaan artikel dengan metadata SEO lengkap, kategori, tag, dan media.
- **SSR (Server-Side Rendering):** Menggunakan Vite & Express untuk loading cepat dan optimasi SEO (Search Engine Indexing).
- **Writer Identity Registration:** Sistem pendaftaran khusus bagi penulis dengan verifikasi identitas.
- **RBAC (Role-Based Access Control):** Manajemen peran pengguna (Admin, Writer, Reader) menggunakan Supabase.
- **Media Management:** Integrasi Supabase Storage untuk penyimpanan aset gambar dan dokumen.
- **Markdown Support:** Editor artikel yang mendukung format Markdown untuk fleksibilitas konten.
- **Firebase Auth:** Sistem otentikasi yang aman dan handal.

## 🛠️ Tech Stack

- **Frontend:** React 18, TypeScript, Tailwind CSS, Lucide Icons, Framer Motion.
- **Framework & Build:** Vite, Express (SSR Engine).
- **Backend/Database:** Supabase (PostgreSQL), Firebase (Auth).
- **Lainnya:** MDX Remote, React Quill, PDF.js, Mammoth (Docx parser).

## 📂 Dokumentasi & Tutorial (Pusat Informasi)

Untuk memudahkan pemahaman dan pengelolaan proyek ini, silakan merujuk ke dokumen-dokumen berikut:

### 1. [Panduan Migrasi & Setup Server](MIGRATION_GUIDE.md)
*Panduan teknis langkah-demi-langkah untuk melakukan setup aplikasi di server produksi (VPS/Dedicated).*
- Persyaratan sistem (Node.js, Postgres).
- Konfigurasi environment.
- Langkah deployment SSR.

### 2. [Struktur Proyek & Workflow](STRUCTURE.md)
*Penjelasan mendalam tentang arsitektur kode dan alur kerja teknis.*
- Peta direktori.
- Alur kerja SSR (Server-Side Rendering).
- Workflow autentikasi hybrid & lifecycle data artikel.

### 3. [Checklist Deployment](CHECKLIST.md)
*Daftar centang khusus untuk System Administrator agar tidak ada langkah yang terlewat saat "Go Live".*
- Verifikasi database & RLS.
- Konfigurasi Nginx & SSL.
- Manajemen proses PM2.

### 4. [Instruksi AI Agent](AGENTS.md)
*Panduan khusus jika Anda menggunakan AI (Cursor, Claude, Windsurf) untuk membantu coding.*
- Aturan keselamatan SSR (Anti-crash).
- Protokol database SQL-First.
- Tips troubleshooting error umum.

## 🏃 Memulai (Getting Started)

### Prasyarat
- Node.js versi 18.x atau lebih baru.
- Akun Supabase & Firebase.

### Instalasi
1. Clone repository ini.
2. Install dependensi:
   ```bash
   npm install
   ```
3. Salin file `.env.example` ke `.env` (atau `.env.local` untuk dev):
   ```bash
   cp .env.example .env
   ```
4. Isi variabel lingkungan sesuai panduan di [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md).

### Menjalankan di Mode Pengembangan (Development)
- **Standard Vite Dev:**
  ```bash
  npm run dev
  ```
- **SSR Mode Dev:**
  ```bash
  npm run dev:ssr
  ```

### Build & Produksi
1. Jalankan build untuk client dan server:
   ```bash
   npm run build:ssr
   ```
2. Jalankan server produksi:
   ```bash
   npm run serve
   ```

## 📂 Struktur Utama
- `src/components`: Komponen UI yang reusable.
- `src/lib`: Konfigurasi library (Supabase, Firebase, SSR Utils).
- `src/pages`: Halaman utama aplikasi.
- `supabase/migrations`: File SQL untuk skema database.
- `server.ts`: Entry point untuk Express SSR server.

---
Developed with ❤️ by the LIN Team.
