# Deployment Checklist (Untuk System Administrator)

File ini berisi daftar tugas kritis yang harus diselesaikan untuk memastikan aplikasi **LIN** berjalan dengan sukses di server produksi.

## 1. Environment & Configuration
- [ ] **Node.js:** Pastikan versi minimal 18.x sudah terinstall.
- [ ] **.env File:** Salin `.env.example` ke `.env` dan pastikan variabel berikut terisi:
  - `VITE_SUPABASE_URL`
  - `VITE_SUPABASE_ANON_KEY`
  - `VITE_FIREBASE_CONFIG` (String JSON lengkap)
  - `SITE_URL` (Domain asli, misal: https://linda.com)
  - `PORT` (Default: 3000)

## 2. Database Migration (Supabase)
- [ ] **Migrations:** Jalankan semua file SQL di `/supabase/migrations/` ke database target.
- [ ] **Roles:** Pastikan trigger `handle_new_user` aktif agar RBAC (admin/writer/user) berfungsi otomatis saat signup.
- [ ] **Seed Data:** Jalankan `/supabase/seed.sql` jika kategori atau data awal diperlukan.

## 3. Build Process
- [ ] **Install Deps:** Jalankan `npm install`.
- [ ] **SSR Build:** Jalankan `npm run build:ssr`. 
  - *Note: Pastikan folder `dist/client` dan `dist/server` sudah tercipta.*

## 4. Process Management (PM2)
- [ ] **Run Application:** Gunakan PM2 untuk menjaga uptime.
  ```bash
  pm2 start server.ts --name "lin-app" --interpreter ./node_modules/.bin/tsx
  ```
- [ ] **Startup Script:** Jalankan `pm2 save` dan `pm2 startup` agar aplikasi otomatis jalan setelah server reboot.

## 5. Reverse Proxy & Security
- [ ] **Nginx Config:** Pastikan proxy pass mengarah ke port aplikasi (3000).
- [ ] **SSL (HTTPS):** Wajib menggunakan SSL (Certbot/LetsEncrypt). Tanpa HTTPS, fitur Auth Supabase/Firebase mungkin gagal.
- [ ] **Firebase Authorized Domains:** Daftarkan domain produksi di Firebase Console > Authentication > Settings > Authorized Domains.

## 6. Verification (Post-Deploy)
- [ ] Cek status 200 di halaman utama.
- [ ] Cek status 404 di URL sembarang.
- [ ] Cek akses sitemap: `/sitemap.xml`.
- [ ] Cek akses Google News sitemap: `/news-sitemap.xml`.

---
**PENTING:** Jika ada error "Window is not defined" saat build, pastikan semua library pihak ketiga yang mengakses browser API di-load secara dinamis (lazy load) di sisi client saja.
