# Panduan Migrasi & Setup Server

Dokumen ini berisi persyaratan sistem dan langkah-langkah teknis untuk melakukan migrasi dan setup aplikasi ini ke server mandiri (self-hosted).

## 1. Persyaratan Sistem (Requirements)

### Perangkat Lunak (Software)
*   **Operating System:** Linux (Ubuntu 20.04/22.04 direkomendasikan).
*   **Node.js:** Versi 18.x atau lebih baru (LTS).
*   **Package Manager:** NPM (bawaan Node) atau Yarn.
*   **Database:** 
    *   **Supabase (Self-hosted atau Cloud):** Memerlukan instance PostgreSQL.
    *   **Firebase:** Akun Firebase aktif untuk Authentication dan Firestore (jika masih digunakan sebagai backup).
*   **Reverse Proxy:** Nginx atau Caddy (untuk SSL dan routing port 80/443).
*   **Process Manager:** PM2 (untuk menjaga aplikasi tetap berjalan di background).

### Spesifikasi Hardware (Minimum)
*   **CPU:** 1 Core.
*   **RAM:** 2 GB (Vite build proses membutuhkan RAM yang cukup).
*   **Storage:** 10 GB SSD.

---

## 2. Persiapan Lingkungan (Environment Setup)

### Step 1: Install Node.js & PM2
```bash
# Update sistem
sudo apt update && sudo apt upgrade -y

# Install Node.js (via NodeSource)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 secara global
sudo npm install pm2 -g
```

### Step 2: Konfigurasi Database (Supabase)
Aplikasi ini menggunakan Supabase. Jika Anda menggunakan Supabase Self-hosted:
1.  Pastikan Docker sudah terinstall.
2.  Jalankan stack Supabase lokal.
3.  Terapkan migrasi yang ada di folder `./supabase/migrations` ke database target:
    ```bash
    # Gunakan Supabase CLI
    supabase db push --db-url "postgresql://postgres:[PASSWORD]@[HOST]:[PORT]/postgres"
    ```

### Step 3: Konfigurasi Variabel Lingkungan (.env)
Salin file `.env.example` menjadi `.env` di root direktori server:
```bash
cp .env.example .env
```
Isi variabel berikut dengan data server Anda:
*   `VITE_SUPABASE_URL`: URL API Supabase Anda.
*   `VITE_SUPABASE_ANON_KEY`: Anon key untuk akses frontend.
*   `SUPABASE_SERVICE_ROLE_KEY`: Key admin (hanya untuk server-side).
*   `VITE_FIREBASE_CONFIG`: JSON string konfigurasi Firebase.

---

## 3. Deployment & Build

### Step 1: Install Dependensi
```bash
npm install
```

### Step 2: Build Aplikasi (SSR Mode)
Karena aplikasi ini mendukung SSR (Server-Side Rendering), proses build akan menghasilkan file untuk client dan server:
```bash
npm run build
```
Hasil build akan berada di folder `dist/`.

### Step 3: Menjalankan Aplikasi dengan PM2
Jalankan `server.ts` menggunakan PM2 (via `tsx` atau dikompilasi ke JS):
```bash
pm2 start server.ts --name "lin-app" --interpreter ./node_modules/.bin/tsx
```
Atau jika sudah dideploy dalam bentuk produksi yang matang:
```bash
pm2 start dist/server/entry-server.js --name "lin-app"
```

---

## 4. Konfigurasi Nginx (Reverse Proxy)

Buat file konfigurasi Nginx di `/etc/nginx/sites-available/lin-app`:

```nginx
server {
    listen 80;
    server_name domain-anda.com;

    location / {
        proxy_pass http://localhost:3000; # Sesuaikan dengan port di server.ts
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Aktifkan konfigurasi dan restart Nginx:
```bash
sudo ln -s /etc/nginx/sites-available/lin-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## 5. Maintenance & Log

*   **Cek status aplikasi:** `pm2 status`
*   **Lihat log error:** `pm2 logs lin-app`
*   **Restart aplikasi:** `pm2 restart lin-app`

---

**Catatan Migrasi Data:**
Jika Anda memindahkan data dari database lama, pastikan untuk menjalankan `seed.sql` (jika ada) setelah migrasi tabel selesai untuk memastikan data referensi (kategori, tag) tersedia.
