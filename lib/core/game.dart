import 'package:flame/extensions.dart';

import 'random.dart';

enum ExtraId {
  detonate,
  score_bonus,
  new_bomb,
  slow_down,
  random,
  eraser,
  death_row,
  clear,
  ;

  // ^^^ order matters for pick_random!

  static ExtraId pick_random([int clear_count = 4]) =>
      ExtraId.values.take(values.length * clear_count ~/ 4).toList().random(rng);

  static ExtraId from(String name) => ExtraId.values.firstWhere((e) => e.name == name);
}

enum PlacedBlockId {
  L('L'),
  L_INV('l'),
  EDGE('E'),
  EDGE_INV('e'),
  SNAKE('S'),
  SNAKE_INV('s'),
  BLOCK('B'),
  LINE('-'),
  DEATH('D'),
  EMPTY(' '),
  EXPLODED('X'),
  GHOST('G'),
  ;

  final String id;

  const PlacedBlockId(this.id);

  bool get is_empty => this == EMPTY || this == EXPLODED;

  static PlacedBlockId from(String name) => PlacedBlockId.values.firstWhere((e) => e.name == name);

  static PlacedBlockId from_id(String id) => PlacedBlockId.values.firstWhere((e) => e.id == id);
}

enum TileRotation {
  ROTATE_0,
  ROTATE_90,
  ROTATE_180,
  ROTATE_270,
  ;

  static TileRotation from(String name) => TileRotation.values.firstWhere((e) => e.name == name);

  static TileRotation pick_random() => values[rng.nextInt(values.length)];

  static TileRotation rotate(TileRotation aRotation, bool clock_wise) =>
      clock_wise ? rotateCW(aRotation) : rotateCCW(aRotation);

  static TileRotation rotateCCW(TileRotation aRotation) => switch (aRotation) {
        TileRotation.ROTATE_0 => TileRotation.ROTATE_270,
        TileRotation.ROTATE_90 => TileRotation.ROTATE_0,
        TileRotation.ROTATE_180 => TileRotation.ROTATE_90,
        TileRotation.ROTATE_270 => TileRotation.ROTATE_180,
      };

  static TileRotation rotateCW(TileRotation aRotation) => switch (aRotation) {
        TileRotation.ROTATE_0 => TileRotation.ROTATE_90,
        TileRotation.ROTATE_90 => TileRotation.ROTATE_180,
        TileRotation.ROTATE_180 => TileRotation.ROTATE_270,
        TileRotation.ROTATE_270 => TileRotation.ROTATE_0,
      };
}

typedef TileMask = List<int>;

class FloatPosition {
  double x;
  double y;

  FloatPosition(this.x, this.y);

  FloatPosition.zero() : this(0, 0);

  @override
  String toString() => '($x, $y)';
}

class FloatSize {
  double width;
  double height;

  FloatSize(this.width, this.height);

  FloatSize.zero() : this(0, 0);

  @override
  String toString() => '($width, $height)';
}

class IntPosition {
  int x;
  int y;

  IntPosition(this.x, this.y);

  IntPosition.zero() : this(0, 0);

  void set_to(IntPosition other) {
    x = other.x;
    y = other.y;
  }

  @override
  String toString() => '($x, $y)';
}

class IntSize {
  int width;
  int height;

  IntSize(this.width, this.height);

  IntSize.zero() : this(0, 0);

  @override
  String toString() => '($width, $height)';
}
