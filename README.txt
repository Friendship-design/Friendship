Friendship Ebenhaezer V28

PENTING: jalankan FIX_ALL_V28.sql SEKALI di Supabase SQL Editor.
Setelah itu upload SEMUA isi folder ini langsung ke root repository GitHub Pages.
Logout lalu login kembali setelah update.

Perbaikan utama V28:
- memperbaiki error notifications.actor_id yang menyebabkan LIKE, CHAT, komentar, dan permintaan teman gagal
- memastikan actor_id ditambahkan walaupun tabel notifications sudah pernah dibuat sebelumnya
- memperbaiki penyimpanan foto profil dan banner
- memperbaiki penyimpanan foto posting dan Reels
- mencegah tombol Bagikan terkirim/terbuka dua kali
- mempertahankan fitur lain dari V27
