import 'package:flutter/painting.dart';

/// x = axisX 기준으로 점을 미러링.
Offset mirrorAround(Offset p, double axisX) => Offset(2 * axisX - p.dx, p.dy);

List<Offset> mirrorPolygon(List<Offset> polygon, double axisX) =>
    polygon.map((p) => mirrorAround(p, axisX)).toList(growable: false);
