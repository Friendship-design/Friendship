# Friendship — Supabase Ready

Project ini sudah dikonfigurasi untuk Supabase project Friendship.

## GitHub Pages
Upload seluruh isi folder ini ke repository GitHub, lalu aktifkan GitHub Pages.

## Catatan
- Register/Login memakai Supabase Auth.
- Profil otomatis dibuat oleh trigger `on_auth_user_created` yang sudah dibuat di database.
- Feed membaca/menulis tabel `posts`.
- Publishable key boleh berada di frontend; jangan pernah memasukkan service_role/secret key.
