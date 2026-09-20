import 'package:flutter/painting.dart';

import 'muscle.dart';

enum BodyView { front, back }

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
