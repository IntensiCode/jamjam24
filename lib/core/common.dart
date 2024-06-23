import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool debug = kDebugMode;
bool dev = kDebugMode;

const tps = 60;

const double gameWidth = 480;
const double gameHeight = 800;
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

ParticleSystemComponent Particles(Particle root) => ParticleSystemComponent(particle: root);

mixin Message {}

class MouseWheel with Message {
  final double direction;

  MouseWheel(this.direction);
}

TODO(String message) => throw UnimplementedError(message);
