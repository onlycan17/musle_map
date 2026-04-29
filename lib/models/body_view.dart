import 'package:flutter/painting.dart';

import 'muscle.dart';

enum BodyView { front, back }

extension BodyViewLabel on BodyView {
  String get koreanLabel {
    switch (this) {
      case BodyView.front:
        return '정면';
      case BodyView.back:
        return '후면';
    }
  }
}

/// 뷰별 이미지/좌표계/근육 데이터를 한 묶음으로 관리.
class BodyViewConfig {
  const BodyViewConfig({
    required this.view,
    required this.assetPath,
    required this.regionMaskPath,
    required this.referenceSize,
    required this.bodyAxisX,
    required this.muscles,
  });

  final BodyView view;
  final String assetPath;
  final String regionMaskPath;
  final Size referenceSize;
  final double bodyAxisX;
  final List<Muscle> muscles;
}
