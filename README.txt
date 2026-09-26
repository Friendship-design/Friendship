FRIENDSHIP EBENHAEZER V26

Perbaikan:
- Chat diperbaiki dan menampilkan detail error jika izin database belum aktif.
- Jumlah teman dihitung dari permintaan yang sudah accepted untuk pengguna yang sedang login.
- Foto profil dapat diganti dari Edit Profil.
- Banner profil dapat diganti dari Edit Profil.
- Foto profil tampil di area profil/composer.
- Fitur lain tetap dipertahankan.
- Tidak ada menu/teks Komunitas.

WAJIB dijalankan sekali di Supabase SQL Editor:
1. CHAT_RLS_FIX_V26.sql
2. PROFILE_CUSTOM_SQL.sql

Jika notifikasi V25 belum pernah dijalankan, jalankan juga:
3. NOTIFICATIONS_SQL.sql

Untuk media foto/video, MEDIA_SOCIAL_FIX.sql tetap boleh dijalankan jika sebelumnya belum pernah dijalankan.
