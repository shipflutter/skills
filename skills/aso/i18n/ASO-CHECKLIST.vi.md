# Checklist ASO — Apple App Store & Google Play

Checklist tối ưu hoá hiển thị trên store (App Store Optimization) dành cho người làm app và AI agent. Cập nhật **2026-10-01**.
Thuộc [skill `aso`](https://github.com/shipflutter/skills/tree/develop/skills/aso) của [ShipFlutter](https://shipflutter.app) · MIT.

> Đây là bản dịch. Bản gốc tiếng Anh là bản chuẩn để đối chiếu, và mã mục (ID) giống nhau ở mọi ngôn ngữ: <https://github.com/shipflutter/skills/blob/develop/skills/aso/ASO-CHECKLIST.md>

- Xem: <https://github.com/shipflutter/skills/blob/develop/skills/aso/i18n/ASO-CHECKLIST.vi.md>
- Bản thô (cho agent): <https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/i18n/ASO-CHECKLIST.vi.md>
- Cài đặt toàn bộ skill: `npx skills add shipflutter/skills --skill aso`

---

## Nếu bạn là AI agent, hãy đọc phần này trước

1. **Chế độ mặc định là kiểm tra (audit).** Đọc trang store, đánh dấu từng mục bên dưới, rồi báo cáo.
   Chỉ sửa tệp khi người dùng yêu cầu sửa. **Không bao giờ tải lên App Store Connect / Play Console
   hay gửi duyệt** trừ khi người dùng đã yêu cầu trong cuộc hội thoại này.
2. **Tìm trang store.** fastlane: `fastlane/metadata/ios/<locale>/*.txt` (hoặc
   `fastlane/metadata/<locale>/`) và `fastlane/metadata/android/<locale>/*.txt`. Nếu không có, nhờ
   người dùng dán tên / phụ đề / từ khoá / mô tả cho từng ngôn ngữ (locale), hoặc tiêu đề / mô tả
   ngắn / mô tả đầy đủ trên Play.
3. **Đếm bằng code, không bao giờ đếm bằng mắt.** Các mục có nhãn **(auto)** được kiểm tra bằng script miễn phí:
   ```bash
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/aso_check.py
   python3 aso_check.py --root .            # markdown report; exit 1 on errors
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/keyword_suggest.py
   python3 keyword_suggest.py "habit tracker" --az --country us --competition
   ```
   (Python 3.10+, chỉ dùng thư viện chuẩn, không cần API key.)
4. **Đánh dấu từng mục** `✅ pass` / `⚠️ improve` / `❌ fail` / `N/A` (đạt / cần cải thiện / không đạt / không áp dụng),
   kèm bằng chứng (tệp, số đếm, trích dẫn). Mỗi ⚠️/❌ phải có một cách sửa cụ thể, vừa giới hạn. Dùng mẫu báo cáo ở cuối tệp.
5. **Không bịa dữ liệu.** Không đưa ra lượng tìm kiếm, thứ hạng hay điểm xếp hạng mà bạn không tự đo.
   Thay vào đó, hãy ghi "chưa đo" (not measured). Thông tin gắn nhãn UNCONFIRMED (chưa xác nhận) bên dưới
   là quan sát của các nhà cung cấp công cụ, không phải quy định của store.

---

## Xem nhanh các giới hạn

| Store | Trường | Giới hạn | Được lập chỉ mục tìm kiếm |
|---|---|---|---|
| App Store | Tên ứng dụng | 30 | ✅ mạnh nhất |
| App Store | Phụ đề | 30 | ✅ |
| App Store | Trường từ khoá (ẩn) | 100 | ✅ |
| App Store | Văn bản quảng cáo | 170 | ❌ (sửa được mà không cần duyệt) |
| App Store | Mô tả | 4000 | ❌ với tìm kiếm trên App Store |
| App Store | Có gì mới | 4000 | ❌ |
| App Store | Tên / mô tả ngắn / mô tả dài của sự kiện trong app (in-app events) | 30 / 50 / 120 | ✅ tên sự kiện |
| App Store | Tên hiển thị / mô tả IAP | 30 / 45 | ✅ IAP được quảng bá |
| Google Play | Tiêu đề | 30 | ✅ mạnh nhất |
| Google Play | Mô tả ngắn | 80 | ✅ |
| Google Play | Mô tả đầy đủ | 4000 | ✅ (không có trường từ khoá ẩn) |
| Google Play | Có gì mới | 500 | ❌ |

Tài liệu của Apple ghi trường từ khoá là "100 byte", nhưng App Store Connect đếm theo ký tự
(một trường tiếng Nhật 100 ký tự / 220 byte đã được chấp nhận ngày 2026-10-01).

---

## 0. Trước khi bắt đầu

- [ ] **PRE-01** Viết ra 3 **việc chính (jobs)** app giúp người dùng làm, bằng lời của chính họ ("chia tiền với bạn bè"), cùng đối tượng người dùng và 5 đối thủ hàng đầu.
- [ ] **PRE-02** Chọn thị trường ưu tiên: storefront / quốc gia + ngôn ngữ, xếp theo lượt cài hiện tại hoặc theo người dùng mục tiêu.
- [ ] **PRE-03** Nội dung trang store nằm trong hệ thống quản lý phiên bản (metadata của fastlane `deliver` / `supply`), để mọi thay đổi đều diff được.
- [ ] **PRE-04** Ghi lại số liệu gốc (baseline) **trước** mọi thay đổi, cho từng quốc gia ưu tiên: lượt hiển thị trong tìm kiếm, lượt xem trang sản phẩm, tỷ lệ chuyển đổi, lượt tải theo nguồn, điểm xếp hạng và số lượt xếp hạng (xem phần 10).
- [ ] **PRE-05** Có nhật ký thay đổi (vd. `docs/aso-log.md`): ngày, các trường đã đổi, trước → sau, chỉ số cần theo dõi, ngày xem lại.

## 1. Nghiên cứu từ khoá

- [ ] **KW-01** 5–10 từ khoá gốc (seed) lấy từ các việc chính và danh từ chỉ danh mục — không phải tên thương hiệu, không chỉ là tính năng.
- [ ] **KW-02** Mở rộng bằng **gợi ý tự động (autocomplete)** của chính từng store, theo từng thị trường và ngôn ngữ (gõ thêm a–z để tìm từ khoá đuôi dài, long-tail). Thứ tự gợi ý = tín hiệu về độ phổ biến.
- [ ] **KW-03** Với mỗi từ khoá chính (head term), đọc tiêu đề / phụ đề của top 10 đối thủ; ghi lại những từ họ cùng dùng. Không bao giờ dùng tên thương hiệu của họ.
- [ ] **KW-04** Khai thác **đánh giá** của app mình và của đối thủ để tìm danh từ, động từ mà người dùng thực sự dùng.
- [ ] **KW-05** Chấm điểm từng từ ứng viên: mức liên quan (0–3, loại nếu < 2), độ phổ biến (vị trí trong gợi ý tự động hoặc chỉ số popularity của Apple Ads), độ mở / độ khó (bao nhiêu app trong top 10 nhắm tới từ đó, và chúng mạnh đến đâu).
- [ ] **KW-06** App mới hoặc nhỏ nhắm vào từ khoá đuôi dài có thể thắng (3–4 từ, độ phổ biến trung bình, độ mở cao) trước khi nhắm tới từ khoá chính.
- [ ] **KW-07** Có **bản đồ từ khoá** cho từng ngôn ngữ: từ nào thuộc về tên / tiêu đề, phụ đề / mô tả ngắn, và trường từ khoá / mô tả đầy đủ. Không từ nào thiếu chỗ, không chỗ nào thiếu từ.
- [ ] **KW-08** Xác định các từ khoá đang có thứ hạng 11–50 — đây là những chiến thắng ít tốn công nhất.
- [ ] **KW-09** Nghiên cứu lại **cho từng thị trường** — từ khoá được tìm bằng ngôn ngữ địa phương, không dịch từ tiếng Anh.

## 2. Metadata App Store (theo từng ngôn ngữ)

- [ ] **AS-01** (auto) Tên ≤ 30, phụ đề ≤ 30, trường từ khoá ≤ 100, văn bản quảng cáo ≤ 170, mô tả ≤ 4000.
- [ ] **AS-02** (auto) Tên, phụ đề và trường từ khoá đều được điền ≥ 90% — ký tự bỏ trống là cơ hội xếp hạng bị mất.
- [ ] **AS-03** Tên = thương hiệu + từ khoá ưu tiên cao nhất, đọc tự nhiên ("TênApp: Theo dõi thói quen").
- [ ] **AS-04** (auto) Phụ đề bổ sung từ **mới** — không lặp lại từ nào trong tên.
- [ ] **AS-05** (auto) Trường từ khoá: phân cách bằng dấu phẩy, **không có dấu cách sau dấu phẩy**, không có dấu phẩy ở cuối.
- [ ] **AS-06** (auto) Trường từ khoá không chứa từ đã có trong tên hoặc phụ đề, và không có từ trùng lặp.
- [ ] **AS-07** (auto) Dùng số ít **hoặc** số nhiều, không dùng cả hai.
- [ ] **AS-08** (auto) Không dùng từ lãng phí: "app", "apps", "free", "iPhone", "iPad", "iOS", "Apple" (và từ tương đương như "ứng dụng", "miễn phí"), tên thương hiệu / công ty; (kiểm tra thủ công) tên danh mục.
- [ ] **AS-09** (auto, warning) Ưu tiên từ đơn thay vì cụm từ — Apple tự ghép các từ trong tên + phụ đề + trường từ khoá của cùng một ngôn ngữ.
- [ ] **AS-10** Không dùng tên đối thủ, nhãn hiệu hay tên người nổi tiếng ở bất kỳ đâu (Hướng dẫn duyệt app 2.3.7, 5.2.1).
- [ ] **AS-11** (auto) Không có từ về giá / thứ hạng / kêu gọi hành động trong tên, phụ đề, từ khoá: "free", "best", "#1", "sale", "% off" (2.3.7), ở mọi ngôn ngữ (vd. "miễn phí", "tốt nhất", "giảm giá").
- [ ] **AS-12** (auto) Không emoji; không dùng nhãn hiệu của Apple như thể là một phần tên app của bạn (iPhone, Siri…).
- [ ] **AS-13** **Danh mục chính** là danh mục liên quan nhất (danh mục cũng được tính vào độ liên quan của văn bản); đã chọn danh mục phụ.
- [ ] **AS-14** Mô tả: 3 dòng đầu nêu việc chính và bằng chứng; gạch đầu dòng dễ đọc lướt; không dùng làm chỗ đặt từ khoá (không được lập chỉ mục cho tìm kiếm App Store) nhưng Google web search và bộ tạo thẻ của Apple vẫn đọc nó.
- [ ] **AS-15** Văn bản quảng cáo dùng cho tin tức / ưu đãi hiện tại (đổi được mà không cần duyệt).
- [ ] **AS-16** (auto) URL chính sách quyền riêng tư và URL hỗ trợ dùng https; (kiểm tra thủ công) cả hai đều mở được.
- [ ] **AS-17** Tên hiển thị của gói mua trong app (in-app purchase) mô tả thứ người dùng nhận được, kèm một từ khoá tìm kiếm nếu tự nhiên ("Theo dõi thói quen Pro").
- [ ] **AS-18** Sự kiện trong app (nếu có): có từ khoá trong tên sự kiện 30 ký tự; tối đa 10 sự kiện được xuất bản cùng lúc.
- [ ] **AS-19** **Thẻ ứng dụng (App tags)** (storefront Mỹ, metadata en-US): đã rà soát trong App Store Connect; bỏ chọn thẻ sai (bạn không thể tự thêm thẻ — hãy để mô tả en-US nêu rõ các tình huống sử dụng).
- [ ] **AS-20** Đã trả lời bảng câu hỏi phân loại độ tuổi theo các mức năm 2025 (4+ / 9+ / 13+ / 16+ / 18+).

## 3. Metadata Google Play (theo từng ngôn ngữ)

- [ ] **GP-01** (auto) Tiêu đề ≤ 30, mô tả ngắn ≤ 80, mô tả đầy đủ ≤ 4000, Có gì mới ≤ 500.
- [ ] **GP-02** (auto) Tiêu đề và mô tả ngắn đều được điền ≥ 90%.
- [ ] **GP-03** Tiêu đề = thương hiệu + từ khoá chính; mô tả ngắn = một câu hoàn chỉnh chứa 2–3 từ khoá phụ và lợi ích chính.
- [ ] **GP-04** (auto) Từ khoá trong tiêu đề có xuất hiện trong mô tả đầy đủ, và nằm trong ~300 ký tự đầu tiên.
- [ ] **GP-05** Mỗi từ khoá mục tiêu xuất hiện tự nhiên 2–3 lần trong mô tả đầy đủ; có dùng từ liên quan và từ đồng nghĩa; không liệt kê từ khoá.
- [ ] **GP-06** (auto) Không từ nào có mật độ trên ~3% (nhồi nhét từ khoá là vi phạm chính sách).
- [ ] **GP-07** (auto) Tiêu đề / mô tả ngắn / tên nhà phát triển: không emoji, không lặp ký tự đặc biệt (`!!!`, `★★`), không VIẾT HOA TOÀN BỘ (trừ khi đó là thương hiệu).
- [ ] **GP-08** (auto) Không có "Free", "#1", "Best", "Top", "Popular", "New", "Editor's choice", "No ads", giá hay khuyến mãi trong tiêu đề, icon hoặc tên nhà phát triển — ở mọi bản dịch (vd. "Miễn phí", "Tốt nhất", "Mới", "Không quảng cáo").
- [ ] **GP-09** Không có lời chứng thực không rõ nguồn hay trích dẫn của người dùng ẩn danh trong mô tả.
- [ ] **GP-10** Mô tả đầy đủ có cấu trúc: câu mở đầu thu hút (2 dòng) → tính năng chính với tiêu đề / gạch đầu dòng → bằng chứng → lời kêu gọi hành động; dùng câu đơn giản mà LLM có thể trích nguyên văn ("Dùng X để …") vì Ask Play / AI highlights đọc phần này.
- [ ] **GP-11** Đã đặt danh mục và tối đa 5 **thẻ (tags)** (trong Store settings).
- [ ] **GP-12** Đã điền email liên hệ, website và chính sách quyền riêng tư; website cũng mô tả app (Ask Play đọc nó).
- [ ] **GP-13** Biểu mẫu An toàn dữ liệu (Data safety) đầy đủ và khớp với app.

## 4. Bản địa hoá

- [ ] **L10N-01** Mỗi thị trường ưu tiên có trang store riêng — không dùng bản dịch tự động của Play, cũng không để nguyên tiếng Anh.
- [ ] **L10N-02** (auto) Trường từ khoá / mô tả ngắn **không sao chép** từ ngôn ngữ gốc.
- [ ] **L10N-03** Từ khoá tìm kiếm địa phương lấy từ gợi ý tự động và đối thủ tại thị trường đó (KW-09).
- [ ] **L10N-04** **Bản địa hoá chéo (cross-localization)** trên App Store: với mỗi storefront ưu tiên, liệt kê các ngôn ngữ phụ mà Apple lập chỉ mục ở đó (US: en-US + es-MX, ar, zh-Hans, zh-Hant, fr-FR, ko, pt-BR, ru, vi; UK: en-GB; CA: en-CA + fr-CA; JP: ja + en-US; hầu hết nơi khác: ngôn ngữ bản địa + en-GB) và cho mỗi ngôn ngữ một bộ từ **khác nhau** trong trường từ khoá.
- [ ] **L10N-05** Các ngôn ngữ dùng để bản địa hoá chéo vẫn phải đọc đúng với người bản xứ của ngôn ngữ đó (người dùng thật sẽ thấy chúng).
- [ ] **L10N-06** (auto) Trang store tiếng CJK (Trung / Nhật / Hàn), Thái, Ả Rập cũng được điền tới giới hạn — điền thiếu ở các ngôn ngữ này là kiểu lãng phí phổ biến nhất.
- [ ] **L10N-07** Ảnh chụp màn hình và chú thích được bản địa hoá cho các ngôn ngữ ưu tiên; bố cục từ phải sang trái cho tiếng Ả Rập / Do Thái.
- [ ] **L10N-08** Kiểm tra các từ nêu giá hay thứ hạng bằng ngôn ngữ địa phương ("miễn phí", "gratis", "無料", "무료", "免费"…).

## 5. Icon, ảnh chụp màn hình, video

- [ ] **CR-01** Icon: một biểu tượng rõ ràng, không có chữ, vẫn nhận ra ở 40 px, khác biệt khi đặt cạnh icon của top 10 đối thủ.
- [ ] **CR-02** iOS 26: icon Liquid Glass nhiều lớp đã được kiểm tra ở các chế độ sáng, tối, phủ màu (tinted) và trong suốt (clear).
- [ ] **CR-03** (auto, Play) Icon PNG 512×512; ảnh nổi bật (feature graphic) 1024×500 không có kênh alpha, không nêu thứ hạng / giá / giải thưởng.
- [ ] **CR-04** Ảnh chụp màn hình 1 thể hiện **việc chính**, với từ khoá chính trong chú thích ≤ 5 từ; chỉ riêng ảnh này cũng phải hiệu quả trong kết quả tìm kiếm.
- [ ] **CR-05** Ảnh chụp màn hình 2–3 thể hiện hai lý do tiếp theo để cài app; mỗi ảnh một lợi ích.
- [ ] **CR-06** Giao diện thật của app (App Store 2.3.3); chú thích trên Play ≤ 20% diện tích ảnh; không có "Download now" ("Tải ngay"), "#1", "Best" ("Tốt nhất"), huy hiệu store.
- [ ] **CR-07** App Store: bộ ảnh iPhone 6.9" (1320×2868 / 1290×2796 / 1260×2736) và bộ ảnh iPad 13" (2064×2752 / 2048×2732) nếu app chạy trên iPad; tối đa 10 ảnh mỗi bộ; không có kênh alpha.
- [ ] **CR-08** (auto) Play: 2–8 ảnh chụp màn hình điện thoại, mỗi cạnh 320–3840 px, cạnh dài ≤ 2× cạnh ngắn; ≥ 4 ảnh ở ≥ 1080 px (9:16 hoặc 16:9) để đủ điều kiện được đề xuất (featuring); bộ ảnh tablet / Chromebook / Wear nếu có hỗ trợ (hiển thị theo từng loại thiết bị).
- [ ] **CR-09** Video (không bắt buộc, hãy thử nghiệm): video xem trước trên App Store 15–30 giây, chỉ quay màn hình, 3 giây đầu thể hiện việc chính ngay cả khi tắt tiếng; Play: link YouTube ở chế độ công khai / không công khai (unlisted), tắt quảng cáo, 30 giây đầu là quan trọng nhất.
- [ ] **CR-10** Hình ảnh khớp với bản đồ từ khoá: điều người dùng tìm kiếm chính là điều ảnh chụp màn hình 1 thể hiện.

## 6. Trang tuỳ chỉnh & thử nghiệm

- [ ] **EXP-01** **Trang sản phẩm tuỳ chỉnh (custom product pages)** trên App Store (tối đa 70) cho các ý định tìm kiếm hàng đầu, mỗi trang được gán từ khoá lấy từ trường từ khoá đã được duyệt.
- [ ] **EXP-02** **Trang store tuỳ chỉnh (custom store listings)** trên Google Play (tối đa 50) cho từ khoá tìm kiếm giá trị cao / quốc gia / người dùng đã rời bỏ.
- [ ] **EXP-03** Luôn có một thử nghiệm đang chạy ở thị trường hàng đầu: tối ưu hoá trang sản phẩm (product page optimization) trên App Store (≤ 3 phương án, ≤ 90 ngày) hoặc thử nghiệm trang store (store listing experiments) trên Play (≤ 2 biến thể; không thử nghiệm được tiêu đề và video).
- [ ] **EXP-04** Mỗi thử nghiệm: một biến, giả thuyết viết ra trước, chỉ số thành công, ≥ 7 ngày, chỉ dừng khi console báo đủ độ tin cậy.
- [ ] **EXP-05** Thứ tự thử nghiệm theo mức tăng kỳ vọng: icon → ảnh chụp màn hình 1 → chú thích → thứ tự ảnh → video.
- [ ] **EXP-06** Ghi lại kết quả (thắng / thua / hoà) và áp dụng phương án thắng cho ngôn ngữ khác dưới dạng thử nghiệm mới, chứ không mặc định là sẽ thắng.

## 7. Điểm xếp hạng & đánh giá

- [ ] **RV-01** Hộp thoại mời đánh giá của hệ thống (`requestReview` / Play In-App Review API) sau một khoảnh khắc thành công; không bao giờ hiện lúc mở app, sau lỗi, hay lọc trước người dùng (review gating); không kèm phần thưởng.
- [ ] **RV-02** Điểm xếp hạng trung bình ≥ 4.0 ở mỗi quốc gia ưu tiên (Play tính điểm theo quốc gia và loại thiết bị, điểm gần đây có trọng số cao hơn).
- [ ] **RV-03** Trả lời các đánh giá 1–3★ trong vài ngày, cụ thể từng vấn đề; trả lời lại khi bản sửa được phát hành.
- [ ] **RV-04** Nắm rõ lời phàn nàn lặp lại nhiều nhất và đã đưa vào lộ trình — bản tóm tắt đánh giá bằng AI trên cả hai store sẽ đưa nó lên làm tiêu điểm.
- [ ] **RV-05** Hằng tháng khai thác nội dung đánh giá để tìm từ khoá mới và yêu cầu tính năng.

## 8. Chất lượng & tín hiệu kỹ thuật

- [ ] **Q-01** Android vitals trên Play dưới ngưỡng hành vi xấu (28 ngày): tỷ lệ crash người dùng nhận thấy (user-perceived) < 1.09%, ANR < 0.47%, theo từng mẫu điện thoại < 8%; partial wake lock quá mức < 5% số phiên.
- [ ] **Q-02** Đã lên kế hoạch cho các ngưỡng bộ nhớ / bitmap / DEX của Play, bắt đầu áp dụng từ tháng Hai năm 2027.
- [ ] **Q-03** Play: target API 36 cho app mới / bản cập nhật (từ 2026-08-31); Apple: build bằng SDK Xcode 26 (từ 2026-04-28).
- [ ] **Q-04** App được cập nhật ít nhất 1–3 tháng một lần; mục Có gì mới mô tả thay đổi thật (2.3.12).
- [ ] **Q-05** Giữ dung lượng tải xuống nhỏ; không crash ở lần mở đầu tiên, không bắt đăng nhập trước khi người dùng thấy giá trị.
- [ ] **Q-06** Đã khai báo nhãn quyền riêng tư (privacy nutrition label) / An toàn dữ liệu và (không bắt buộc, App Store) nhãn trợ năng (Accessibility Nutrition Labels).

## 9. Chính sách — kiểm tra để tránh bị từ chối & gỡ bỏ

- [ ] **POL-01** Không có tuyên bố gây hiểu lầm, đánh giá giả, "#1" / "best" ("tốt nhất") không kiểm chứng được, hay giá trong tên / tiêu đề (App Store 2.3.1, 2.3.7; chính sách metadata của Play).
- [ ] **POL-02** Không có tên nền tảng khác trong metadata App Store ("Android", "Google Play") (2.3.10).
- [ ] **POL-03** Không dùng nhãn hiệu của bên thứ ba hay tên nhái (5.2.1; chính sách mạo danh của Play).
- [ ] **POL-04** "For Kids" / "For Children" ("Dành cho trẻ em") chỉ được dùng trong danh mục Kids (2.3.8).
- [ ] **POL-05** Ảnh chụp màn hình / video xem trước: thể hiện app đang được dùng, không chỉ màn hình chờ (splash) hay màn hình đăng nhập (2.3.3, 2.3.4).
- [ ] **POL-06** Mọi bản dịch tuân theo cùng quy tắc (Play áp dụng chính sách theo từng ngôn ngữ).

## 10. Đo lường & cải tiến

- [ ] **M-01** App Store Connect → Analytics: lượt hiển thị trong App Store Search, lượt xem trang sản phẩm, chuyển đổi, lượt tải — theo từng quốc gia và từng trang sản phẩm tuỳ chỉnh.
- [ ] **M-02** Play Console → Grow overview / Statistics: lượt thu nạp người dùng theo **cụm từ tìm kiếm** và nguồn lưu lượng (Store analysis đã ngừng hoạt động từ tháng Sáu năm 2026; chỉ số trang store chuyển sang lượt nhấp theo người dùng duy nhất (unique user clicks) từ tháng Bảy năm 2026 — đừng so sánh số liệu trước và sau mốc đó).
- [ ] **M-03** Theo dõi thứ hạng các từ khoá trong bản đồ từ khoá (công cụ theo dõi thứ hạng, báo cáo cụm từ tìm kiếm của Apple Ads, hoặc chạy lại gợi ý tự động hằng tháng).
- [ ] **M-04** Mỗi lần chỉ đổi một nhóm trường; chờ 2–4 tuần rồi mới đánh giá; tên / phụ đề / từ khoá trên App Store chỉ đổi được khi ra phiên bản mới.
- [ ] **M-05** Hằng tháng: bỏ các từ trong trường từ khoá không có lượt hiển thị sau 4–6 tuần, thêm từ ứng viên tiếp theo, kiểm tra lại đối thủ và yếu tố mùa vụ.

---

## Mẫu báo cáo

```markdown
# Kiểm tra ASO — <App> — <ngày>

Store: <App Store / Google Play> · Ngôn ngữ: <danh sách> · Chế độ: <kiểm tra / sửa>

## Điểm
<số mục đạt>/<tổng> mục · <n> ❌ · <n> ⚠️ · script: <dòng điểm của aso_check>

## Bảng các trường
| Store | Ngôn ngữ | Tên/Tiêu đề | Phụ đề/Mô tả ngắn | Từ khoá | Mô tả |
|---|---|---|---|---|---|
| App Store | en-US | 28/30 ✅ | 30/30 ✅ | 97/100 ✅ | 3120/4000 ✅ |

## Vấn đề (ảnh hưởng lớn nhất trước)
| ID | Trạng thái | Store · ngôn ngữ · tệp | Bằng chứng | Cách sửa (vừa giới hạn) |
|---|---|---|---|---|
| AS-06 | ❌ | App Store · en-US · keywords.txt | "tracker" đã có trong tên | thay bằng "routine" (+7 ký tự) |

## Bản đồ từ khoá (theo từng ngôn ngữ ưu tiên)
| Từ khoá | Mức liên quan | Vị trí gợi ý tự động | Độ mở | Trường |

## 3 việc cần làm tiếp
1. …
```

## Nguồn tham khảo

- Apple: [Tìm kiếm](https://developer.apple.com/app-store/search/) ·
  [Thông tin phiên bản nền tảng](https://developer.apple.com/help/app-store-connect/reference/platform-version-information) ·
  [Bản địa hoá App Store](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) ·
  [Hướng dẫn duyệt app](https://developer.apple.com/app-store/review/guidelines/) ·
  [Thông số ảnh chụp màn hình](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/) ·
  [Trang sản phẩm tuỳ chỉnh](https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions/) ·
  [Thẻ ứng dụng](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags)
- Google: [Phương pháp hay nhất cho trang store](https://support.google.com/googleplay/android-developer/answer/13393723) ·
  [Chính sách metadata](https://support.google.com/googleplay/android-developer/answer/9898842) ·
  [Tài nguyên xem trước](https://support.google.com/googleplay/android-developer/answer/9866151) ·
  [Trang store tuỳ chỉnh](https://support.google.com/googleplay/android-developer/answer/9867158) ·
  [Thử nghiệm trang store](https://support.google.com/googleplay/android-developer/answer/6227309) ·
  [Android vitals](https://developer.android.com/topic/performance/vitals) ·
  [Có gì mới trên Play](https://google.play/business/whats-new/)
- Chi tiết và mốc thời gian theo từng store: [`references/app-store.md`](../references/app-store.md),
  [`references/google-play.md`](../references/google-play.md),
  [`references/conversion.md`](../references/conversion.md),
  [`references/keyword-research.md`](../references/keyword-research.md),
  [`references/tools.md`](../references/tools.md).
