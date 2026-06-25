# AI Prompts for Flutter Test Skills

Dùng các prompt dưới đây cho AI agent khi cần tích hợp test Flutter.

## 1. Integration test không lưu screenshot

```text
Bạn là AI agent đang làm việc trong một Flutter project.

Hãy tích hợp Flutter integration test chạy trên emulator/simulator, không lưu file screenshot image.

Yêu cầu:
- Đọc skill tại thư mục `flutter-integration-test-skill/` nếu có.
- Thêm `integration_test` vào `dev_dependencies` nếu chưa có.
- Tạo thư mục `integration_test/` nếu chưa có.
- Tạo integration smoke test kiểm tra flow chính của app.
- Không tạo thư mục `screenshots/`.
- Không ghi file PNG/JPG.
- Không dùng `integration_test_driver_extended.dart`.
- Tạo file `integration_test.sh` để chạy:
  - `flutter pub get`
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`
  - `flutter test integration_test`
- Chạy validation và sửa lỗi nếu có.

Sau khi xong, báo lại:
- Files đã tạo/sửa.
- Command đã chạy.
- Kết quả pass/fail.
```

## 2. Flutter driver test có lưu screenshot image

```text
Bạn là AI agent đang làm việc trong một Flutter project.

Hãy tích hợp Flutter driver screenshot test để lưu file screenshot PNG vào thư mục `screenshots/` trên host machine.

Yêu cầu:
- Đọc skill tại thư mục `flutter-driver-screenshot-skill/` nếu có.
- Thêm `integration_test` vào `dev_dependencies` nếu chưa có.
- Tạo `integration_test/helpers/screenshot_helper.dart`.
- Helper chỉ gọi `binding.takeScreenshot(...)`, không ghi file trong app/simulator.
- Tạo `test_driver/integration_test.dart` dùng `integration_test_driver_extended.dart` và `onScreenshot` để ghi PNG vào `screenshots/`.
- Tạo `integration_test/screenshot_test.dart` để chụp ít nhất 1 màn hình chính.
- Tạo file `e2e.sh` để chạy:
  - `flutter pub get`
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`
  - `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshot_test.dart`
- Chạy validation và sửa lỗi nếu có.

Sau khi xong, báo lại:
- Files đã tạo/sửa.
- Command đã chạy.
- Screenshot files đã sinh ra.
- Kết quả pass/fail.
```

## 3. Tích hợp cả hai tính năng vào project khác

```text
Bạn là AI agent. Hãy tích hợp cả hai tính năng test Flutter vào project sau:

PROJECT_PATH=<đường dẫn project Flutter>

Tính năng 1:
- Integration test chạy emulator/simulator.
- Không lưu screenshot image.
- Có script `integration_test.sh`.

Tính năng 2:
- Flutter driver screenshot test.
- Lưu screenshot PNG vào `screenshots/` bằng host driver.
- Có script `e2e.sh`.

Nguồn skill:
- `flutter-integration-test-skill/`
- `flutter-driver-screenshot-skill/`

Quy trình:
1. Kiểm tra `PROJECT_PATH` là Flutter project có `pubspec.yaml`.
2. Đọc `lib/main.dart` và test hiện có để chọn smoke flow phù hợp.
3. Thêm dependency cần thiết.
4. Tạo/cập nhật integration test, screenshot helper, driver, scripts.
5. Chạy:
   - `flutter pub get`
   - `dart format --set-exit-if-changed .`
   - `flutter analyze`
   - `flutter test`
   - `sh integration_test.sh`
   - `sh e2e.sh`
6. Nếu lỗi, sửa nguyên nhân gốc, không bypass check.

Báo cáo cuối:
- Danh sách file thay đổi.
- Command validation.
- Screenshot output path.
- Lưu ý nếu cần emulator/simulator đang chạy.
```

## 4. Prompt ngắn để dùng nhanh

```text
Tích hợp 2 skill Flutter test vào project này:
1. Integration test không lưu screenshot, script `integration_test.sh`.
2. Flutter driver screenshot test lưu PNG vào `screenshots/`, script `e2e.sh`.
Đọc skill folder nếu có, tạo test phù hợp với app hiện tại, chạy validation, sửa lỗi đến khi pass.
```

## 5. Thuộc tính device/referral an toàn quyền riêng tư

```text
Dùng skill `privacy-safe-device-referral-attributes`.

Tạo POC minh bạch cho device/referral attributes trên Flutter Android, iOS và Web.

Yêu cầu:
- Chỉ dùng metadata platform/browser thông thường.
- Chỉ parse referral params trong allowlist như ref, referral, utm_source, utm_medium, utm_campaign, gclid, fbclid.
- Bỏ qua query params nhạy cảm không nằm trong allowlist như token, email, session, access_token.
- Tạo SHA-256 hash local từ các thuộc tính đã normalize và được phép dùng.
- Không gọi third-party IP services.
- Không dùng canvas/audio/WebGL/font fingerprinting.
- Hiển thị JSON đã collect và privacy notes trong UI.
- Chạy format/analyze và báo cáo file đã thay đổi.
```

## 6. Tạo bộ tài liệu sản phẩm đầy đủ (add-feat + add-srs)

```text
Dùng skill add-feat và add-srs để phân tích dự án này và tạo bộ tài liệu sản phẩm đầy đủ theo template mới nhất.

1. PHÂN TÍCH TRƯỚC. Map toàn bộ sản phẩm (frontend, backend/API, data model, build/deploy).
   Gom chức năng thành các epic EP01, EP02, … mỗi epic một slug kebab-case (vd ep01-auth).
   Liệt kê danh sách epic trước khi ghi file.

2. MỖI EPIC tạo (dưới resources/, bám template trong skills/add-feat/assets/templates/):
   - resources/user-story/epXX-<slug>.md — story dạng "## EPXX.US###: Title", mỗi story có:
     • dòng "Status:" (Backlog | To Do | Sprint | In Progress | In Review | Done) — đặt cột Board;
     • dòng "As a … I want … so that …" (mô tả card);
     • "Acceptance criteria:" dạng bullet (= task checklist; bullet lồng = sub-task).
   - resources/technial-design/epXX-<slug>.md — Technologies, Entry Points (đường dẫn file thật),
     Flow (đánh số), 1 sơ đồ Mermaid, bảng Entities, Tests.
   - resources/screens/epXX-<slug>-screen.md — heading đầu = tên màn hình; 1 wireframe ASCII trong
     fenced code (ký tự khung ┌─┐│└┘├┤┬┴); "## Components", "## States", "## Events".
     Viết event dạng "EventName -> mô tả" (hoặc →) trỏ màn hình đích theo FILE ID
     (vd "… -> navigate to ep02-…-screen") hoặc theo TỪ KHÓA TIÊU ĐỀ để Flow vẽ mũi tên;
     thêm event quay lại trên màn hình đích để có mũi tên 2 chiều.
   - 1 file resources/feature-brief.md — brief sản phẩm + bảng catalog epic.

3. COMPILE SRS. Viết resources/srs.md: purpose, scope, requirements summary, index user-story,
   use cases, mục "## Screens / UI Surfaces" (để TRỐNG cho script tự inject), data/entity model
   kèm sơ đồ Mermaid ER, external interfaces/API, NFRs, risks, và bảng traceability
   (FR → epic → stories → design → screen → verification).

4. RENDER. Đảm bảo có resources/srs.sh (copy bản mới nhất từ
   examples/flutter-poc-auth/resources/srs.sh, đổi tên tiêu đề sidebar), chạy ./resources/srs.sh
   để sinh srs-index.html ở thư mục gốc và verify cả 3 view:
   📄 Docs (TOC + screens đã inject) · 🔀 Flow (mỗi screen 1 card, mũi tên từ ## Events) ·
   🗂️ Board (mỗi story 1 card, xếp cột theo Status:).

Giữ nguyên ký tự khung trong fenced code, giữ mọi thứ local (không render ngoài),
và giữ resources/srs.md là source of truth duy nhất.

Mẹo: muốn tạo doc khởi tạo từ feature tree Flutter có sẵn, chạy
scripts/add_feat.sh gen-tdd <slug> EPXX trước rồi tinh chỉnh các file sinh ra.
```

Checklist deliverables (hoàn thành khi tick đủ):

- [ ] `resources/feature-brief.md` — brief + bảng catalog epic.
- [ ] `resources/user-story/epXX-<slug>.md` mỗi epic — story `## EPXX.US###`, có `Status:`, dòng `As a …`, và `Acceptance criteria:` (bullet lồng = sub-task).
- [ ] `resources/technial-design/epXX-<slug>.md` mỗi epic — Technologies · Entry Points · Flow · **Mermaid** · Entities · Tests.
- [ ] `resources/screens/epXX-<slug>-screen.md` mỗi màn hình — wireframe ASCII + `## Components/States/Events`; events `EventName -> …` trỏ màn hình đích để Flow vẽ mũi tên.
- [ ] `resources/srs.md` — đủ mục + `## Screens / UI Surfaces` (placeholder) + Mermaid **ER** + traceability matrix.
- [ ] `resources/srs.sh` (bản mới nhất) + `srs-index.html` đã sinh bằng `./resources/srs.sh`.
- [ ] Verify mở `srs-index.html`: **📄 Docs** inject screens · **🔀 Flow** có mũi tên từ `## Events` · **🗂️ Board** xếp cột theo `Status:`, click card xem mô tả + tasks · giữ ký tự khung, không còn marker thừa.

## Ghi nhớ kỹ thuật

- `flutter test integration_test` phù hợp cho integration test thường, không cần driver lưu ảnh.
- `flutter drive` + `integration_test_driver_extended.dart` phù hợp khi cần lưu screenshot PNG.
- Không ghi screenshot trực tiếp trong app process vì simulator/device có thể dùng filesystem read-only.
- `onScreenshot` chạy ở host driver process nên ghi file ổn định hơn.
