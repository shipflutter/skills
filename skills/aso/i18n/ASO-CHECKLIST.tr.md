# ASO Kontrol Listesi — Apple App Store ve Google Play

Uygulama geliştiricileri ve yapay zekâ ajanları için App Store Optimizasyonu (ASO) kontrol listesi. Son güncelleme: **2026-10-01**.
[ShipFlutter](https://shipflutter.app) tarafından hazırlanan [`aso` becerisinin](https://github.com/shipflutter/skills/tree/develop/skills/aso) parçasıdır · MIT.

> Bu bir çeviridir. Esas alınan metin İngilizce asıldır; madde ID'leri her dilde aynıdır: <https://github.com/shipflutter/skills/blob/develop/skills/aso/ASO-CHECKLIST.md>

- Görüntüle: <https://github.com/shipflutter/skills/blob/develop/skills/aso/i18n/ASO-CHECKLIST.tr.md>
- Ham metin (ajanlar için): <https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/i18n/ASO-CHECKLIST.tr.md>
- Becerinin tamamını kurun: `npx skills add shipflutter/skills --skill aso`

---

## Yapay zekâ ajanıysanız önce bunu okuyun

1. **Varsayılan mod denetimdir.** Mağaza sayfasını okuyun, aşağıdaki her maddeyi işaretleyin, rapor
   verin. Dosyaları yalnızca kullanıcı düzeltme istediyse düzenleyin. Kullanıcı bu konuşmada
   istemedikçe **App Store Connect / Play Console'a hiçbir şey yüklemeyin, incelemeye göndermeyin.**
2. **Mağaza sayfasını bulun.** fastlane: `fastlane/metadata/ios/<locale>/*.txt` (veya
   `fastlane/metadata/<locale>/`) ve `fastlane/metadata/android/<locale>/*.txt`. Bunlar yoksa
   kullanıcıdan her dil için adı / alt başlığı / anahtar kelimeleri / açıklamayı ya da Play
   başlığını / kısa / tam açıklamayı yapıştırmasını isteyin.
3. **Gözle değil, kodla sayın.** **(auto)** ile işaretli maddeleri ücretsiz betik kontrol eder:
   ```bash
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/aso_check.py
   python3 aso_check.py --root .            # markdown report; exit 1 on errors
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/keyword_suggest.py
   python3 keyword_suggest.py "habit tracker" --az --country us --competition
   ```
   (Python 3.10+, yalnızca standart kütüphane, API anahtarı gerekmez.)
4. **Her maddeyi işaretleyin:** `✅ pass` (geçti) / `⚠️ improve` (iyileştirilmeli) / `❌ fail` (kaldı) /
   `N/A` (geçerli değil); kanıtını da yazın (dosya, sayı, alıntı). Her ⚠️/❌ için sınıra sığan somut
   bir düzeltme önerin. Sondaki rapor şablonunu kullanın.
5. **Veri uydurmayın.** Ölçmediğiniz arama hacmi, sıralama veya puan yazmayın; bunun yerine "ölçülmedi"
   deyin. Aşağıda UNCONFIRMED (doğrulanmamış) diye işaretlenen bilgiler mağaza kuralı değil, araç
   sağlayıcılarının gözlemleridir.

---

## Sınırlar bir bakışta

| Mağaza | Alan | Sınır | Aramada dizinlenir mi |
|---|---|---|---|
| App Store | Uygulama adı | 30 | ✅ en güçlü |
| App Store | Alt başlık | 30 | ✅ |
| App Store | Anahtar kelime alanı (gizli) | 100 | ✅ |
| App Store | Tanıtım metni | 170 | ❌ (inceleme olmadan düzenlenebilir) |
| App Store | Açıklama | 4000 | ❌ App Store aramasında |
| App Store | Yenilikler | 4000 | ❌ |
| App Store | Uygulama içi etkinlik (in-app event): ad / kısa / uzun açıklama | 30 / 50 / 120 | ✅ etkinlik adı |
| App Store | Uygulama içi satın alım (IAP): görünen ad / açıklama | 30 / 45 | ✅ tanıtılan IAP'ler |
| Google Play | Başlık | 30 | ✅ en güçlü |
| Google Play | Kısa açıklama | 80 | ✅ |
| Google Play | Tam açıklama | 4000 | ✅ (gizli anahtar kelime alanı yok) |
| Google Play | Sürüm notları (What's new) | 500 | ❌ |

Apple'ın belgeleri anahtar kelime alanı için "100 bayt" der, ama App Store Connect karakter sayar
(100 karakterlik / 220 baytlık Japonca bir alan 2026-10-01'de kabul edildi).

---

## 0. Başlamadan önce

- [ ] **PRE-01** Uygulamanın kullanıcı için gördüğü 3 temel **işi** kullanıcıların kendi sözcükleriyle yazın ("arkadaşlarla hesabı bölüşmek"); hedef kitlesini ve en güçlü 5 rakibini de belirleyin.
- [ ] **PRE-02** Öncelikli pazarları seçin: ülke mağazası (storefront) / ülke + dil; mevcut yüklemelere veya hedef kullanıcılara göre sıralayın.
- [ ] **PRE-03** Mağaza sayfası sürüm kontrolünde tutuluyor (fastlane `deliver` / `supply` meta verileri); böylece her değişikliğin diff'i alınabilir.
- [ ] **PRE-04** Herhangi bir değişiklikten **önce** başlangıç değerleri kaydedildi: arama gösterimleri, ürün sayfası görüntülemeleri, dönüşüm oranı, kaynağa göre indirmeler, puan ve puan sayısı; her öncelikli ülke için ayrı (bkz. bölüm 10).
- [ ] **PRE-05** Bir değişiklik günlüğü var (ör. `docs/aso-log.md`): tarih, değişen alanlar, önce → sonra, izlenecek metrik, takip tarihi.

## 1. Anahtar kelime araştırması

- [ ] **KW-01** İşlerden ve kategori adlarından 5–10 çekirdek kelime çıkarın; marka adını değil, yalnızca özellikleri de değil.
- [ ] **KW-02** Liste her mağazanın kendi **otomatik tamamlama** önerileriyle, her pazar ve dil için genişletildi (a–z ile uzun kuyruk). Önerilerin sırası = popülerlik sinyali.
- [ ] **KW-03** Her ana terim için ilk 10 rakibin başlıkları / alt başlıkları okundu, ortak kelimeleri not edildi. Rakiplerin marka adlarını asla kullanmayın.
- [ ] **KW-04** Kullanıcıların kullandığı isimleri ve fiilleri bulmak için kendi uygulamanızın ve rakiplerin **yorumları** tarandı.
- [ ] **KW-05** Her aday puanlandı: alaka (0–3, < 2 olanı eleyin), popülerlik (otomatik tamamlamadaki sırası veya Apple Ads popülerliği), açıklık / zorluk (ilk 10 uygulamadan kaçı onu hedefliyor, ne kadar güçlüler).
- [ ] **KW-06** Yeni veya küçük uygulamalar, ana terimlerden önce kazanılabilir uzun kuyruk terimleri hedefler (3–4 kelime, orta popülerlik, yüksek açıklık).
- [ ] **KW-07** Her dil için bir **anahtar kelime haritası**: hangi terimler ad / başlıkta, hangileri alt başlık / kısa açıklamada, hangileri anahtar kelime alanı / tam açıklamada yer alır. Yeri olmayan terim de, terimi olmayan yer de kalmasın.
- [ ] **KW-08** Şu an 11–50. sıralarda yer alan terimler belirlendi; en ucuz kazanımlar bunlardır.
- [ ] **KW-09** Araştırma **her pazar için** yeniden yapılır: anahtar kelimeler İngilizceden çevrilmez, yerel dilde araştırılır.

## 2. App Store meta verileri (her dil için)

- [ ] **AS-01** (auto) Ad ≤ 30, alt başlık ≤ 30, anahtar kelime alanı ≤ 100, tanıtım metni ≤ 170, açıklama ≤ 4000.
- [ ] **AS-02** (auto) Ad, alt başlık ve anahtar kelime alanının her biri ≥ 90% dolu; boş kalan her karakter, kaçırılan sıralama demektir.
- [ ] **AS-03** Ad = marka + en öncelikli terim, doğal okunur ("Marka: Alışkanlık Takibi").
- [ ] **AS-04** (auto) Alt başlık **yeni** kelimeler ekler; addaki hiçbir kelimeyi tekrarlamaz.
- [ ] **AS-05** (auto) Anahtar kelime alanı: virgülle ayrılmış, **virgülden sonra boşluk yok**, sonda virgül yok.
- [ ] **AS-06** (auto) Anahtar kelime alanında ad veya alt başlıkta zaten geçen bir kelime yok, tekrar eden kelime de yok.
- [ ] **AS-07** (auto) Tekil **ya da** çoğul; ikisi birden değil.
- [ ] **AS-08** (auto) Boşa giden kelime yok: "app", "apps" ("uygulama"), "free" ("ücretsiz"), "iPhone", "iPad", "iOS", "Apple", marka / şirket adı; (elle) kategori adı.
- [ ] **AS-09** (auto, warning) Kelime öbekleri yerine tek kelimeleri tercih edin; Apple aynı dildeki ad + alt başlık + anahtar kelime alanındaki kelimeleri kendisi birleştirir.
- [ ] **AS-10** Hiçbir yerde rakip adı, ticari marka veya ünlü adı yok (Yönergeler 2.3.7, 5.2.1).
- [ ] **AS-11** (auto) Ad, alt başlık ve anahtar kelimelerde fiyat / sıralama / harekete geçirici kelime yok: "free", "best", "#1", "sale", "% off" (2.3.7); "ücretsiz", "en iyi", "indirim" gibi karşılıkları da dahil, hangi dilde olursa olsun.
- [ ] **AS-12** (auto) Emoji yok; Apple ticari markaları adınızın parçasıymış gibi kullanılmıyor (iPhone, Siri…).
- [ ] **AS-13** **Birincil kategori** en alakalı olandır (metin alakasının bir parçasıdır); ikincil kategori de seçildi.
- [ ] **AS-14** Açıklama: ilk 3 satır ana işi ve kanıtını söyler; kolay taranan madde işaretleri; anahtar kelime için kullanılmaz (App Store aramasında dizinlenmez), ama Google web araması ve Apple'ın etiket oluşturucusu onu okur.
- [ ] **AS-15** Tanıtım metni güncel haberler / teklifler için kullanılıyor (inceleme olmadan değiştirilebilir).
- [ ] **AS-16** (auto) Gizlilik politikası URL'si ve destek URL'si https; (elle) ikisi de açılıyor.
- [ ] **AS-17** Uygulama içi satın alımların görünen adları kullanıcının ne aldığını anlatır, doğal düşüyorsa bir arama terimi içerir ("Pro Alışkanlık Takibi").
- [ ] **AS-18** Uygulama içi etkinlikler (in-app events; varsa): anahtar kelime 30 karakterlik etkinlik adında; aynı anda en fazla 10 etkinlik yayında.
- [ ] **AS-19** **Uygulama etiketleri (App Tags)** (ABD mağazası, en-US meta verileri): App Store Connect'te gözden geçirildi, yanlış etiketlerin seçimi kaldırıldı (etiket ekleyemezsiniz; bu yüzden en-US açıklamasında kullanım senaryolarını açıkça yazın).
- [ ] **AS-20** Yaş derecelendirmesi anketi 2025 kademelerine göre yanıtlandı (4+ / 9+ / 13+ / 16+ / 18+).

## 3. Google Play meta verileri (her dil için)

- [ ] **GP-01** (auto) Başlık ≤ 30, kısa açıklama ≤ 80, tam açıklama ≤ 4000, sürüm notları (What's new) ≤ 500.
- [ ] **GP-02** (auto) Başlık ve kısa açıklama ≥ 90% dolu.
- [ ] **GP-03** Başlık = marka + ana terim; kısa açıklama = 2–3 ikincil terimi ve ana faydayı içeren gerçek bir cümle.
- [ ] **GP-04** (auto) Başlıktaki anahtar kelimeler tam açıklamada, üstelik ilk ~300 karakter içinde geçer.
- [ ] **GP-05** Her hedef terim tam açıklamada doğal biçimde 2–3 kez geçer; ilgili terimler ve eş anlamlılar kullanılır; anahtar kelime listesi yok.
- [ ] **GP-06** (auto) Hiçbir kelime ~3% yoğunluğu aşmıyor (anahtar kelime doldurma bir politika ihlalidir).
- [ ] **GP-07** (auto) Başlık / kısa açıklama / geliştirici adı: emoji yok, tekrarlanan özel karakter yok (`!!!`, `★★`), TAMAMI BÜYÜK HARFLİ kelime yok (marka öyle yazılmıyorsa).
- [ ] **GP-08** (auto) Başlıkta, simgede veya geliştirici adında "Free", "#1", "Best", "Top", "Popular", "New", "Editor's choice", "No ads" ("Ücretsiz", "En iyi", "Popüler", "Yeni", "Reklamsız"…), fiyat veya promosyon yok; her çeviride de.
- [ ] **GP-09** Açıklamada kime ait olduğu belirtilmeyen övgü yazıları (testimonial) veya anonim kullanıcı alıntıları yok.
- [ ] **GP-10** Tam açıklama yapılandırılmış: kanca (2 satır) → başlıklar / madde işaretleriyle temel özellikler → kanıt → harekete geçirici çağrı; bir LLM'in alıntılayabileceği sade cümleler kullanır ("… için X'i kullanın"), çünkü Ask Play / yapay zekâ özetleri (AI highlights) bu metni okur.
- [ ] **GP-11** Kategori ve en fazla 5 **etiket** ayarlandı (Mağaza ayarları).
- [ ] **GP-12** İletişim e-postası, web sitesi ve gizlilik politikası dolduruldu; web sitesi de uygulamayı anlatıyor (Ask Play onu okur).
- [ ] **GP-13** Veri güvenliği (Data safety) formu eksiksiz ve uygulamayla tutarlı.

## 4. Yerelleştirme

- [ ] **L10N-01** Her öncelikli pazarın kendi mağaza sayfası var; Play'in otomatik çevirisi değil, İngilizce değil.
- [ ] **L10N-02** (auto) Anahtar kelime alanı / kısa açıklama temel dilden **kopyalanmamış**.
- [ ] **L10N-03** Yerel arama terimleri yerel otomatik tamamlamadan ve yerel rakiplerden alındı (KW-09).
- [ ] **L10N-04** App Store **çapraz yerelleştirme**: her öncelikli ülke mağazası için Apple'ın orada dizinlediği ek dilleri listeleyin (ABD: en-US + es-MX, ar, zh-Hans, zh-Hant, fr-FR, ko, pt-BR, ru, vi; Birleşik Krallık: en-GB; Kanada: en-CA + fr-CA; Japonya: ja + en-US; diğerlerinin çoğu: yerel dil + en-GB) ve her dilin anahtar kelime alanına **farklı** kelimeler yazın.
- [ ] **L10N-05** Çapraz yerelleştirme için kullanılan dillerdeki metinler, o dili anadili olarak konuşanlar için de doğru ve anlamlı (gerçek kullanıcılar bunları görür).
- [ ] **L10N-06** (auto) CJK (Çince, Japonca, Korece) / Tayca / Arapça mağaza sayfaları da sınıra kadar dolu; bu dillerde kısa kalan alanlar en yaygın israftır.
- [ ] **L10N-07** Öncelikli diller için ekran görüntüleri ve üzerlerindeki metinler yerelleştirildi; Arapça / İbranice için sağdan sola düzen.
- [ ] **L10N-08** İddia kelimeleri yerel dilde kontrol edildi ("miễn phí", "gratis", "無料", "무료", "免费"…; Türkçede ör. "ücretsiz", "en iyi").

## 5. Simge, ekran görüntüleri, video

- [ ] **CR-01** Simge: tek ve net bir sembol, yazı yok, 40 px'te okunabilir, ilk 10 rakibin simgeleriyle yan yana konduğunda ayırt edilebilir.
- [ ] **CR-02** iOS 26: katmanlı Liquid Glass simgesi açık, koyu, renklendirilmiş ve saydam modlarda kontrol edildi.
- [ ] **CR-03** (auto, Play) Simge 512×512 PNG; öne çıkan grafik 1024×500, alfa kanalı yok, sıralama / fiyat / ödül iddiası yok.
- [ ] **CR-04** 1. ekran görüntüsü **ana işi** gösterir, ana anahtar kelime ≤ 5 kelimelik metninde geçer; arama sonuçlarında tek başına da işe yarar.
- [ ] **CR-05** 2–3. ekran görüntüleri uygulamayı yüklemek için sıradaki iki nedeni gösterir; her ekran görüntüsünde tek fayda.
- [ ] **CR-06** Gerçek uygulama arayüzü (App Store 2.3.3); Play'de metnin görseldeki payı ≤ 20%; "Download now" ("Hemen indir"), "#1", "Best" ("En iyi") veya mağaza rozetleri yok.
- [ ] **CR-07** App Store: 6.9" iPhone seti (1320×2868 / 1290×2796 / 1260×2736) ve uygulama iPad'de çalışıyorsa 13" iPad seti (2064×2752 / 2048×2732); her biri en fazla 10 görüntü; alfa kanalı yok.
- [ ] **CR-08** (auto) Play: 2–8 telefon ekran görüntüsü, kenarlar 320–3840 px, uzun kenar ≤ 2× kısa kenar; öne çıkarılmaya uygun olmak için ≥ 1080 px (9:16 veya 16:9) çözünürlükte ≥ 4 görüntü; destekleniyorsa tablet / Chromebook / Wear setleri (her cihaz türünde ayrı gösterilir).
- [ ] **CR-09** Video (isteğe bağlı, test edin): App Store önizlemesi 15–30 sn, yalnızca ekran kaydı, ilk 3 sn sesi olmadan da işi gösterir; Play'de YouTube bağlantısı herkese açık / liste dışı, reklamlar kapalı, ilk 30 sn belirleyici.
- [ ] **CR-10** Görseller anahtar kelime haritasıyla uyumlu: insanların aradığı şey, 1. ekran görüntüsünde gösterilen şeydir.

## 6. Özel sayfalar ve deneyler

- [ ] **EXP-01** En önemli anahtar kelime niyetleri için App Store **özel ürün sayfaları (custom product pages)** (en fazla 70); her birine onaylanmış anahtar kelime alanından anahtar kelimeler atandı.
- [ ] **EXP-02** Yüksek değerli arama anahtar kelimeleri / ülkeler / uygulamayı bırakmış kullanıcılar için Google Play **özel mağaza sayfaları (custom store listings)** (en fazla 50).
- [ ] **EXP-03** En önemli pazarda her zaman bir deney çalışıyor: App Store ürün sayfası optimizasyonu (product page optimization; ≤ 3 varyasyon, ≤ 90 gün) veya Play mağaza sayfası denemesi (store listing experiment; ≤ 2 varyant; başlık ve video test edilemez).
- [ ] **EXP-04** Her test: tek değişken, yazılı hipotez, başarı metriği, ≥ 7 gün; yalnızca konsol yeterli güven düzeyini gösterdiğinde durdurulur.
- [ ] **EXP-05** Beklenen etkiye göre test sırası: simge → 1. ekran görüntüsü → ekran görüntüsü metinleri → ekran görüntüsü sırası → video.
- [ ] **EXP-06** Sonuçlar kaydedildi (kazandı / kaybetti / fark yok); kazananlar diğer dillere varsayımla değil, yeni test olarak uygulanır.

## 7. Puanlar ve yorumlar

- [ ] **RV-01** Başarılı bir anın ardından sistemin kendi uygulama içi değerlendirme penceresi (`requestReview` / Play In-App Review API); asla açılışta, bir hatanın ardından ya da ön elemeyle (gating) gösterilmez; teşvik verilmez.
- [ ] **RV-02** Her öncelikli ülkede ortalama puan ≥ 4.0 (Play puanı ülkeye ve cihaz türüne göre hesaplar, yeni puanlar daha ağır basar).
- [ ] **RV-03** 1–3★ yorumlar birkaç gün içinde, konuya özel yanıtlanır; düzeltme yayınlandığında yeniden yanıt verilir.
- [ ] **RV-04** En sık tekrarlanan şikâyet biliniyor ve yol haritasında; iki mağazadaki yapay zekâ yorum özetleri onu manşet olarak öne çıkarır.
- [ ] **RV-05** Yorum metinleri yeni anahtar kelimeler ve özellik istekleri için her ay taranıyor.

## 8. Kalite ve teknik sinyaller

- [ ] **Q-01** Play Android vitals kötü davranış eşiklerinin altında (28 gün): kullanıcının algıladığı çökme oranı < 1.09%, ANR < 0.47%, telefon modeli başına < 8%; aşırı kısmi uyandırma kilidi (partial wake lock) görülen oturumlar < 5%.
- [ ] **Q-02** Şubat 2027'de yürürlüğe girecek Play bellek / bitmap / DEX eşikleri için plan yapıldı.
- [ ] **Q-03** Play: yeni uygulamalar / güncellemeler için hedef API 36 (2026-08-31'den beri); Apple: derlemeler Xcode 26 SDK ile (2026-04-28'den beri).
- [ ] **Q-04** Uygulama en az 1–3 ayda bir güncelleniyor; Yenilikler metni gerçek değişiklikleri anlatıyor (2.3.12).
- [ ] **Q-05** İndirme boyutu küçük tutuluyor; ilk açılışta çökme yok, değer sunulmadan önce giriş duvarı yok.
- [ ] **Q-06** Gizlilik etiketi (privacy nutrition label) / veri güvenliği ve (isteğe bağlı, App Store) Erişilebilirlik Etiketleri (Accessibility Nutrition Labels) beyan edildi.

## 9. Politika — ret ve kaldırma kontrolleri

- [ ] **POL-01** Yanıltıcı iddia, sahte yorum, doğrulanamayan "#1" / "best" yok; ad / başlıkta fiyat yok (App Store 2.3.1, 2.3.7; Play meta veri politikası).
- [ ] **POL-02** App Store meta verilerinde başka platformların adları yok ("Android", "Google Play") (2.3.10).
- [ ] **POL-03** Üçüncü taraf ticari markaları veya taklit adlar yok (5.2.1; Play kimliğe bürünme politikası).
- [ ] **POL-04** "For Kids" / "For Children" ("Çocuklar için") yalnızca Çocuklar (Kids) kategorisinde (2.3.8).
- [ ] **POL-05** Ekran görüntüleri / önizlemeler uygulamayı kullanılırken gösterir, yalnızca açılış ya da giriş ekranını değil (2.3.3, 2.3.4).
- [ ] **POL-06** Her çeviri aynı kurallara uyar (Play politikayı her dil için ayrı uygular).

## 10. Ölçün ve yineleyin

- [ ] **M-01** App Store Connect → Analytics: App Store aramasındaki gösterimler, ürün sayfası görüntülemeleri, dönüşüm, indirmeler; ülkeye ve özel ürün sayfasına göre.
- [ ] **M-02** Play Console → Grow overview / Statistics: **arama terimine** ve trafik kaynağına göre edinme (Store analysis Haziran 2026'da kaldırıldı; mağaza sayfası metrikleri Temmuz 2026'da tekil kullanıcı tıklamalarına geçti, bu tarihin öncesini ve sonrasını karşılaştırmayın).
- [ ] **M-03** Anahtar kelime haritasındaki terimlerin sıralamaları izleniyor (sıralama takip aracı, Apple Ads arama terimi raporu veya her ay yinelenen otomatik tamamlama taraması).
- [ ] **M-04** Bir seferde tek alan grubu değiştirilir; sonucu değerlendirmeden önce 2–4 hafta beklenir; App Store adı / alt başlığı / anahtar kelimeleri yalnızca yeni bir sürümle değişir.
- [ ] **M-05** Her ay: 4–6 hafta sonunda hiç gösterim almayan anahtar kelime alanı kelimelerini çıkarın, sıradaki adayları ekleyin, rakipleri ve mevsimselliği yeniden kontrol edin.

---

## Rapor şablonu

```markdown
# ASO denetimi — <Uygulama> — <tarih>

Mağazalar: <App Store / Google Play> · Diller: <liste> · Mod: <denetim / düzeltme>

## Skor
<geçen>/<toplam> madde · <n> ❌ · <n> ⚠️ · betik: <aso_check skor satırı>

## Alan tablosu
| Mağaza | Dil | Ad/Başlık | Alt başlık/Kısa | Anahtar kelimeler | Açıklama |
|---|---|---|---|---|---|
| App Store | en-US | 28/30 ✅ | 30/30 ✅ | 97/100 ✅ | 3120/4000 ✅ |

## Sorunlar (en etkiliden başlayarak)
| ID | Durum | Mağaza · dil · dosya | Kanıt | Düzeltme (sınıra sığan) |
|---|---|---|---|---|
| AS-06 | ❌ | App Store · en-US · keywords.txt | "tracker" adda da geçiyor | yerine "routine" yazın (+7 karakter) |

## Anahtar kelime haritası (her öncelikli dil için)
| Terim | Alaka | Otomatik tamamlama sırası | Açıklık | Alan |

## Sonraki 3 adım
1. …
```

## Kaynaklar

- Apple: [Arama](https://developer.apple.com/app-store/search/) ·
  [Platform sürüm bilgileri](https://developer.apple.com/help/app-store-connect/reference/platform-version-information) ·
  [App Store yerelleştirmeleri](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) ·
  [İnceleme Yönergeleri](https://developer.apple.com/app-store/review/guidelines/) ·
  [Ekran görüntüsü özellikleri](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/) ·
  [Özel ürün sayfaları](https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions/) ·
  [Uygulama etiketleri](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags)
- Google: [Mağaza sayfası için en iyi uygulamalar](https://support.google.com/googleplay/android-developer/answer/13393723) ·
  [Meta veri politikası](https://support.google.com/googleplay/android-developer/answer/9898842) ·
  [Önizleme öğeleri](https://support.google.com/googleplay/android-developer/answer/9866151) ·
  [Özel mağaza sayfaları](https://support.google.com/googleplay/android-developer/answer/9867158) ·
  [Mağaza sayfası denemeleri](https://support.google.com/googleplay/android-developer/answer/6227309) ·
  [Android vitals](https://developer.android.com/topic/performance/vitals) ·
  [Play'deki yenilikler](https://google.play/business/whats-new/)
- Mağazaya göre ayrıntılar ve tarihler (İngilizce): [`references/app-store.md`](../references/app-store.md),
  [`references/google-play.md`](../references/google-play.md),
  [`references/conversion.md`](../references/conversion.md),
  [`references/keyword-research.md`](../references/keyword-research.md),
  [`references/tools.md`](../references/tools.md).
