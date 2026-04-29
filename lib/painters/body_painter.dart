import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/body_view.dart';
import '../models/muscle_mark.dart';

class CanvasTransform {
  CanvasTransform({required this.scale, required this.dx, required this.dy});

  final double scale;
  final double dx;
  final double dy;

  factory CanvasTransform.contain(Size canvasSize, Size reference) {
    final scaleW = canvasSize.width / reference.width;
    final scaleH = canvasSize.height / reference.height;
    final s = scaleW < scaleH ? scaleW : scaleH;
    final dx = (canvasSize.width - reference.width * s) / 2;
    final dy = (canvasSize.height - reference.height * s) / 2;
    return CanvasTransform(scale: s, dx: dx, dy: dy);
  }

  Offset toCanvas(Offset ref) =>
      Offset(ref.dx * scale + dx, ref.dy * scale + dy);

  Offset toReference(Offset canvas) =>
      Offset((canvas.dx - dx) / scale, (canvas.dy - dy) / scale);
}

class BodyPainter extends CustomPainter {
  BodyPainter({
    required this.config,
    required this.bodyImage,
    required this.markOverlayImage,
    required this.painPoints,
    required this.calibrationMode,
    this.baselineOverlayImage,
    this.baselinePainPoints = const <BodyPainPoint>[],
    this.lastTapPoint,
  });

  final BodyViewConfig config;
  final ui.Image? bodyImage;
  final ui.Image? markOverlayImage;
  final ui.Image? baselineOverlayImage;
  final List<BodyPainPoint> painPoints;
  final List<BodyPainPoint> baselinePainPoints;
  final bool calibrationMode;
  final Offset? lastTapPoint;

  static const _gridColor = Color(0x22000000);
  static const _bgColor = Color(0x00FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bgColor);
    final transform = CanvasTransform.contain(size, config.referenceSize);
    _paintImage(canvas, transform, bodyImage);
    _paintImage(canvas, transform, baselineOverlayImage);
    _paintImage(canvas, transform, markOverlayImage);
    _paintPainPoints(canvas, transform, baselinePainPoints, baseline: true);
    _paintPainPoints(canvas, transform, painPoints, baseline: false);
    if (calibrationMode) {
      _paintGrid(canvas, transform);
      _paintCrosshair(canvas, transform);
    }
  }

  void _paintImage(Canvas canvas, CanvasTransform t, ui.Image? image) {
    if (image == null) return;
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dst = Rect.fromLTWH(
      t.dx,
      t.dy,
      config.referenceSize.width * t.scale,
      config.referenceSize.height * t.scale,
    );
    canvas.drawImageRect(image, src, dst, Paint());
  }

  void _paintGrid(Canvas canvas, CanvasTransform t) {
    final paint = Paint()
      ..color = _gridColor
      ..strokeWidth = 0.5;
    final w = config.referenceSize.width;
    final h = config.referenceSize.height;
    final stepX = w > 1500 ? 100.0 : 50.0;
    final stepY = h > 1500 ? 100.0 : 50.0;
    for (double x = 0; x <= w; x += stepX) {
      canvas.drawLine(
        t.toCanvas(Offset(x, 0)),
        t.toCanvas(Offset(x, h)),
        paint,
      );
    }
    for (double y = 0; y <= h; y += stepY) {
      canvas.drawLine(
        t.toCanvas(Offset(0, y)),
        t.toCanvas(Offset(w, y)),
        paint,
      );
    }
  }

  void _paintPainPoints(
    Canvas canvas,
    CanvasTransform t,
    List<BodyPainPoint> points, {
    required bool baseline,
  }) {
    if (points.isEmpty) return;

    final radius = baseline ? 6.0 : 7.5;
    final fillPaint = Paint()
      ..color = baseline ? const Color(0x55D84A3A) : const Color(0xFFE53935);
    final borderPaint = Paint()
      ..color = baseline
          ? const Color(0x88D84A3A)
          : Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseline ? 1.5 : 2.5;

    for (final point in points) {
      final center = t.toCanvas(Offset(point.x, point.y));
      canvas.drawCircle(center, radius, fillPaint);
      canvas.drawCircle(center, radius, borderPaint);
    }
  }

  void _paintCrosshair(Canvas canvas, CanvasTransform t) {
    final p = lastTapPoint;
    if (p == null) return;
    final c = t.toCanvas(p);
    final paint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(c.dx - 12, c.dy), Offset(c.dx + 12, c.dy), paint);
    canvas.drawLine(Offset(c.dx, c.dy - 12), Offset(c.dx, c.dy + 12), paint);
    canvas.drawCircle(c, 4, Paint()..color = const Color(0xFF1B5E20));
  }

  @override
  bool shouldRepaint(covariant BodyPainter oldDelegate) {
    return oldDelegate.config != config ||
        oldDelegate.bodyImage != bodyImage ||
        oldDelegate.markOverlayImage != markOverlayImage ||
        oldDelegate.baselineOverlayImage != baselineOverlayImage ||
        oldDelegate.painPoints != painPoints ||
        oldDelegate.baselinePainPoints != baselinePainPoints ||
        oldDelegate.calibrationMode != calibrationMode ||
        oldDelegate.lastTapPoint != lastTapPoint;
  }
}
