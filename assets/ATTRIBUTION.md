# 에셋 출처 및 라이선스

## app icon
- **현재 표시용 에셋**: `assets/images/app_icon.png`
- **생성 도구**: OpenAI image generation built-in tool
- **보관 원본**: `assets/source_assets/app_icon_imagegen.png`
- **적용 위치**: Android 런처 아이콘, iOS AppIcon, Web favicon/icon, 앱 헤더 로고
- **변경 사항**: 근육 지도 주제에 맞춰 전면 상체 근육과 위치 핀을 결합한 아이콘으로 교체

## images/body_front.jpg
- **기존 표시용 에셋**: 사용자 제공 라벨 포함 정면 이미지
- **보관 원본**: `assets/source_assets/body_front_labeled_original.jpg`

## images/body_front.png
- **현재 표시용 에셋**: 사용자 제공 첨부 이미지에서 전면 라인 도식을 분리한 뒤 500×1089 앱 좌표계에 맞춰 재생성.
- **생성 도구**: 로컬 이미지 처리 스크립트(Pillow)
- **참고 자료**: `/Users/ojinseog_ai/Downloads/KakaoTalk_Photo_2026-04-29-16-54-19.png`
- **보관 원본**
  - `assets/source_assets/body_front_imagegen_anterior.png`: 생성 직후 원본 이미지
  - `assets/source_assets/body_front_detailed_previous.png`: 교체 전 상세 근육 이미지 백업
- **변경 사항**: 상세 근섬유 이미지에서 첨부 이미지 형태의 흑백 라인 도식으로 교체, 도식 바깥 배경을 투명 처리

## images/body_front_regions.png
- **현재 표시용 에셋**: 전면 라인 도식의 닫힌 흰 영역을 자동 분할한 픽셀 마스크.
- **생성 도구**: 로컬 이미지 처리 스크립트(Pillow)
- **용도**: 클릭 영역 판별 및 파란색/빨간색 표시가 경계선 밖으로 넘어가지 않도록 하는 채색 마스크

## images/body_back.png
- **현재 표시용 에셋**: 사용자 제공 첨부 이미지에서 후면 라인 도식을 분리한 뒤 500×1172 앱 좌표계에 맞춰 재생성.
- **생성 도구**: 로컬 이미지 처리 스크립트(Pillow)
- **참고 자료**: `/Users/ojinseog_ai/Downloads/KakaoTalk_Photo_2026-04-29-16-54-19.png`
- **보관 원본**
  - `assets/source_assets/body_back_labeled_stretched.png`: 기존 라벨 안내선 포함 후면 PNG 백업
  - `assets/source_assets/body_back_imagegen_posterior.png`: 생성 직후 원본 이미지
  - `assets/source_assets/body_back_detailed_previous.png`: 교체 전 상세 근육 이미지 백업
- **변경 사항**: 상세 근섬유 이미지에서 첨부 이미지 형태의 흑백 라인 도식으로 교체, 도식 바깥 배경을 투명 처리

## images/body_back_regions.png
- **현재 표시용 에셋**: 후면 라인 도식의 닫힌 흰 영역을 자동 분할한 픽셀 마스크.
- **생성 도구**: 로컬 이미지 처리 스크립트(Pillow)
- **용도**: 클릭 영역 판별 및 파란색/빨간색 표시가 경계선 밖으로 넘어가지 않도록 하는 채색 마스크

> 본 앱이 배포되는 경우, CC BY-SA 4.0 라이선스에 따라
> 1) 출처 표기 의무
> 2) 동일 라이선스 적용 의무
> 가 적용됨에 유의.
