# 근육 학습 지도

인체 정면·후면 도식에서 근육의 위치와 명칭을 익히고 주석을 남기는 Flutter 해부학 학습 앱입니다.

## 주요 기능

- 파란색으로 학습 완료 근육 표시
- 빨간색으로 관심 근육 표시
- 도식 위에 학습 포인트 추가
- 주제별 학습 노트와 학습 기록 저장
- 이전 학습 기록 비교 및 복원
- 정면·후면 근육 도식 전환
- `shared_preferences` 기반 로컬 저장
- 이미지 경계선 내부 픽셀 마스크 기준으로 색상 표시
- 폰(최단 변 600 미만)은 세로 모드 고정이며, 웹 등 회전 잠금이 불가능한 환경에서는 가로 전환 시 세로 회전 안내를 표시
- iPad/태블릿 가로 화면에서는 앱이 화면 전체를 사용하며 좌측 조작 패널과 우측 큰 인체 표시 영역으로 자동 전환

## 실행 및 검증

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

Google Play 출시 빌드는 Android 16(API 36)을 대상으로 하며, 업로드 키 정보는
`MUSCLE_MAP_UPLOAD_STORE_FILE`, `MUSCLE_MAP_UPLOAD_STORE_PASSWORD`,
`MUSCLE_MAP_UPLOAD_KEY_ALIAS`, `MUSCLE_MAP_UPLOAD_KEY_PASSWORD` 환경 변수로
전달해야 합니다. 저장소에 업로드 키나 비밀번호를 추가하지 마세요.

스토어 등록 문구는 [`docs/PLAY_STORE_LISTING.md`](docs/PLAY_STORE_LISTING.md), 개인정보 처리 기준은 [`docs/PRIVACY_POLICY.md`](docs/PRIVACY_POLICY.md)에서 확인할 수 있습니다.

## 참고

근육 도식은 배경 이미지와 클릭 가능한 픽셀 마스크를 분리해 관리합니다. 배경 이미지는 사용자 제공 첨부 이미지를 전면/후면으로 분리해 재생성했으며, 클릭/채색 영역은 `assets/images/body_front_regions.png`와 `assets/images/body_back_regions.png`의 마스크 색상으로 판별합니다.
