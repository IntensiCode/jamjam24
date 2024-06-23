import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import 'common.dart';

Future<Image> image(String filename) => images.load(filename);

Future<SpriteSheet> sheetIWH(String filename, int frameWidth, int frameHeight) async {
  var img = await image(filename);
  final columns = img.width ~/ frameWidth;
  final rows = img.height ~/ frameHeight;
  return SpriteSheet.fromColumnsAndRows(image: img, columns: columns, rows: rows);
}

Future<SpriteSheet> sheetI(String filename, int columns, int rows) async =>
    SpriteSheet.fromColumnsAndRows(image: await image(filename), columns: columns, rows: rows);

SpriteSheet sheet(Image image, int columns, int rows) =>
    SpriteSheet.fromColumnsAndRows(image: image, columns: columns, rows: rows);

Future<SpriteComponent> loadSprite(
  String filename, {
  Vector2? position,
  Vector2? size,
  Anchor? anchor,
}) async {
  return SpriteComponent(
    sprite: await game.loadSprite(filename),
    position: position,
    size: size,
    anchor: anchor,
  );
}

Future<SpriteAnimation> loadAnimCR(
  String filename,
  int columns,
  int rows, [
  double stepTime = 0.1,
  bool loop = true,
]) async {
  final image = await images.load(filename);
  final frameWidth = image.width ~/ columns;
  final frameHeight = image.height ~/ rows;
  return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: columns * rows,
        amountPerRow: columns,
        stepTime: stepTime,
        textureSize: Vector2(frameWidth.toDouble(), frameHeight.toDouble()),
        loop: loop,
      ));
}

Future<SpriteAnimation> loadAnimWH(
  String filename,
  int frameWidth,
  int frameHeight, [
  double stepTime = 0.1,
  bool loop = true,
]) async {
  final image = await images.load(filename);
  final columns = image.width ~/ frameWidth;
  if (columns * frameWidth != image.width) {
    throw ArgumentError('image width ${image.width} / frame width $frameWidth');
  }
  final rows = image.height ~/ frameHeight;
  if (rows * frameHeight != image.height) {
    throw ArgumentError('image height ${image.height} / frame height $frameHeight');
  }
  return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: columns * rows,
        amountPerRow: columns,
        stepTime: stepTime,
        textureSize: Vector2(frameWidth.toDouble(), frameHeight.toDouble()),
        loop: loop,
      ));
}

Future<SpriteAnimation> loadAnim(
  String filename, {
  required int frames,
  required double stepTimeSeconds,
  required num frameWidth,
  required num frameHeight,
  bool loop = true,
}) async {
  final frameSize = Vector2(frameWidth.toDouble(), frameHeight.toDouble());
  return game.loadSpriteAnimation(
    filename,
    SpriteAnimationData.sequenced(
      amount: frames.toInt(),
      stepTime: stepTimeSeconds.toDouble(),
      textureSize: frameSize,
      loop: loop,
    ),
  );
}