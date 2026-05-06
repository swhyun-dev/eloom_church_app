---
name: eloom-feature-migration
description: 이룸교회 Flutter 앱(eloom_church_app)의 feature를 더미 데이터에서 실제 API 연동 Repository 패턴으로 마이그레이션할 때 반드시 사용. lib/features/ 아래 폴더를 수정하거나, dummy_data.dart 참조를 제거하거나, Repository 패턴을 적용하거나, data/domain/presentation 구조로 리팩토링하거나, 새 feature를 만들 때 이 skill을 따른다. "마이그레이션", "API 연동", "더미 제거", "repository 적용", "feature 추가" 키워드에서 반드시 트리거.
---

# 이룸교회 Flutter Feature 마이그레이션 표준

## 표준 구조 (bible 모듈 레퍼런스)
lib/features/<feature명>/
├── data/
│   ├── <feature>_repository_impl.dart   # HTTP 구현
│   ├── dto/<feature>_dto.dart           # API 응답 DTO
│   └── mappers/<feature>_mapper.dart    # DTO → Domain
├── domain/
│   ├── <feature>_repository.dart        # 추상 인터페이스
│   └── models/<feature>.dart            # 도메인 모델
└── presentation/
├── controllers/<feature>_controller.dart  # Riverpod
└── pages/                            # UI

## 작업 절차

### 1. API 확인
- 백엔드 레포(eloom_app)의 apps/api/src/routes/ 에서 대응 엔드포인트 확인
- 응답 스키마는 docs/api-response-schemas.md 참조 (백엔드 레포)
- 인증 필요 여부, 권한, 페이지네이션 구조 확인
- /api/v1/ 사용 (앱용), /admin/ 사용 금지

### 2. DTO + Domain Model 정의
- DTO: API 응답과 1:1 매핑, fromJson만 신경
- Domain Model: UI 친화적 형태, immutable
- mapper에서 DTO → Domain 변환 책임 분리

### 3. Repository 인터페이스 + 구현
- 인터페이스(domain/<feature>_repository.dart)는 추상 메서드만
- 구현(data/<feature>_repository_impl.dart)은 AppHttpClient 주입
- ⚠️ Dio 직접 생성 금지 → 항상 AppHttpClient 사용

### 4. service_locator 등록
```dart
// lib/core/di/service_locator.dart
getIt.registerLazySingleton<XxxRepository>(
  () => XxxRepositoryImpl(getIt<AppHttpClient>()),
);
```

### 5. Controller (Riverpod)
- AsyncNotifierProvider 사용
- 로딩/에러/데이터를 AsyncValue로 처리
- pull-to-refresh, 페이지네이션 지원 시 별도 메서드

### 6. Page 연결
- AsyncValueBuilder (또는 .when)으로 분기
- 로딩 → 스피너, 에러 → ErrorView, 빈 데이터 → EmptyView, 데이터 → 실제 UI
- 공통 위젯은 lib/core/widgets/ 에 두고 재사용

### 7. 더미 참조 제거
- lib/dummy/dummy_data.dart의 해당 feature 부분 참조 해제
- ⚠️ dummy_data.dart 파일 자체는 절대 삭제 금지 (다른 feature 참조 중)

## 절대 금지 사항
- Page에서 직접 Dio/http 호출 (반드시 Repository 경유)
- Repository에서 토큰 직접 관리 (AppHttpClient 인터셉터가 처리)
- 더미 데이터를 Page에 하드코딩
- /admin/ 엔드포인트 호출 (앱은 /api/v1/만)
- API_BASE_URL 하드코딩 (--dart-define 사용)

## 완료 체크리스트
- [ ] `flutter analyze` 경고 0개
- [ ] 실기기/에뮬에서 화면 진입 확인
- [ ] 네트워크 끊김 시 에러 UI 노출
- [ ] 빈 데이터일 때 EmptyView 노출
- [ ] 401 응답 시 로그인 화면 이동 확인
- [ ] (백엔드 레포의) ROADMAP.md 체크박스 업데이트

## 빌드 명령 표준
```bash
# 개발 (Android 에뮬레이터)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000

# 개발 (iOS 시뮬레이터)
flutter run --dart-define=API_BASE_URL=http://localhost:4000

# 프로덕션 빌드
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.eloomtv.com
```
