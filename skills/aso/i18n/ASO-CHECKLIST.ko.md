# ASO 체크리스트 — Apple App Store & Google Play

앱 제작자와 AI 에이전트를 위한 앱 스토어 최적화(ASO) 체크리스트입니다. **2026-10-01** 업데이트.
[ShipFlutter](https://shipflutter.app)의 [`aso` 스킬](https://github.com/shipflutter/skills/tree/develop/skills/aso)에 포함된 문서 · MIT.

> 이 문서는 번역본입니다. 기준은 영어 원문이며, 항목 ID는 모든 언어에서 같습니다: <https://github.com/shipflutter/skills/blob/develop/skills/aso/ASO-CHECKLIST.md>

- 보기: <https://github.com/shipflutter/skills/blob/develop/skills/aso/i18n/ASO-CHECKLIST.ko.md>
- Raw 파일(에이전트용): <https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/i18n/ASO-CHECKLIST.ko.md>
- 전체 스킬 설치: `npx skills add shipflutter/skills --skill aso`

---

## AI 에이전트라면 이것부터 읽으세요

1. **기본 모드는 점검입니다.** 스토어 등록 정보를 읽고, 아래 모든 항목을 표시한 뒤 보고하세요. 사용자가
   수정을 요청했을 때만 파일을 고치세요. 사용자가 이 대화에서 요청하지 않았다면 **App Store Connect /
   Play Console에 업로드하거나 심사를 제출하지 마세요**.
2. **등록 정보를 찾으세요.** fastlane: `fastlane/metadata/ios/<locale>/*.txt` (또는
   `fastlane/metadata/<locale>/`)와 `fastlane/metadata/android/<locale>/*.txt`. 없으면 언어별 이름 /
   부제 / 키워드 / 설명, 또는 Play 제목 / 간단한 설명 / 자세한 설명을 붙여 넣어 달라고
   사용자에게 요청하세요.
3. **글자 수는 눈대중이 아니라 코드로 세세요.** **(auto)** 표시 항목은 무료 스크립트로 검사합니다:
   ```bash
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/aso_check.py
   python3 aso_check.py --root .            # markdown report; exit 1 on errors
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/keyword_suggest.py
   python3 keyword_suggest.py "habit tracker" --az --country us --competition
   ```
   (Python 3.10+, 표준 라이브러리만 사용, API 키 불필요.)
4. **각 항목을 표시하세요.** `✅ pass`(통과) / `⚠️ improve`(개선 필요) / `❌ fail`(실패) / `N/A`(해당 없음) 중 하나로 표시하고 근거(파일, 글자 수, 인용)를 적습니다.
   ⚠️/❌마다 제한 안에 들어가는 구체적인 수정안을 붙이세요. 마지막의 보고서 템플릿을 쓰세요.
5. **데이터를 지어내지 마세요.** 직접 측정하지 않은 검색량, 순위, 평점은 쓰지 말고
   "측정하지 않음"이라고 쓰세요. 아래에서 UNCONFIRMED로 표시된 내용은 스토어 규칙이 아니라 업체의 관찰 결과입니다.

---

## 글자 수 제한 한눈에 보기

| 스토어 | 항목 | 제한 | 검색 색인 |
|---|---|---|---|
| App Store | 앱 이름 | 30 | ✅ 가장 강함 |
| App Store | 부제 | 30 | ✅ |
| App Store | 키워드 필드(숨김) | 100 | ✅ |
| App Store | 프로모션 텍스트 | 170 | ❌ (심사 없이 수정 가능) |
| App Store | 설명 | 4000 | ❌ App Store 검색에는 미반영 |
| App Store | 이 버전의 새로운 기능 | 4000 | ❌ |
| App Store | 인앱 이벤트(in-app events) 이름 / 짧은 설명 / 긴 설명 | 30 / 50 / 120 | ✅ 이벤트 이름 |
| App Store | 인앱 구매 표시 이름 / 설명 | 30 / 45 | ✅ 프로모션 인앱 구매 |
| Google Play | 제목 | 30 | ✅ 가장 강함 |
| Google Play | 간단한 설명 | 80 | ✅ |
| Google Play | 자세한 설명 | 4000 | ✅ (숨은 키워드 필드 없음) |
| Google Play | 출시 노트(What's new) | 500 | ❌ |

Apple 문서는 키워드 필드를 "100바이트"라고 하지만, App Store Connect는 글자 수로 셉니다
(2026-10-01에 100자 / 220바이트 일본어 필드가 승인됨).

---

## 0. 시작하기 전에

- [ ] **PRE-01** 앱의 핵심 **용도(job)** 3가지를 사용자의 말로("친구와 더치페이하기") 적고, 대상 사용자와 상위 경쟁 앱 5개도 적으세요.
- [ ] **PRE-02** 우선 시장을 정하세요: 스토어프런트 / 국가 + 언어, 현재 설치 수나 목표 사용자 기준으로 순위를 매깁니다.
- [ ] **PRE-03** 스토어 등록 정보를 버전 관리에 두세요(fastlane `deliver` / `supply` 메타데이터). 그래야 모든 변경을 diff로 비교할 수 있습니다.
- [ ] **PRE-04** 무엇이든 바꾸기 **전에** 우선 국가별 기준값을 기록하세요: 검색 노출수, 제품 페이지 조회수, 전환율, 유입 경로별 다운로드 수, 평점과 평점 수(섹션 10 참고).
- [ ] **PRE-05** 변경 기록(예: `docs/aso-log.md`)을 남기세요: 날짜, 바꾼 항목, 변경 전 → 후, 확인할 지표, 후속 확인 날짜.

## 1. 키워드 조사

- [ ] **KW-01** 용도와 카테고리 명사에서 시드 키워드 5–10개를 뽑으세요 — 브랜드명은 빼고, 기능 이름만으로 채우지도 마세요.
- [ ] **KW-02** 각 스토어의 **자동완성**으로 시장·언어별로 확장하세요(a–z 롱테일). 추천 순서 = 인기도 신호입니다.
- [ ] **KW-03** 대표 키워드(head term)마다 상위 10개 경쟁 앱의 제목 / 부제를 읽고 공통 단어를 적어 두세요. 경쟁 앱의 브랜드명은 절대 쓰지 마세요.
- [ ] **KW-04** 자사 앱과 경쟁 앱의 **리뷰**에서 사용자가 실제로 쓰는 명사와 동사를 찾아내세요.
- [ ] **KW-05** 후보마다 점수를 매기세요: 관련성(0–3, < 2는 제외), 인기도(자동완성 순위 또는 Apple Ads 인기도), 공략 여지 / 난이도(상위 10개 앱 중 몇 개가 노리는지, 얼마나 강한지).
- [ ] **KW-06** 신규·소규모 앱은 대표 키워드보다 이길 수 있는 롱테일(3–4단어, 중간 인기도, 공략 여지 큼)을 먼저 노리세요.
- [ ] **KW-07** 언어별 **키워드 맵**: 이름 / 제목, 부제 / 간단한 설명, 키워드 필드 / 자세한 설명이 각각 어떤 키워드를 맡는지 정하세요. 자리 없는 키워드도, 키워드 없는 자리도 없어야 합니다.
- [ ] **KW-08** 이미 11–50위에 있는 키워드를 찾으세요 — 가장 적은 노력으로 얻는 성과입니다.
- [ ] **KW-09** 조사는 **시장별로** 다시 하세요 — 키워드는 영어에서 번역하지 말고 현지 언어로 조사합니다.

## 2. App Store 메타데이터 (언어별)

- [ ] **AS-01** (auto) 이름 ≤ 30, 부제 ≤ 30, 키워드 필드 ≤ 100, 프로모션 텍스트 ≤ 170, 설명 ≤ 4000.
- [ ] **AS-02** (auto) 이름, 부제, 키워드 필드를 각각 ≥ 90% 채우세요 — 비워 둔 글자 수만큼 순위 기회를 잃습니다.
- [ ] **AS-03** 이름 = 브랜드 + 최우선 키워드. 자연스럽게 읽혀야 합니다("브랜드: 습관 트래커").
- [ ] **AS-04** (auto) 부제에는 **새로운** 단어를 넣으세요 — 이름의 단어를 반복하지 않습니다.
- [ ] **AS-05** (auto) 키워드 필드: 쉼표로 구분, **쉼표 뒤 공백 없음**, 끝에 쉼표 없음.
- [ ] **AS-06** (auto) 키워드 필드에 이름이나 부제에 이미 있는 단어가 없고, 중복도 없어야 합니다.
- [ ] **AS-07** (auto) 단수 **또는** 복수 중 하나만 쓰세요. 둘 다 쓰지 않습니다.
- [ ] **AS-08** (auto) 낭비 단어 없음: "app", "apps", "free", "iPhone", "iPad", "iOS", "Apple"(한국어라면 "앱", "무료"도), 브랜드 / 회사명; (수동) 카테고리 이름.
- [ ] **AS-09** (auto, warning) 구문보다 단일 단어를 쓰세요 — Apple은 같은 언어의 이름 + 부제 + 키워드 필드에 있는 단어를 서로 조합합니다.
- [ ] **AS-10** 경쟁 앱 이름, 상표, 유명인 이름은 어디에도 쓰지 마세요(심사 지침 2.3.7, 5.2.1).
- [ ] **AS-11** (auto) 이름, 부제, 키워드에 가격 / 순위 / 행동 유도 단어 금지: "free", "best", "#1", "sale", "% off" (2.3.7) — 어떤 언어로든 마찬가지입니다("무료", "최고", "할인" 등).
- [ ] **AS-12** (auto) 이모지 없음. Apple 상표(iPhone, Siri…)를 앱 이름의 일부처럼 쓰지 마세요.
- [ ] **AS-13** **기본 카테고리**는 가장 관련성 높은 것으로 고르세요(텍스트 관련성에 반영됨). 보조 카테고리도 설정하세요.
- [ ] **AS-14** 설명: 첫 3줄에 주요 용도와 근거를 쓰고, 훑어보기 쉬운 글머리 기호로 정리하세요. 키워드를 채우는 용도로 쓰지 마세요(App Store 검색 색인 대상 아님). 다만 Google 웹 검색과 Apple의 태그 생성기는 이 글을 읽습니다.
- [ ] **AS-15** 프로모션 텍스트는 최신 소식 / 혜택에 쓰세요(심사 없이 변경 가능).
- [ ] **AS-16** (auto) 개인정보 처리방침 URL과 지원 URL은 https여야 합니다. (수동) 둘 다 실제로 열리는지 확인하세요.
- [ ] **AS-17** 인앱 구매 표시 이름은 사용자가 얻는 것을 설명하고, 자연스럽다면 검색어를 넣으세요("습관 트래커 Pro").
- [ ] **AS-18** 인앱 이벤트(있다면): 30자 이벤트 이름에 키워드를 넣으세요. 동시에 최대 10개까지 게시할 수 있습니다.
- [ ] **AS-19** **앱 태그(App tags)**(미국 스토어프런트, en-US 메타데이터): App Store Connect에서 검토하고 잘못된 태그는 선택 해제하세요(태그를 직접 추가할 수는 없으니 en-US 설명에 사용 사례를 분명하게 적으세요).
- [ ] **AS-20** 연령 등급 설문을 2025년 등급 체계(4+ / 9+ / 13+ / 16+ / 18+)에 맞춰 답하세요.

## 3. Google Play 메타데이터 (언어별)

- [ ] **GP-01** (auto) 제목 ≤ 30, 간단한 설명 ≤ 80, 자세한 설명 ≤ 4000, 출시 노트 ≤ 500.
- [ ] **GP-02** (auto) 제목과 간단한 설명을 ≥ 90% 채우세요.
- [ ] **GP-03** 제목 = 브랜드 + 대표 키워드. 간단한 설명 = 보조 키워드 2–3개와 핵심 이점을 담은 제대로 된 문장 하나.
- [ ] **GP-04** (auto) 제목의 키워드가 자세한 설명에, 그것도 처음 ~300자 안에 나와야 합니다.
- [ ] **GP-05** 목표 키워드마다 자세한 설명에 자연스럽게 2–3번 넣고, 관련어와 동의어도 쓰세요. 키워드 나열은 금지입니다.
- [ ] **GP-06** (auto) 밀도가 ~3%를 넘는 단어 없음(키워드 남용은 정책 위반).
- [ ] **GP-07** (auto) 제목 / 간단한 설명 / 개발자 이름: 이모지 없음, 반복 특수문자(`!!!`, `★★`) 없음, 모두 대문자(ALL CAPS) 없음(브랜드명이면 예외).
- [ ] **GP-08** (auto) 제목, 아이콘, 개발자 이름에 "Free", "#1", "Best", "Top", "Popular", "New", "Editor's choice", "No ads", 가격, 프로모션 금지 — 모든 번역본에서도 마찬가지입니다("무료", "최고", "인기", "신규", "에디터 추천", "광고 없음" 등).
- [ ] **GP-09** 설명에 출처 없는 추천 글이나 익명 사용자 인용문을 넣지 마세요.
- [ ] **GP-10** 자세한 설명은 구조를 갖추세요: 도입부(2줄) → 소제목 / 글머리 기호로 정리한 주요 기능 → 근거 → 행동 유도. Ask Play / AI 하이라이트가 이 글을 읽으므로 LLM이 그대로 인용할 수 있는 평이한 문장("X로 …하세요")을 쓰세요.
- [ ] **GP-11** 스토어 설정(Store settings)에서 카테고리와 **태그**를 최대 5개까지 설정하세요.
- [ ] **GP-12** 연락처 이메일, 웹사이트, 개인정보 처리방침을 채우세요. 웹사이트에서도 앱을 설명해야 합니다(Ask Play가 읽음).
- [ ] **GP-13** 데이터 보안(Data safety) 양식을 빠짐없이, 앱의 실제 동작과 일치하게 작성하세요.

## 4. 현지화

- [ ] **L10N-01** 우선 시장마다 전용 스토어 등록 정보를 두세요 — Play 자동 번역도, 영어 그대로도 안 됩니다.
- [ ] **L10N-02** (auto) 키워드 필드 / 간단한 설명을 기본 언어에서 **복사하지 마세요**.
- [ ] **L10N-03** 현지 자동완성과 현지 경쟁 앱에서 찾은 현지 검색어를 쓰세요(KW-09).
- [ ] **L10N-04** App Store **교차 현지화(cross-localization)**: 우선 스토어프런트마다 Apple이 그곳에서 추가로 색인하는 언어를 정리하고(US: en-US + es-MX, ar, zh-Hans, zh-Hant, fr-FR, ko, pt-BR, ru, vi; UK: en-GB; CA: en-CA + fr-CA; JP: ja + en-US; 그 밖의 대부분: 현지 언어 + en-GB), 언어마다 **서로 다른** 키워드 필드 단어를 넣으세요.
- [ ] **L10N-05** 교차 현지화에 쓰는 언어도 그 언어 원어민이 읽기에 자연스러워야 합니다(실제 사용자가 봅니다).
- [ ] **L10N-06** (auto) CJK / 태국어 / 아랍어 등록 정보도 제한까지 채우세요 — 이런 언어에서 짧게 남긴 항목이 가장 흔한 낭비입니다.
- [ ] **L10N-07** 우선 언어의 스크린샷과 캡션을 현지화하세요. 아랍어 / 히브리어는 오른쪽에서 왼쪽(RTL) 레이아웃을 쓰세요.
- [ ] **L10N-08** 과장 표현을 현지 언어로도 확인하세요("miễn phí", "gratis", "無料", "무료", "免费"…).

## 5. 아이콘, 스크린샷, 동영상

- [ ] **CR-01** 아이콘: 분명한 상징 하나, 글자 없음, 40 px에서도 알아볼 수 있음, 상위 10개 경쟁 앱 아이콘과 나란히 놓아도 구별됨.
- [ ] **CR-02** iOS 26: 레이어 구조의 Liquid Glass 아이콘을 라이트, 다크, 틴티드, 클리어 모드에서 모두 확인하세요.
- [ ] **CR-03** (auto, Play) 아이콘 512×512 PNG. 그래픽 이미지(feature graphic) 1024×500, 알파 채널 없음, 순위 / 가격 / 수상 표현 없음.
- [ ] **CR-04** 스크린샷 1은 ≤ 5단어 캡션에 대표 키워드를 넣어 **주요 용도**를 보여 주세요. 이 한 장만으로도 검색 결과에서 의미가 전달되어야 합니다.
- [ ] **CR-05** 스크린샷 2–3은 설치할 다음 이유 두 가지를 보여 주세요. 스크린샷 한 장에 이점 하나.
- [ ] **CR-06** 실제 앱 UI를 쓰세요(App Store 2.3.3). Play 캡션은 이미지의 ≤ 20%. "Download now", "#1", "Best", 스토어 배지 금지("지금 다운로드", "최고" 등).
- [ ] **CR-07** App Store: 6.9" iPhone 세트(1320×2868 / 1290×2796 / 1260×2736), iPad에서 실행되는 앱이면 13" iPad 세트(2064×2752 / 2048×2732)도. 각각 최대 10장, 알파 채널 없음.
- [ ] **CR-08** (auto) Play: 휴대전화 스크린샷 2–8장, 각 변 320–3840 px, 긴 변 ≤ 짧은 변의 2×. 추천(featuring) 대상이 되려면 ≥ 1080 px(9:16 또는 16:9) 스크린샷이 ≥ 4장. 지원한다면 태블릿 / Chromebook / Wear 세트도(폼 팩터별로 표시됨).
- [ ] **CR-09** 동영상(선택, 테스트해 보세요): App Store 미리보기는 15–30초, 화면 녹화만, 처음 3초 안에 소리 없이도 용도가 보여야 합니다. Play YouTube 링크는 공개 / 일부 공개, 광고 끔, 처음 30초가 중요합니다.
- [ ] **CR-10** 크리에이티브를 키워드 맵에 맞추세요: 사람들이 검색한 바로 그것을 스크린샷 1이 보여 줘야 합니다.

## 6. 맞춤 페이지와 실험

- [ ] **EXP-01** 주요 키워드 검색 의도별로 App Store **맞춤형 제품 페이지(custom product pages)**(최대 70개)를 만들고, 각 페이지에 승인된 키워드 필드의 키워드를 지정하세요.
- [ ] **EXP-02** 가치 높은 검색 키워드 / 국가 / 이탈 사용자를 위한 Google Play **맞춤 스토어 등록 정보(custom store listings)**(최대 50개).
- [ ] **EXP-03** 최상위 시장에서는 항상 실험 하나를 돌리세요: App Store 제품 페이지 최적화(product page optimization; 대체 버전 ≤ 3개, ≤ 90일) 또는 Play 스토어 등록 정보 실험(store listing experiments; 변형 ≤ 2개, 제목과 동영상은 테스트 불가).
- [ ] **EXP-04** 테스트마다: 변수 하나, 글로 적은 가설, 성공 지표, ≥ 7일 진행, 콘솔이 신뢰 수준에 도달했다고 보여 줄 때만 종료.
- [ ] **EXP-05** 기대 효과가 큰 순서로 테스트하세요: 아이콘 → 스크린샷 1 → 캡션 → 스크린샷 순서 → 동영상.
- [ ] **EXP-06** 결과(승 / 패 / 차이 없음)를 기록하세요. 이긴 안은 다른 언어에 그대로 적용된다고 가정하지 말고 새 테스트로 적용합니다.

## 7. 평점과 리뷰

- [ ] **RV-01** 성공 순간 직후에 네이티브 인앱 리뷰 요청(`requestReview` / Play In-App Review API)을 띄우세요. 앱 실행 직후나 오류 직후에 띄우거나, 만족한 사용자만 골라 요청(gating)하면 안 됩니다. 보상 제공도 금지입니다.
- [ ] **RV-02** 우선 국가마다 평균 평점 ≥ 4.0(Play는 국가와 폼 팩터별로 평점을 매기며, 최근 평점의 비중이 더 큽니다).
- [ ] **RV-03** 1–3★ 리뷰에는 며칠 안에 구체적으로 답하고, 수정이 배포되면 다시 답글을 다세요.
- [ ] **RV-04** 가장 자주 반복되는 불만을 파악해 로드맵에 넣으세요 — 두 스토어의 AI 리뷰 요약이 그것을 헤드라인으로 띄웁니다.
- [ ] **RV-05** 매달 리뷰 텍스트에서 새 키워드와 기능 요청을 찾아내세요.

## 8. 품질과 기술 신호

- [ ] **Q-01** Play Android vitals를 부적절한 동작 기준 아래로 유지하세요(28일 기준): 사용자가 인지한 비정상 종료율 < 1.09%, ANR < 0.47%, 휴대전화 모델별 < 8%. 과도한 부분 wake lock은 세션의 < 5%.
- [ ] **Q-02** February 2027부터 시행되는 Play 메모리 / 비트맵 / DEX 기준에 미리 대비하세요.
- [ ] **Q-03** Play: 신규 앱 / 업데이트는 target API 36(2026-08-31부터). Apple: Xcode 26 SDK로 빌드(2026-04-28부터).
- [ ] **Q-04** 최소 1–3개월마다 앱을 업데이트하세요. 이 버전의 새로운 기능(What's New)에는 실제 변경 사항을 쓰세요(2.3.12).
- [ ] **Q-05** 다운로드 크기는 작게 유지하세요. 첫 실행 시 비정상 종료나, 가치를 보여 주기 전에 막는 로그인 장벽이 없어야 합니다.
- [ ] **Q-06** 개인정보 보호 레이블(privacy nutrition label) / 데이터 보안, 그리고 (선택, App Store) 손쉬운 사용 레이블(Accessibility Nutrition Labels)을 신고하세요.

## 9. 정책 — 거부·삭제 방지 점검

- [ ] **POL-01** 오해를 부르는 표현, 가짜 리뷰, 검증할 수 없는 "#1" / "best", 이름 / 제목 속 가격 금지(App Store 2.3.1, 2.3.7; Play 메타데이터 정책).
- [ ] **POL-02** App Store 메타데이터에 다른 플랫폼 이름 금지("Android", "Google Play") (2.3.10).
- [ ] **POL-03** 타사 상표나 모방한 이름 금지(5.2.1; Play 사칭 정책).
- [ ] **POL-04** "For Kids" / "For Children"("어린이용")은 키즈 카테고리에서만 쓰세요(2.3.8).
- [ ] **POL-05** 스크린샷 / 미리보기: 스플래시나 로그인 화면만이 아니라 앱을 실제로 사용하는 모습(2.3.3, 2.3.4).
- [ ] **POL-06** 모든 번역본도 같은 규칙을 따라야 합니다(Play는 언어별로 정책을 적용).

## 10. 측정과 반복

- [ ] **M-01** App Store Connect → 분석(Analytics): App Store 검색 노출수, 제품 페이지 조회수, 전환율, 다운로드 수 — 국가별, 맞춤형 제품 페이지별로.
- [ ] **M-02** Play Console → 성장 개요(Grow overview) / 통계(Statistics): **검색어**별·트래픽 소스별 획득(스토어 분석(Store analysis)은 June 2026에 종료, 등록 정보 지표는 July 2026에 순 사용자 클릭(unique user clicks) 기준으로 변경 — 이 시점 전후를 비교하지 마세요).
- [ ] **M-03** 키워드 맵의 키워드 순위를 추적하세요(순위 추적 도구, Apple Ads 검색어 보고서, 또는 매달 자동완성 재조사).
- [ ] **M-04** 한 번에 항목 그룹 하나만 바꾸세요. 판단하기 전에 2–4주 기다리세요. App Store 이름 / 부제 / 키워드는 새 버전을 낼 때만 바뀝니다.
- [ ] **M-05** 매달: 4–6주가 지나도 노출이 없는 키워드 필드 단어는 빼고, 다음 후보를 넣고, 경쟁 앱과 계절성을 다시 확인하세요.

---

## 보고서 템플릿

```markdown
# ASO 점검 — <앱> — <날짜>

스토어: <App Store / Google Play> · 언어: <목록> · 모드: <점검 / 수정>

## 점수
<통과>/<전체> 항목 · <n> ❌ · <n> ⚠️ · 스크립트: <aso_check 점수 줄>

## 항목별 글자 수
| 스토어 | 언어 | 이름/제목 | 부제/간단한 설명 | 키워드 | 설명 |
|---|---|---|---|---|---|
| App Store | en-US | 28/30 ✅ | 30/30 ✅ | 97/100 ✅ | 3120/4000 ✅ |

## 문제 (영향 큰 순)
| ID | 상태 | 스토어 · 언어 · 파일 | 근거 | 수정안 (제한 이내) |
|---|---|---|---|---|
| AS-06 | ❌ | App Store · en-US · keywords.txt | 이름에도 "tracker"가 있음 | "routine"으로 교체 (+7자) |

## 키워드 맵 (우선 언어별)
| 키워드 | 관련성 | 자동완성 순위 | 공략 여지 | 항목 |

## 다음 3가지 작업
1. …
```

## 출처

- Apple: [검색](https://developer.apple.com/app-store/search/) ·
  [플랫폼 버전 정보](https://developer.apple.com/help/app-store-connect/reference/platform-version-information) ·
  [App Store 현지화](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) ·
  [심사 지침](https://developer.apple.com/app-store/review/guidelines/) ·
  [스크린샷 사양](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/) ·
  [맞춤형 제품 페이지](https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions/) ·
  [앱 태그](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags)
- Google: [스토어 등록 정보 권장사항](https://support.google.com/googleplay/android-developer/answer/13393723) ·
  [메타데이터 정책](https://support.google.com/googleplay/android-developer/answer/9898842) ·
  [미리보기 애셋](https://support.google.com/googleplay/android-developer/answer/9866151) ·
  [맞춤 스토어 등록 정보](https://support.google.com/googleplay/android-developer/answer/9867158) ·
  [스토어 등록 정보 실험](https://support.google.com/googleplay/android-developer/answer/6227309) ·
  [Android vitals](https://developer.android.com/topic/performance/vitals) ·
  [Play의 새로운 소식](https://google.play/business/whats-new/)
- 스토어별 세부 사항과 날짜: [`references/app-store.md`](../references/app-store.md),
  [`references/google-play.md`](../references/google-play.md),
  [`references/conversion.md`](../references/conversion.md),
  [`references/keyword-research.md`](../references/keyword-research.md),
  [`references/tools.md`](../references/tools.md).
