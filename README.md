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
4. Isi variabel lingkungan berikut:
   ```env
   VITE_SUPABASE_URL=your_supabase_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   VITE_FIREBASE_CONFIG={"apiKey":"...","authDomain":"..."}
   ```

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

## 📂 Struktur Proyek
- `src/components`: Komponen UI yang reusable.
- `src/lib`: Konfigurasi library (Supabase, Firebase, SSR Utils).
- `src/pages`: Halaman utama aplikasi.
- `supabase/migrations`: File SQL untuk skema database.
- `server.ts`: Entry point untuk Express SSR server.

## 📖 Dokumentasi Terkait
- [Panduan Migrasi & Setup Server](MIGRATION_GUIDE.md)
- [Requirement Phase 1 (SEO System)](.kiro/specs/phase1-seo-core-article-system/requirements.md)

---
Developed with ❤️ by the LIN Team.
