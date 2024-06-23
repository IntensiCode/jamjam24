import 'dart:ui';

import 'package:flame/components.dart';

import '../core/common.dart';

class GradientBackground extends PositionComponent with HasPaint, HasVisibility {
  GradientBackground({Vector2? position, Vector2? size, Anchor? anchor}) {
    if (position != null) super.position.setFrom(position);
    super.size.setFrom(size ?? gameSize);
    if (anchor != null) super.anchor = anchor;

    paint.shader = Gradient.linear(Offset.zero, Offset(0, height), [
      const Color(0xFF000000),
      const Color(0xFF0000a0),
    ]);
  }

  @override
  render(Canvas canvas) {
    canvas.drawPaint(paint);
  }
}
