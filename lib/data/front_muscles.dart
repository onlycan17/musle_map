import 'package:flutter/painting.dart';

import '../models/body_view.dart';

const Size _frontReferenceSize = Size(500, 1089);
const double _frontAxisX = 250;
const String _frontAsset = 'assets/images/body_front.png';
const String _frontRegionMask = 'assets/images/body_front_regions.png';

BodyViewConfig buildFrontViewConfig() => const BodyViewConfig(
  view: BodyView.front,
  assetPath: _frontAsset,
  regionMaskPath: _frontRegionMask,
  referenceSize: _frontReferenceSize,
  bodyAxisX: _frontAxisX,
  muscles: [],
);
