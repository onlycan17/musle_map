# musle_map

인체 정면/후면 라인 도식 위에 약한 근육과 통증 또는 과활성 근육을 표시하는 Flutter 앱입니다.

## 주요 기능

- 사용자 등록 및 사용자별 근육 표시 저장
- 사용자 정보에서 선택 입력 생년월일 저장
- 파란색: 약한 근육
- 빨간색 채움: 풀어야 할 근육 또는 과활성 근육
- 빨간색 원형 포인트: 정확한 통증 부위 표시
- 정면/후면 근육 도식 전환
- 현재 상태를 히스토리로 저장
- 과거 기록을 현재 상태와 비교하거나 현재 상태로 복원
- `shared_preferences` 기반 로컬 저장
- 이미지 경계선 내부 픽셀 마스크 기준으로 색상 표시
- iPad/태블릿 가로 화면에서는 앱이 화면 전체를 사용하며 좌측 조작 패널과 우측 큰 인체 표시 영역으로 자동 전환

## 실행

```bash
flutter pub get
flutter run
```

Android 빌드는 Android Gradle Plugin `8.9.1`과 호환되도록 Gradle wrapper `8.11.1`을 사용합니다.

## 검증

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

## 참고

근육 도식은 배경 이미지와 클릭 가능한 픽셀 마스크를 분리해 관리합니다. 배경 이미지는 사용자 제공 첨부 이미지를 전면/후면으로 분리해 재생성했으며, 클릭/채색 영역은 `assets/images/body_front_regions.png`와 `assets/images/body_back_regions.png`의 마스크 색상으로 판별합니다.
