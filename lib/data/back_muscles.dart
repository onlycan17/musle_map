import 'package:flutter/painting.dart';

import '../models/body_view.dart';

const Size _backReferenceSize = Size(500, 1172);
const double _backAxisX = 250;
const String _backAsset = 'assets/images/body_back.png';
const String _backRegionMask = 'assets/images/body_back_regions.png';

BodyViewConfig buildBackViewConfig() => const BodyViewConfig(
  view: BodyView.back,
  assetPath: _backAsset,
  regionMaskPath: _backRegionMask,
  referenceSize: _backReferenceSize,
  bodyAxisX: _backAxisX,
  muscles: [],
);
