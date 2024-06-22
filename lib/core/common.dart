import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals_core/signals_core.dart';

final debug = signal(kDebugMode);
bool dev = kDebugMode;

const tps = 120;

const double gameWidth = 256;
const double gameHeight = 320;
final Vector2 gameSize = Vector2(gameWidth, gameHeight);

const xCenter = gameWidth / 2;
const yCenter = gameHeight / 2;
const fontScale = gameHeight / 500;
const lineHeight = 24 * fontScale;
const debugHeight = 12 * fontScale;

late Game game;
late Images images;
late CollisionDetection collisions;

// to avoid importing materials elsewhere (which causes clashes sometimes), some color values right here:
const transparent = Colors.transparent;
const black = Colors.black;
const white = Colors.white;
const red = Colors.red;
const orange = Colors.orange;
const yellow = Colors.yellow;
const blue = Colors.blue;

Paint pixelPaint() => Paint()
  ..isAntiAlias = false
  ..filterQuality = FilterQuality.none;

enum Screen {
  game,
  title,
}

enum EffectKind {
  explosion,
  smoke,
  sparkle,
  star,
}

enum ExtraKind {
  energy(1),
  firePower(1),
  missile(0.2),
  ;

  final double probability;

  const ExtraKind(this.probability);
}

mixin Collector {
  void collect(ExtraKind kind);
}

mixin Defender {
  bool onHit([int hits = 1]);
}
