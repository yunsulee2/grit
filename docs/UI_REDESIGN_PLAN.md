# GRIT UI 리디자인 종합 계획서

> 작성일: 2026-02-26
> 작성자: Senior Design Team (AI Agent)
> 대상: GRIT 피트니스 공동구매 플랫폼 (Flutter Web)

---

## 1. 현재 상태 진단

### 1.1 핵심 수치 (코드 분석 기반)

| 항목 | 수치 | 심각도 |
|------|------|--------|
| AppTextStyles 사용률 | **0건 / 15개 스크린** | CRITICAL |
| 하드코딩 컬러 (Colors.white, Color(0xFF...)) | **129건** | HIGH |
| fontSize 하드코딩 | **249건** (screens 162 + widgets 87) | HIGH |
| BorderRadius 종류 | **11가지** (2,3,4,5,6,8,10,12,16,20,22) | HIGH |
| 반응형 maxWidth 적용 화면 | **2개 / 15개** | HIGH |
| AppColors 사용률 | 381건 (양호, 하지만 혼재) | MEDIUM |

### 1.2 근본 문제 3가지

**문제 1: 디자인 시스템이 존재하지만 적용되지 않음**
- `app_typography.dart`에 완벽한 타입 스케일(20개 스타일)이 정의되어 있으나, 전체 앱에서 **단 한 번도 참조되지 않음**
- `app_colors.dart`에 토큰이 정의되어 있으나, 화면들은 `Colors.white`, `Color(0xFF333333)` 등 하드코딩 혼재

**문제 2: 테마 정체성 분열 (다크 vs 라이트) — 근본 원인**
- 디자인 토큰: 다크 테마 (Obsidian #0D0F0E 배경)
- 실제 GNB: `Colors.white` 배경 (`gnb.dart:35`)
- FundCard: `Colors.white` 배경 (`fund_card.dart:70`) + `Color(0xFF333333)` 텍스트
- AppShell: `Colors.white` 배경 (`app_shell.dart:32`)
- FilterChipsBar: `Color(0xFFFFF3EC)` 활성배경 (`filter_chips_bar.dart:62`) — 라이트용 피치 색상
- FundDetail 공유배너: `Color(0xFFEBF5FB)` (`fund_detail_screen.dart:782`) — 라이트블루
- → **"디자인 시스템은 다크, 실제 UI는 라이트"** 라는 정체성 분열이 "올드하다"는 피드백의 근본 원인

**문제 2-1: Breakpoint 4종류 혼재**
- `gnb.dart:30` → 768px
- `home_screen.dart:70-71` → 960px / 768px
- `fund_detail_screen.dart:98` → 960px
- `url_scrape_screen.dart:116` → 800px

**문제 2-2: 폼 컴포넌트 4중 중복**
- `seller_fund_form_screen.dart:1186` → `_StyledTextField` (borderRadius 8)
- `seller_apply_screen.dart:247` → `_FormField` (borderRadius 10)
- `profile_edit_screen.dart:150` → `_buildField` (borderRadius 10)
- `inquiry_screen.dart:114` → 인라인 TextFormField (borderRadius 10)

**문제 3: 반응형 미적용**
- 홈/상세 페이지만 maxWidth: 1280 적용
- 나머지 13개 화면은 무한 확장 → 데스크톱에서 비정상적으로 넓어짐
- 일관된 breakpoint 시스템 부재

### 1.3 화면별 문제 상세

| 화면 | 주요 문제 |
|------|-----------|
| **HomeScreen** | 상대적으로 양호. 반응형 레이아웃 있음. 단, 하드코딩 스타일 |
| **FundDetailScreen** | 1100줄+. 하드코딩 19건. 다크/라이트 혼재 심각 |
| **CategoryScreen** | maxWidth 미적용. 데스크톱에서 카드 2열 고정 |
| **MyPageScreen** | 패딩 불일치. 반응형 없음. 프로필 섹션 너무 단조 |
| **CartScreen** | 반응형 없음. 아이템 카드 레이아웃 비효율 |
| **SellerDashboard** | SummaryCards 고정 width(160). 반응형 미적용 |
| **SellerFundForm** | 21개 서로 다른 BorderRadius. 폼 스타일 불일치 |
| **LoginScreen** | 전체화면 폼인데 maxWidth 없음. 데스크톱에서 너무 넓음 |
| **SearchScreen** | 검색바 양호. 결과 리스트 반응형 없음 |
| **ProfileEdit** | 폼 스타일 InquiryScreen과 다름 |
| **AddressScreen** | 카드 레이아웃 단조. 반응형 없음 |
| **InquiryScreen** | 폼 스타일 ProfileEdit와 약간 다름 |

---

## 2. 디자인 방향 결정

### 2.1 라이트 테마 전환 (권장)

**결정: 다크 테마 → 라이트 테마 기반으로 전환**

#### 근거 (트렌드 리서치 + 코드 분석 종합)

**라이트 선택 이유:**
- 한국 커머스 앱(쿠팡, 무신사, 마켓컬리) 모두 라이트 테마 기반
- 한국 온라인 매출 73%가 모바일 → 모바일에서 라이트가 표준
- 식품 커머스에서 라이트 배경이 신선도/신뢰감 인식에 유리
- **실용적 이유**: 현재 구현이 이미 대부분 라이트 (GNB, FundCard, AppShell 모두 Colors.white) → 전환 비용 최소

**다크 테마 고려사항 (Researcher 분석):**
- 피트니스 브랜드에서 다크 테마는 전략적 우위 (82.7% 선호, 세션 25% 증가)
- Nike, Peloton 등 피트니스 브랜드는 다크 선호
- 단, GRIT은 "피트니스 식품 커머스" → 커머스 전환율이 더 중요
- 향후 다크 모드 토글 추가 시 바운스율 14% 감소 기대 (Phase 4에서 검토)

**유지할 것:**
- 브랜드 컬러 Acid Lime (#C6F135) → 포인트/CTA에 활용
- Noto Sans KR 폰트
- 타입 스케일 구조 (사이즈만 조정)

**변경할 것:**
- 배경: #0D0F0E → **#FFFFFF** (순백)
- Surface: #141817 → **#F7F8F9** (연한 그레이)
- 텍스트: 밝은 톤 → **#1A1A1A** (짙은 회색)
- 서브텍스트: → **#8E8E93** (시스템 그레이)

### 2.2 디자인 무드

**"Clean Performance" — 깨끗하고 기능적인 피트니스 커머스**

참고 레퍼런스:
- 쿠팡: 깔끔한 카드, 명확한 가격 표시, 효율적 정보 밀도
- 무신사: 모던한 타이포그래피, 흑백 기반 + 포인트 컬러
- 마켓컬리: 깔끔한 상품 카드, 신뢰감 있는 레이아웃
- Nike Training Club: 피트니스 감성, 강렬한 CTA

핵심 키워드: **Compact, Clean, Confident, Conversion-focused**

**2025-2026 적용 가능한 트렌드 (Researcher 조사 결과):**
- **Bento Grid 레이아웃**: 다양한 크기 카드로 정보 스캔 속도 향상
- **발견형 쇼핑 (Discovery Commerce)**: 콘텐츠 → 자연스러운 구매 전환 (무신사 스타일)
- **공동구매 참여 카운터**: "현재 127명 참여 중" 실시간 FOMO 유발
- **마이크로인터랙션**: 호버/클릭/스크롤 반응 애니메이션 기본값
- **소셜 증명 UI**: 구매자 수, 별점, 후기 사진 상단 배치
- **라이브 커머스 섹션**: 한국 라이브커머스 시장 연 36% 성장 (향후 추가 검토)

---

## 3. 새 디자인 시스템

### 3.1 컬러 팔레트 (Light Mode)

```dart
class AppColors {
  // ── Brand ──
  static const primary = Color(0xFF1A1A1A);     // 메인 액션 (검정 기반)
  static const accent = Color(0xFFC6F135);       // 포인트 (Acid Lime 유지)
  static const accentDark = Color(0xFF9BBF00);   // 액센트 hover

  // ── Background ──
  static const background = Color(0xFFFFFFFF);   // 순백
  static const surface = Color(0xFFF7F8F9);      // 카드/섹션 배경
  static const surfaceElevated = Color(0xFFFFFFFF); // 올린 카드 (그림자)

  // ── Text ──
  static const textPrimary = Color(0xFF1A1A1A);   // 제목, 가격
  static const textSecondary = Color(0xFF8E8E93);  // 부제, 메타
  static const textTertiary = Color(0xFFAEAEB2);   // 비활성
  static const textInverse = Color(0xFFFFFFFF);     // 어두운 배경 위

  // ── Semantic ──
  static const error = Color(0xFFFF3B30);           // iOS 레드
  static const success = Color(0xFF34C759);         // iOS 그린
  static const warning = Color(0xFFFF9500);         // iOS 오렌지
  static const info = Color(0xFF007AFF);            // iOS 블루

  // ── Border ──
  static const border = Color(0xFFE5E5EA);          // 기본 테두리
  static const borderSubtle = Color(0xFFF2F2F7);    // 은은한 구분선
  static const borderFocus = Color(0xFF1A1A1A);     // 포커스

  // ── Discount/Price ──
  static const priceRed = Color(0xFFFF3B30);        // 할인율
  static const priceAccent = Color(0xFFC6F135);     // 최대혜택가 배지
}
```

### 3.2 타이포그래피 스케일 (조정)

```dart
class AppTextStyles {
  // ── 디스플레이 (히어로, 대형 수치) ──
  static const displayLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5);
  static const displayMedium = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3);

  // ── 제목 ──
  static const titleLarge = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3);
  static const titleMedium = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.35);
  static const titleSmall = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4);

  // ── 본문 ──
  static const bodyLarge = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);
  static const bodyMedium = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);

  // ── 라벨 ──
  static const labelLarge = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3);
  static const labelMedium = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.3);
  static const labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.3);

  // ── 가격 ──
  static const priceHero = TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.3);
  static const priceCard = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.25);
  static const priceStrike = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, decoration: TextDecoration.lineThrough);

  // ── 캡션 ──
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, height: 1.3);
}
```

**변경 포인트:**
- h1: 40→20, h2: 28→17, h3: 22→15 (전반적으로 축소)
- display: 64→32 (거의 절반 축소)
- priceHero: 32→24
- 전체적으로 **모바일-퍼스트** 사이즈로 조정

### 3.3 간격 시스템 (4pt Grid)

```dart
class AppSpacing {
  static const xs = 4.0;    // 아이콘-텍스트 간격
  static const sm = 8.0;    // 칩 내부, 요소 간 최소 간격
  static const md = 12.0;   // 카드 내부 패딩
  static const lg = 16.0;   // 섹션 패딩, 카드 간격
  static const xl = 20.0;   // 페이지 수평 패딩
  static const xxl = 24.0;  // 섹션 간 간격
  static const xxxl = 32.0; // 큰 섹션 구분
}
```

**규칙:**
- 페이지 수평 패딩: 항상 `xl` (20px)
- 카드 내부 패딩: 항상 `md` (12px) 또는 `lg` (16px)
- 요소 간 간격: `sm` (8px) 또는 `md` (12px)
- 섹션 간 간격: `xxl` (24px)

### 3.4 BorderRadius 체계 (4단계로 통일)

```dart
class AppRadius {
  static const xs = 4.0;    // 뱃지, 작은 태그
  static const sm = 8.0;    // 칩, 인풋 필드
  static const md = 12.0;   // 카드, 컨테이너
  static const lg = 16.0;   // 모달, 바텀시트
  static const full = 999.0; // 원형 (필/아바타)
}
```

**현재 11가지 → 5가지로 통일**

### 3.5 카드 스타일

```dart
// 기본 카드 (그림자 기반, border 제거)
BoxDecoration cardDefault = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(AppRadius.md),
  boxShadow: [
    BoxShadow(
      color: Color(0x0A000000),  // 매우 은은한 그림자
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: Color(0x05000000),
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ],
);

// 호버/강조 카드
BoxDecoration cardElevated = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(AppRadius.md),
  boxShadow: [
    BoxShadow(
      color: Color(0x12000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Color(0x08000000),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ],
);
```

**변경: border 기반 → shadow 기반 (모던한 느낌)**

### 3.6 버튼 스타일

```dart
// Primary CTA (검정 배경 + 흰 텍스트)
ElevatedButton.styleFrom(
  backgroundColor: AppColors.primary,        // #1A1A1A
  foregroundColor: AppColors.textInverse,    // white
  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
  elevation: 0,
  textStyle: AppTextStyles.labelLarge,
);

// Secondary (아웃라인)
OutlinedButton.styleFrom(
  side: BorderSide(color: AppColors.border),
  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
  textStyle: AppTextStyles.labelLarge,
);

// Accent CTA (라임 배경 - 특별 프로모션용)
ElevatedButton.styleFrom(
  backgroundColor: AppColors.accent,         // Acid Lime
  foregroundColor: AppColors.primary,        // 검정 텍스트
  elevation: 0,
);
```

### 3.7 인풋 필드 통합 스타일

```dart
InputDecoration appInputDecoration({String? hint}) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
  filled: true,
  fillColor: AppColors.surface,
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.sm),
    borderSide: BorderSide(color: AppColors.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.sm),
    borderSide: BorderSide(color: AppColors.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.sm),
    borderSide: BorderSide(color: AppColors.borderFocus, width: 1.5),
  ),
);
```

---

## 4. 반응형 전략

### 4.1 Breakpoints

```dart
class AppBreakpoints {
  static const mobile = 0;      // 0~599
  static const tablet = 600;    // 600~959
  static const desktop = 960;   // 960+
}
```

### 4.2 레이아웃 규칙

| 요소 | Mobile (<600) | Tablet (600~959) | Desktop (960+) |
|------|---------------|------------------|-----------------|
| **maxWidth** | 100% | 100% | 960px (컨텐츠) |
| **페이지 패딩** | 16px | 20px | 24px |
| **카드 그리드** | 2열 | 3열 | 4열 |
| **GNB** | 로고 + 아이콘 | 로고 + 축약 메뉴 | 풀 메뉴 |
| **상세 페이지** | 단일 컬럼 | 단일 컬럼 | 좌/우 분할 (이미지|정보) |
| **폼 페이지** | 전폭 | maxWidth: 560px | maxWidth: 560px |
| **사이드 패널** | 없음 | 없음 | 280px 사이드바 |

### 4.3 공통 래퍼

```dart
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  // 모든 화면에 적용하는 반응형 래퍼
  Widget build(context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
```

---

## 5. 화면별 리디자인 명세

### 5.1 GNB (Global Navigation Bar)

**현재 문제:**
- Colors.white 하드코딩 (7건)
- 모바일에서 nav items 숨기지만 구조 비효율
- 로고 스타일이 Bebas Neue 정의되어 있으나 실제 일반 TextStyle 사용

**변경안:**
```
┌─────────────────────────────────────────────┐
│ GRIT%  [홈][카테고리][랭킹]    🔍 🛒 로그인 │
└─────────────────────────────────────────────┘
높이: 52px (56→52 축소)
배경: #FFFFFF + 하단 1px #E5E5EA border
로고: 'GRIT' Noto Sans KR w900 + '%' Acid Lime
네비 텍스트: 13px w500 → 활성: w700 + 하단 2px 검정 indicator
아이콘: 22px (24→22 축소)
```

### 5.2 FundCard (상품 카드)

**현재 문제:**
- 이미지 비율 0.8 → 너무 큰 이미지
- Colors.white 하드코딩 13건
- 가격 표시 3줄 (공구가 + 원가 + 최대혜택가) → 복잡

**변경안:**
```
┌─────────────────────┐
│ [이미지 1:1 비율]    │  ← 0.8 → 1.0 변경
│  ⏰ 마감 2일전       │
├─────────────────────┤
│ 브랜드명             │  ← 11px #8E8E93
│ 상품명 최대 2줄...   │  ← 13px w500 #1A1A1A
│                     │
│ 38% 12,900원        │  ← 할인율 빨강 + 가격 볼드
│ ~~19,900원~~        │  ← 취소선
└─────────────────────┘
카드: 배경 white, shadow 기반, border 제거
이미지: radius 12px (상단만), 1:1
패딩: 12px
태그: 작은 회색 라운드 뱃지
```

### 5.3 FundDetailScreen (상품 상세)

**현재 문제:**
- 1100줄+, 하드코딩 심각
- 가격/참여 정보 섹션이 너무 큼
- 반응형은 있지만 불완전

**변경안:**
- 이미지 캐러셀: 높이 360px (모바일), 480px (데스크톱)
- 가격 영역: compact하게 2줄로
- 참여 진행바: 높이 4px (6→4 축소), 라운드
- 섹션 간격: 24px 균일
- 탭 바 (상세/리뷰/배송): 모던한 underline tab
- sticky CTA 바: 높이 64px, 그림자

### 5.4 CategoryScreen

**현재 문제:**
- maxWidth 미적용 → 데스크톱에서 과도하게 넓음
- 카드 그리드 2열 고정
- 정렬 드롭다운 스타일 올드

**변경안:**
- maxWidth: 960px 적용
- 그리드: 모바일 2열, 태블릿 3열, 데스크톱 4열
- 카테고리 칩: 높이 36px (48→36), 더 컴팩트
- 정렬: 모던한 세그먼트 컨트롤 스타일

### 5.5 MyPageScreen

**현재 문제:**
- 프로필 섹션 단조
- 반응형 없음
- 메뉴 섹션이 탭 내부에 있어 UX 혼란

**변경안:**
- 프로필: 좌측 아바타 + 우측 이름/이메일 (현재 유지하되 크기 조정)
- 주문 현황: 가로 스크롤 카드 → 탭 유지하되 탭 높이 축소
- 메뉴: 탭 밖으로 분리, 독립 섹션
- maxWidth: 560px (폼 페이지 취급)

### 5.6 CartScreen

**변경안:**
- maxWidth: 560px
- 아이템 카드: 이미지 48px (56→48), 더 compact
- 수량 stepper: 높이 28px 유지하되 스타일 모던화
- 결제 바: sticky bottom, 깔끔한 2줄 (총액 + 버튼)

### 5.7 SellerDashboard

**변경안:**
- SummaryCard: 고정 width 160 → flex, 반응형 그리드
- 펀드 목록: maxWidth: 720px
- 진행바: 색상 통일 (Acid Lime 대신 시맨틱 컬러)
- FAB: 바텀 CTA 바로 변경 (FAB는 모바일 앱 패턴)

### 5.8 SellerFundForm

**변경안:**
- maxWidth: 560px 센터 정렬
- 스텝 인디케이터: 더 컴팩트 (연결선 + 원형 넘버)
- 폼 필드: 통일된 AppInputDecoration 적용
- 21가지 BorderRadius → 2가지(sm, md)로 통일

### 5.9 LoginScreen

**변경안:**
- maxWidth: 400px (로그인은 좁게)
- 로고: 더 크게, 여백 충분히
- 소셜 버튼: 높이 48px (52→48), radius 12px 통일
- 구분선: "또는" 디바이더 추가

### 5.10 폼 화면들 (ProfileEdit, AddressScreen, InquiryScreen)

**공통 변경:**
- maxWidth: 560px
- 공통 AppInputDecoration 적용 (현재 각 화면마다 중복 정의)
- 라벨: AppTextStyles.labelMedium 적용
- 저장 버튼: 통일된 스타일

---

## 6. 구현 우선순위

### Phase 1: 디자인 시스템 기반 (즉시, 임팩트 최대)

1. **`app_colors.dart` 라이트 테마 전환** — 컬러 토큰 전면 교체
2. **`app_theme.dart` 강화** — 컴포넌트별 테마 (AppBar, Card, Input, Button, Tab 등)
3. **`app_typography.dart` 사이즈 조정** — 축소된 타입 스케일
4. **`app_spacing.dart` 신규** — 간격 토큰
5. **`app_radius.dart` 신규** — 4단계 radius 토큰
6. **`app_decorations.dart` 신규** — 카드, 인풋 공통 데코레이션
7. **`responsive_container.dart` 신규** — 반응형 래퍼 위젯

**예상 효과: 전체 앱의 기본 비주얼이 일괄 변경됨**

### Phase 2: 핵심 화면 리디자인 (1주)

1. **GNB** — 라이트 테마, 컴팩트 사이즈
2. **BottomTabBar** — 테마 토큰 적용
3. **FundCard** — 새 카드 스타일, 이미지 비율, 가격 레이아웃
4. **HomeScreen** — 디자인 토큰 전면 적용
5. **FundDetailScreen** — 하드코딩 제거, 컴팩트 레이아웃
6. **CategoryScreen** — 반응형 그리드, maxWidth

### Phase 3: 서브 화면 정리 (1주)

1. **MyPageScreen** — 메뉴 분리, 반응형
2. **CartScreen** — 반응형, 컴팩트
3. **SellerDashboard** — 반응형 카드
4. **SellerFundForm** — 통일된 폼 스타일
5. **LoginScreen** — maxWidth, 모던 소셜 버튼
6. **나머지 폼 화면들** — AppInputDecoration 일괄 적용

### Phase 4: 마이크로 인터랙션 (선택)

1. 카드 hover 효과 (그림자 확대)
2. 탭 전환 애니메이션
3. 스크롤 기반 GNB 축소
4. 페이지 전환 트랜지션
5. 스켈레톤 로딩

---

## 7. 새로 만들어야 할 파일

```
lib/theme/
├── app_colors.dart        # 수정 (라이트 테마)
├── app_theme.dart         # 대폭 강화
├── app_typography.dart    # 사이즈 조정
├── app_spacing.dart       # 신규
├── app_radius.dart        # 신규
├── app_decorations.dart   # 신규 (공통 BoxDecoration, InputDecoration)
└── app_breakpoints.dart   # 신규

lib/widgets/
├── responsive_container.dart  # 신규 (반응형 래퍼)
└── app_input_field.dart       # 신규 (통일된 인풋 위젯)
```

---

## 8. 핵심 원칙 요약

1. **하드코딩 금지** — 모든 컬러, 폰트, 간격, radius는 토큰 참조
2. **라이트 테마 통일** — 다크/라이트 혼재 해소
3. **컴팩트 우선** — 현재 사이즈 대비 20~30% 축소
4. **반응형 필수** — 모든 화면에 maxWidth + breakpoint 적용
5. **그림자 기반** — border 대신 subtle shadow로 깊이 표현
6. **일관성** — BorderRadius 4단계, Spacing 7단계, Typography 12단계

---

*이 문서는 에이전트 팀의 분석 결과를 종합하여 작성되었습니다.*
*구현 시 Phase 1부터 순차적으로 진행하세요.*
