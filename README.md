UTS Game Development — 3D Collectible & Speed Boost (Godot 4)
Proyek praktik UTS mata kuliah Game Development menggunakan Godot Engine 4.x dan GDScript.
Identitas Mahasiswa
Nama: Ageng Wahyu Margiono
Program Studi: Informatika
Varian Soal: NIM Akhiran 3 (Collectible Speed Boost, HUD Timer, SFX Audio Bus & Real-Time Volume Control)
Fitur Utama Implementasi
Kontrol Karakter 3D (player.gd):
Pergerakan 3D berbasis CharacterBody3D (W/A/S/D), lompatan (Space), serta rotasi kamera mouse mulus dengan SpringArm3D.
Mekanisme Speed Boost +20% selama 5 detik (
pply_speed_boost) yang memancarkan sinyal Boost_changed secara real-time ke antarmuka pengguna.
Collectible Kristal Biru (Blue_crystal.gd):
Menggunakan Area3D dengan sinyal body_entered untuk mendeteksi pemain, memberikan efek speed boost, menyembunyikan mesh, menonaktifkan collider sementara (set_deferred), dan respawn otomatis setelah 6 detik.
Menghasilkan efek suara denting arpeggio kristal secara prosedural via AudioStreamGenerator yang diarahkan khusus ke bus audio SFX.
Antarmuka Pengguna & Pengaturan Audio (hud.gd):
Indikator Speed Boost: Menampilkan ProgressBar dan sisa waktu hitung mundur (Speed Boost (+20%): Xs) di pojok kiri atas yang responsif terhadap perubahan ukuran jendela (Stretch Mode: canvas_items, Aspect: expand).
Panel Pengaturan Audio (Tab): Membuka/menutup panel pengaturan di tengah layar sekaligus menjeda pergerakan kamera agar slider mudah diatur.
Slider Volume SFX (0%–100%, kelipatan 5%): Mengatur volume bus SFX secara real-time menggunakan kurva desibel perseptual (-60 dB hingga   dB).
Pintasan Cepat Mute (M): Membisukan (mute) atau mengaktifkan kembali (unmute) bus SFX seketika.
Cara Menjalankan Proyek
Buka Godot Engine 4.x (versi 4.3 atau lebih baru).
Klik Import, arahkan ke folder proyek ini, dan pilih file project.godot.
Tekan F5 untuk menjalankan main scene (world.tscn).
Kontrol Permainan
Tombol	Fungsi
W A S D	Bergerak maju, kiri, mundur, kanan
Mouse	Mengarahkan sudut pandang kamera
Space	Melompat
Tab	Membuka / menutup Panel Pengaturan Audio (jeda kamera)
M	Mute / Unmute cepat audio bus SFX
