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

## Ghi nhớ kỹ thuật

- `flutter test integration_test` phù hợp cho integration test thường, không cần driver lưu ảnh.
- `flutter drive` + `integration_test_driver_extended.dart` phù hợp khi cần lưu screenshot PNG.
- Không ghi screenshot trực tiếp trong app process vì simulator/device có thể dùng filesystem read-only.
- `onScreenshot` chạy ở host driver process nên ghi file ổn định hơn.
