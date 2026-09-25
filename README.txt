FRIENDSHIP EBENHAEZER — V12 FIX UPLOAD
1. Upload semua file ZIP langsung ke root GitHub Pages.
2. SEBELUM upload foto/video, jalankan SETUP_SQL.txt di Supabase SQL Editor.
3. Setelah SQL berhasil, login kembali lalu coba Status Foto dan Reels.
4. Foto/video akan masuk ke penyimpanan online dan URL-nya dicatat di posts.
5. Email tidak ditampilkan di profil.
6. Reels memakai tabel posts dengan media_type=video.

V13: nama pada setiap postingan diambil dari profil pengguna (full_name/username), bukan 'Anggota Friendship Ebenhaezer'. Tombol Suka, Komentar, dan Bagikan aktif. Suka dan komentar menggunakan tabel likes/comments; Bagikan menggunakan menu share HP atau menyalin tautan.

V14: Grup aktif dengan buat grup, gabung, anggota, posting grup, suka, komentar, dan bagikan. Jalankan GROUPS_SQL.txt di SQL Editor sebelum memakai fitur grup.

V15: memperbaiki kesalahan JavaScript V14 yang membuat tombol tidak merespons. Memperbaiki escape pada tombol Suka/Komentar/Grup dan karakter newline script. Overlay tersembunyi juga tidak lagi menghalangi sentuhan.

V16 memperbaiki pesan "new row violates row-level security policy" pada Suka dan Komentar.
WAJIB jalankan SOCIAL_RLS_FIX.sql di SQL Editor sebelum mencoba tombol Suka/Komentar lagi.
Tidak perlu mengubah pengaturan email untuk perbaikan ini.
