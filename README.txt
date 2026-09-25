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

V17: Chat pribadi aktif: cari pengguna, buka percakapan, kirim pesan, dan lihat riwayat. Jalankan CHAT_RLS_FIX.sql sekali di SQL Editor.

V18: upload Foto dan Reels online melalui penyimpanan media, plus perbaikan izin posting, Suka, dan Komentar. Jalankan MEDIA_SOCIAL_FIX.sql sekali di SQL Editor.

V19: Chat dibuat selalu terlihat melalui tombol Chat/floating button dan bagian Chat lengkap. Cari pengguna, buka percakapan, kirim pesan, dan lihat riwayat. Jalankan CHAT_RLS_FIX.sql dari V17 sekali.

FITUR TAMBAH TEMAN DAN CHAT
1. Jalankan FRIEND_REQUESTS_SQL.sql sekali di Supabase SQL Editor.
2. CHAT_RLS_FIX.sql tetap harus sudah dijalankan untuk chat.
3. Setelah itu upload semua file ZIP ini ke GitHub Pages.
4. Di menu Teman, pengguna dapat mencari pengguna lain, Tambah Teman, Terima/Tolak permintaan, atau langsung Chat.
