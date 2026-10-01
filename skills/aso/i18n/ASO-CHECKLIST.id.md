# Checklist ASO — Apple App Store & Google Play

Checklist App Store Optimization untuk pembuat aplikasi dan agen AI. Diperbarui **2026-10-01**.
Bagian dari [skill `aso`](https://github.com/shipflutter/skills/tree/develop/skills/aso) oleh [ShipFlutter](https://shipflutter.app) · MIT.

> Ini adalah terjemahan. Versi asli bahasa Inggris menjadi acuan, dan ID item sama di semua bahasa: <https://github.com/shipflutter/skills/blob/develop/skills/aso/ASO-CHECKLIST.md>

- Lihat: <https://github.com/shipflutter/skills/blob/develop/skills/aso/i18n/ASO-CHECKLIST.id.md>
- Raw (untuk agen): <https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/i18n/ASO-CHECKLIST.id.md>
- Instal skill lengkap: `npx skills add shipflutter/skills --skill aso`

---

## Jika Anda agen AI, baca ini dulu

1. **Mode bawaan adalah audit.** Baca listing, tandai setiap item di bawah, lalu laporkan. Ubah file
   hanya jika pengguna meminta perbaikan. **Jangan pernah mengunggah ke App Store Connect / Play Console
   atau mengirim untuk ditinjau** kecuali pengguna memintanya dalam percakapan ini.
2. **Temukan listing.** fastlane: `fastlane/metadata/ios/<locale>/*.txt` (atau
   `fastlane/metadata/<locale>/`) dan `fastlane/metadata/android/<locale>/*.txt`. Jika tidak ada, minta
   pengguna menempelkan nama / subjudul / kata kunci / deskripsi per bahasa, atau judul / deskripsi
   singkat / deskripsi lengkap Play.
3. **Hitung dengan kode, jangan dikira-kira.** Item bertanda **(auto)** diperiksa oleh skrip gratis:
   ```bash
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/aso_check.py
   python3 aso_check.py --root .            # markdown report; exit 1 on errors
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/keyword_suggest.py
   python3 keyword_suggest.py "habit tracker" --az --country us --competition
   ```
   (Python 3.10+, hanya pustaka standar, tanpa kunci API.)
4. **Tandai setiap item** `✅ pass` (lolos) / `⚠️ improve` (perlu ditingkatkan) / `❌ fail` (gagal) / `N/A`,
   dengan bukti (file, jumlah, kutipan). Setiap ⚠️/❌ wajib disertai perbaikan konkret yang muat dalam
   batas. Gunakan template laporan di bagian akhir.
5. **Jangan mengarang data.** Jangan cantumkan volume pencarian, peringkat, atau rating yang tidak Anda ukur.
   Tulis "belum diukur" sebagai gantinya. Fakta bertanda UNCONFIRMED (belum dikonfirmasi) adalah pengamatan vendor, bukan aturan store.

---

## Batas sekilas

| Store | Kolom | Batas | Diindeks untuk pencarian |
|---|---|---|---|
| App Store | Nama aplikasi | 30 | ✅ paling kuat |
| App Store | Subjudul | 30 | ✅ |
| App Store | Kolom kata kunci (tersembunyi) | 100 | ✅ |
| App Store | Teks promosi | 170 | ❌ (bisa diubah tanpa peninjauan) |
| App Store | Deskripsi | 4000 | ❌ untuk pencarian App Store |
| App Store | Yang Baru (What's New) | 4000 | ❌ |
| App Store | Event dalam aplikasi (in-app events): nama / singkat / panjang | 30 / 50 / 120 | ✅ nama event |
| App Store | Nama tampilan / deskripsi IAP | 30 / 45 | ✅ IAP yang dipromosikan |
| Google Play | Judul | 30 | ✅ paling kuat |
| Google Play | Deskripsi singkat | 80 | ✅ |
| Google Play | Deskripsi lengkap | 4000 | ✅ (tidak ada kolom kata kunci tersembunyi) |
| Google Play | Catatan rilis (What's new) | 500 | ❌ |

Dokumentasi Apple menyebut batas kolom kata kunci "100 bytes", tetapi App Store Connect menghitung karakter
(kolom bahasa Jepang berisi 100 karakter / 220 byte diterima pada 2026-10-01).

---

## 0. Sebelum mulai

- [ ] **PRE-01** Tulis 3 **tugas** inti aplikasi dengan kata-kata pengguna ("bagi tagihan dengan teman"), target penggunanya, dan 5 pesaing teratasnya.
- [ ] **PRE-02** Pilih pasar prioritas: storefront / negara + bahasa, diurutkan menurut jumlah instal saat ini atau target pengguna.
- [ ] **PRE-03** Listing disimpan di version control (metadata fastlane `deliver` / `supply`), sehingga setiap perubahan bisa dilihat diff-nya.
- [ ] **PRE-04** Baseline dicatat **sebelum** ada perubahan: impresi pencarian, tayangan halaman produk, tingkat konversi, unduhan per sumber, rating dan jumlahnya, per negara prioritas (lihat bagian 10).
- [ ] **PRE-05** Ada log perubahan (mis. `docs/aso-log.md`): tanggal, kolom yang diubah, sebelum → sesudah, metrik yang dicek, tanggal tindak lanjut.

## 1. Riset kata kunci

- [ ] **KW-01** 5–10 kata kunci awal (seed) dari tugas aplikasi dan kata benda kategori — bukan merek, bukan hanya fitur.
- [ ] **KW-02** Diperluas dengan **autocomplete** milik masing-masing store, per pasar dan bahasa (long-tail a–z). Urutan saran = sinyal popularitas.
- [ ] **KW-03** Judul / subjudul 10 pesaing teratas dibaca untuk setiap kata kunci utama (head term); kata yang sama-sama mereka pakai dicatat. Jangan pernah memakai nama merek mereka.
- [ ] **KW-04** **Ulasan** aplikasi sendiri dan pesaing digali untuk menemukan kata benda dan kata kerja yang dipakai pengguna.
- [ ] **KW-05** Setiap kandidat diberi skor: relevansi (0–3, buang jika < 2), popularitas (posisi di autocomplete atau popularitas di Apple Ads), keterbukaan / kesulitan (berapa banyak aplikasi di 10 teratas yang menargetkannya, dan seberapa kuat mereka).
- [ ] **KW-06** Aplikasi baru atau kecil menargetkan long-tail yang bisa dimenangkan (3–4 kata, popularitas sedang, keterbukaan tinggi) sebelum kata kunci utama.
- [ ] **KW-07** Ada **peta kata kunci** per bahasa: istilah mana yang dipegang nama / judul, subjudul / deskripsi singkat, dan kolom kata kunci / deskripsi lengkap. Tidak ada istilah tanpa tempat, tidak ada tempat tanpa istilah.
- [ ] **KW-08** Istilah yang sudah berperingkat 11–50 diidentifikasi — ini kemenangan paling murah.
- [ ] **KW-09** Riset diulang **per pasar** — kata kunci diriset dalam bahasa lokal, bukan diterjemahkan dari bahasa Inggris.

## 2. Metadata App Store (per bahasa)

- [ ] **AS-01** (auto) Nama ≤ 30, subjudul ≤ 30, kolom kata kunci ≤ 100, teks promosi ≤ 170, deskripsi ≤ 4000.
- [ ] **AS-02** (auto) Nama, subjudul, dan kolom kata kunci masing-masing terisi ≥ 90% — karakter yang tidak terpakai berarti peringkat yang hilang.
- [ ] **AS-03** Nama = merek + istilah dengan prioritas tertinggi, tetap enak dibaca ("Merek: Pelacak Kebiasaan").
- [ ] **AS-04** (auto) Subjudul menambahkan kata **baru** — tidak ada yang mengulang kata dari nama.
- [ ] **AS-05** (auto) Kolom kata kunci: dipisah koma, **tanpa spasi setelah koma**, tanpa koma di akhir.
- [ ] **AS-06** (auto) Kolom kata kunci tidak berisi kata yang sudah ada di nama atau subjudul, dan tanpa duplikat.
- [ ] **AS-07** (auto) Bentuk tunggal **atau** jamak, jangan keduanya.
- [ ] **AS-08** (auto) Tanpa kata mubazir: "app", "apps" ("aplikasi"), "free" ("gratis"), "iPhone", "iPad", "iOS", "Apple", nama merek / perusahaan; (manual) nama kategori.
- [ ] **AS-09** (auto, warning) Utamakan kata lepas daripada frasa — Apple menggabungkan kata dari nama + subjudul + kolom kata kunci dalam bahasa yang sama.
- [ ] **AS-10** Tanpa nama pesaing, merek dagang, atau nama selebritas di mana pun (Pedoman 2.3.7, 5.2.1).
- [ ] **AS-11** (auto) Tanpa kata harga / peringkat / ajakan bertindak di nama, subjudul, kata kunci: "free", "best", "#1", "sale", "% off" (2.3.7), dalam bahasa apa pun ("gratis", "terbaik", "diskon"…).
- [ ] **AS-12** (auto) Tanpa emoji; tanpa merek dagang Apple yang dipakai seolah bagian dari nama Anda (iPhone, Siri…).
- [ ] **AS-13** **Kategori utama** adalah yang paling relevan (kategori ikut menentukan relevansi teks); kategori sekunder diisi.
- [ ] **AS-14** Deskripsi: 3 baris pertama menyebut tugas utama dan buktinya; poin-poin mudah dipindai; tidak dipakai untuk kata kunci (tidak diindeks untuk pencarian App Store), tetapi dibaca oleh pencarian web Google dan generator tag Apple.
- [ ] **AS-15** Teks promosi dipakai untuk berita / penawaran terkini (bisa diubah tanpa peninjauan).
- [ ] **AS-16** (auto) URL kebijakan privasi dan URL dukungan memakai https; (manual) keduanya bisa dibuka.
- [ ] **AS-17** Nama tampilan pembelian dalam aplikasi menjelaskan apa yang didapat pengguna, dengan istilah pencarian jika terasa alami ("Pelacak Kebiasaan Pro").
- [ ] **AS-18** Event dalam aplikasi (jika ada): kata kunci dimasukkan ke nama event (30 karakter); paling banyak 10 event terpublikasi sekaligus.
- [ ] **AS-19** **Tag aplikasi (App tags)** (storefront US, metadata en-US): ditinjau di App Store Connect; tag yang salah dibatalkan pilihannya (Anda tidak bisa menambah tag — jadi tulis kasus penggunaan dengan gamblang di deskripsi en-US).
- [ ] **AS-20** Kuesioner rating usia dijawab sesuai tingkatan 2025 (4+ / 9+ / 13+ / 16+ / 18+).

## 3. Metadata Google Play (per bahasa)

- [ ] **GP-01** (auto) Judul ≤ 30, deskripsi singkat ≤ 80, deskripsi lengkap ≤ 4000, catatan rilis ≤ 500.
- [ ] **GP-02** (auto) Judul dan deskripsi singkat terisi ≥ 90%.
- [ ] **GP-03** Judul = merek + kata kunci utama; deskripsi singkat = satu kalimat utuh berisi 2–3 istilah sekunder dan manfaat utama.
- [ ] **GP-04** (auto) Kata kunci dari judul muncul di deskripsi lengkap, termasuk dalam ~300 karakter pertamanya.
- [ ] **GP-05** Setiap istilah target muncul 2–3 kali secara alami di deskripsi lengkap; istilah terkait dan sinonim dipakai; tanpa daftar kata kunci.
- [ ] **GP-06** (auto) Tidak ada kata dengan kepadatan di atas ~3% (penjejalan kata kunci melanggar kebijakan).
- [ ] **GP-07** (auto) Judul / deskripsi singkat / nama developer: tanpa emoji, tanpa karakter khusus berulang (`!!!`, `★★`), tanpa HURUF KAPITAL SEMUA (kecuali memang merek).
- [ ] **GP-08** (auto) Tanpa "Free", "#1", "Best", "Top", "Popular", "New", "Editor's choice", "No ads" ("Gratis", "Terbaik", "Populer", "Baru", "Tanpa iklan"), harga, atau promosi di judul, ikon, atau nama developer — di setiap terjemahan.
- [ ] **GP-09** Tidak ada testimoni tanpa atribusi atau kutipan pengguna anonim di deskripsi.
- [ ] **GP-10** Deskripsi lengkap terstruktur: pembuka (2 baris) → fitur utama dengan heading / poin → bukti → ajakan bertindak; pakai kalimat sederhana yang bisa dikutip LLM ("Gunakan X untuk …"), karena Ask Play / sorotan AI membacanya.
- [ ] **GP-11** Kategori dan maksimal 5 **tag** diisi (di Store settings).
- [ ] **GP-12** Email kontak, situs web, dan kebijakan privasi diisi; situs web juga menjelaskan aplikasinya (Ask Play ikut membacanya).
- [ ] **GP-13** Formulir Keamanan Data (Data safety) lengkap dan sesuai dengan perilaku aplikasi.

## 4. Lokalisasi

- [ ] **L10N-01** Setiap pasar prioritas punya listing sendiri — bukan terjemahan otomatis Play, bukan bahasa Inggris.
- [ ] **L10N-02** (auto) Kolom kata kunci / deskripsi singkat **tidak disalin** dari bahasa dasar.
- [ ] **L10N-03** Istilah pencarian lokal diambil dari autocomplete lokal dan pesaing lokal (KW-09).
- [ ] **L10N-04** **Lokalisasi silang** (cross-localization) App Store: untuk setiap storefront prioritas, daftarkan bahasa tambahan yang diindeks Apple di sana (US: en-US + es-MX, ar, zh-Hans, zh-Hant, fr-FR, ko, pt-BR, ru, vi; UK: en-GB; CA: en-CA + fr-CA; JP: ja + en-US; sebagian besar lainnya: bahasa setempat + en-GB) dan isi kolom kata kunci setiap bahasa dengan kata yang **berbeda**.
- [ ] **L10N-05** Bahasa yang dipakai untuk lokalisasi silang tetap terbaca benar bagi penutur asli bahasa itu (pengguna sungguhan melihatnya).
- [ ] **L10N-06** (auto) Listing CJK / Thailand / Arab juga diisi sampai batas — kolom yang diisi terlalu pendek di bahasa-bahasa ini adalah pemborosan yang paling sering terjadi.
- [ ] **L10N-07** Screenshot dan keterangannya dilokalkan untuk bahasa prioritas; tata letak kanan-ke-kiri untuk Arab / Ibrani.
- [ ] **L10N-08** Kata klaim dicek dalam bahasa lokal ("miễn phí", "gratis", "無料", "무료", "免费"…).

## 5. Ikon, screenshot, video

- [ ] **CR-01** Ikon: satu simbol jelas, tanpa tulisan, terbaca pada 40 px, dan tetap beda saat dijejerkan dengan ikon 10 pesaing teratas.
- [ ] **CR-02** iOS 26: ikon Liquid Glass berlapis dicek dalam mode terang, gelap, berwarna (tinted), dan bening (clear).
- [ ] **CR-03** (auto, Play) Ikon PNG 512×512; grafis fitur (feature graphic) 1024×500 tanpa alpha, tanpa klaim peringkat / harga / penghargaan.
- [ ] **CR-04** Screenshot 1 menunjukkan **tugas utama** dengan kata kunci utama dalam keterangan ≤ 5 kata; harus bisa berdiri sendiri di hasil pencarian.
- [ ] **CR-05** Screenshot 2–3 menunjukkan dua alasan berikutnya untuk menginstal; satu manfaat per screenshot.
- [ ] **CR-06** UI aplikasi yang asli (App Store 2.3.3); keterangan di Play ≤ 20% dari gambar; tanpa "Download now", "#1", "Best", atau lencana store.
- [ ] **CR-07** App Store: set iPhone 6.9" (1320×2868 / 1290×2796 / 1260×2736) dan set iPad 13" (2064×2752 / 2048×2732) jika aplikasi berjalan di iPad; maksimal 10 per set; tanpa alpha.
- [ ] **CR-08** (auto) Play: 2–8 screenshot ponsel, sisi 320–3840 px, sisi panjang ≤ 2× sisi pendek; ≥ 4 screenshot dengan ≥ 1080 px (9:16 atau 16:9) agar memenuhi syarat untuk ditampilkan sebagai unggulan (featuring); set tablet / Chromebook / Wear jika didukung (ditampilkan per jenis perangkat).
- [ ] **CR-09** Video (opsional, uji dulu): pratinjau App Store 15–30 detik, hanya rekaman layar, 3 detik pertama menunjukkan tugas utama tanpa suara; link YouTube di Play berstatus publik / unlisted, iklan dimatikan, 30 detik pertama paling menentukan.
- [ ] **CR-10** Materi visual selaras dengan peta kata kunci: yang dicari orang adalah yang ditunjukkan screenshot 1.

## 6. Halaman kustom & eksperimen

- [ ] **EXP-01** **Halaman produk kustom (custom product pages)** App Store (maksimal 70) untuk intent pencarian teratas, masing-masing diberi kata kunci dari kolom kata kunci yang sudah disetujui.
- [ ] **EXP-02** **Listing store kustom (custom store listings)** Google Play (maksimal 50) untuk kata kunci pencarian bernilai tinggi / negara / pengguna yang sudah berhenti (churned).
- [ ] **EXP-03** Selalu ada satu eksperimen berjalan di pasar teratas: optimasi halaman produk (product page optimization) App Store (≤ 3 treatment, ≤ 90 hari) atau eksperimen listing store (store listing experiments) Play (≤ 2 varian; judul dan video tidak bisa diuji).
- [ ] **EXP-04** Setiap uji: satu variabel, hipotesis tertulis, metrik keberhasilan, ≥ 7 hari, baru dihentikan setelah tingkat keyakinan (confidence) di konsol tercapai.
- [ ] **EXP-05** Urutan uji menurut perkiraan kenaikan: ikon → screenshot 1 → keterangan → urutan screenshot → video.
- [ ] **EXP-06** Hasil dicatat (menang / kalah / datar), dan pemenangnya diterapkan ke bahasa lain sebagai uji baru, bukan sebagai asumsi.

## 7. Rating & ulasan

- [ ] **RV-01** Prompt ulasan bawaan dalam aplikasi (`requestReview` / Play In-App Review API) setelah momen sukses; jangan saat aplikasi baru dibuka, setelah error, atau dengan penyaringan (gating); tanpa insentif.
- [ ] **RV-02** Rating rata-rata ≥ 4.0 di setiap negara prioritas (Play menghitung rating per negara dan jenis perangkat, dan rating terbaru berbobot lebih besar).
- [ ] **RV-03** Ulasan 1–3★ dibalas dalam beberapa hari, secara spesifik; balas lagi saat perbaikannya dirilis.
- [ ] **RV-04** Keluhan berulang teratas sudah diketahui dan masuk roadmap — ringkasan ulasan AI di kedua store menampilkannya sebagai sorotan utama.
- [ ] **RV-05** Teks ulasan digali setiap bulan untuk mencari kata kunci baru dan permintaan fitur.

## 8. Sinyal kualitas & teknis

- [ ] **Q-01** Android vitals di Play di bawah ambang perilaku buruk (28 hari): tingkat crash yang dirasakan pengguna < 1.09%, ANR < 0.47%, per model ponsel < 8%; partial wake lock berlebihan < 5% sesi.
- [ ] **Q-02** Ambang memori / bitmap / DEX di Play sudah direncanakan sebelum mulai ditegakkan pada Februari 2027.
- [ ] **Q-03** Play: target API 36 untuk aplikasi baru / update (sejak 2026-08-31); Apple: build memakai SDK Xcode 26 (sejak 2026-04-28).
- [ ] **Q-04** Aplikasi diperbarui setidaknya setiap 1–3 bulan; Yang Baru menjelaskan perubahan nyata (2.3.12).
- [ ] **Q-05** Ukuran unduhan dijaga kecil; tidak crash saat pertama dibuka, dan tidak ada layar wajib login sebelum pengguna merasakan manfaat.
- [ ] **Q-06** Label privasi (privacy nutrition label) / Keamanan Data dan (opsional, App Store) Label Nutrisi Aksesibilitas (Accessibility Nutrition Labels) sudah dideklarasikan.

## 9. Kebijakan — cek penolakan & penghapusan

- [ ] **POL-01** Tanpa klaim menyesatkan, ulasan palsu, "#1" / "best" yang tidak bisa diverifikasi, atau harga di nama / judul (App Store 2.3.1, 2.3.7; kebijakan metadata Play).
- [ ] **POL-02** Tanpa nama platform lain di metadata App Store ("Android", "Google Play") (2.3.10).
- [ ] **POL-03** Tanpa merek dagang pihak ketiga atau nama tiruan (5.2.1; kebijakan peniruan identitas Play).
- [ ] **POL-04** "For Kids" / "For Children" ("Untuk Anak") hanya di kategori Kids (2.3.8).
- [ ] **POL-05** Screenshot / pratinjau: menampilkan aplikasi yang sedang dipakai, bukan sekadar splash atau login (2.3.3, 2.3.4).
- [ ] **POL-06** Setiap terjemahan mengikuti aturan yang sama (Play menerapkan kebijakan per bahasa).

## 10. Ukur & iterasi

- [ ] **M-01** App Store Connect → Analytics: impresi App Store Search, tayangan halaman produk, konversi, unduhan — per negara dan per halaman produk kustom.
- [ ] **M-02** Play Console → Grow overview / Statistics: akuisisi menurut **istilah pencarian** dan sumber traffic (Store analysis dihentikan pada Juni 2026; metrik listing beralih ke klik pengguna unik pada Juli 2026 — jangan bandingkan data sebelum dan sesudah tanggal itu).
- [ ] **M-03** Peringkat kata kunci dilacak untuk peta kata kunci (rank tracker, laporan istilah pencarian Apple Ads, atau cek ulang autocomplete setiap bulan).
- [ ] **M-04** Hanya satu kelompok kolom yang diubah dalam satu waktu; tunggu 2–4 minggu sebelum menilai; nama / subjudul / kata kunci App Store hanya bisa berubah bersama versi baru.
- [ ] **M-05** Setiap bulan: buang kata di kolom kata kunci yang tidak mendapat impresi setelah 4–6 minggu, tambahkan kandidat berikutnya, cek ulang pesaing dan musim.

---

## Template laporan

```markdown
# Audit ASO — <Aplikasi> — <tanggal>

Store: <App Store / Google Play> · Bahasa: <daftar> · Mode: <audit / perbaikan>

## Skor
<lolos>/<total> item · <n> ❌ · <n> ⚠️ · skrip: <baris skor aso_check>

## Tabel kolom
| Store | Bahasa | Nama/Judul | Subjudul/Singkat | Kata kunci | Deskripsi |
|---|---|---|---|---|---|
| App Store | en-US | 28/30 ✅ | 30/30 ✅ | 97/100 ✅ | 3120/4000 ✅ |

## Masalah (dampak terbesar dulu)
| ID | Status | Store · bahasa · file | Bukti | Perbaikan (muat dalam batas) |
|---|---|---|---|---|
| AS-06 | ❌ | App Store · en-US · keywords.txt | "tracker" juga ada di nama | ganti dengan "routine" (+7 karakter) |

## Peta kata kunci (per bahasa prioritas)
| Istilah | Relevansi | Posisi autocomplete | Keterbukaan | Kolom |

## 3 tindakan berikutnya
1. …
```

## Sumber

- Apple: [Pencarian](https://developer.apple.com/app-store/search/) ·
  [Informasi versi platform](https://developer.apple.com/help/app-store-connect/reference/platform-version-information) ·
  [Lokalisasi App Store](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) ·
  [Pedoman Peninjauan](https://developer.apple.com/app-store/review/guidelines/) ·
  [Spesifikasi screenshot](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/) ·
  [Halaman produk kustom](https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions/) ·
  [Tag aplikasi](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags)
- Google: [Praktik terbaik listing store](https://support.google.com/googleplay/android-developer/answer/13393723) ·
  [Kebijakan metadata](https://support.google.com/googleplay/android-developer/answer/9898842) ·
  [Aset pratinjau](https://support.google.com/googleplay/android-developer/answer/9866151) ·
  [Listing store kustom](https://support.google.com/googleplay/android-developer/answer/9867158) ·
  [Eksperimen listing store](https://support.google.com/googleplay/android-developer/answer/6227309) ·
  [Android vitals](https://developer.android.com/topic/performance/vitals) ·
  [Yang baru di Play](https://google.play/business/whats-new/)
- Detail dan tanggal per store: [`references/app-store.md`](../references/app-store.md),
  [`references/google-play.md`](../references/google-play.md),
  [`references/conversion.md`](../references/conversion.md),
  [`references/keyword-research.md`](../references/keyword-research.md),
  [`references/tools.md`](../references/tools.md).
