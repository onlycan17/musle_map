import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

enum MuscleSide { left, right, center }

@immutable
class Muscle {
  const Muscle({
    required this.id,
    required this.koreanName,
    required this.latinName,
    required this.side,
    required this.polygon,
  });

  final String id;
  final String koreanName;
  final String latinName;
  final MuscleSide side;
  final List<Offset> polygon;

  Path toPath() {
    final path = Path();
    if (polygon.isEmpty) return path;
    path.moveTo(polygon.first.dx, polygon.first.dy);
    for (var i = 1; i < polygon.length; i++) {
      path.lineTo(polygon[i].dx, polygon[i].dy);
    }
    path.close();
    return path;
  }
}
