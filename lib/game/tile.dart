import 'package:jamjam24/game/game_object.dart';

import '../core/game.dart';

class Tile {
  static const int MAX_TILE_SIZE = 4;

  static final Tile L = Tile._(2, 3, [1, 0, 1, 0, 1, 1], PlacedBlockId.L);
  static final Tile L_INV = Tile._(3, 2, [1, 1, 1, 0, 0, 1], PlacedBlockId.L_INV);
  static final Tile EDGE = Tile._(2, 3, [1, 0, 1, 1, 1, 0], PlacedBlockId.EDGE);
  static final Tile EDGE_INV = Tile._(3, 2, [1, 1, 1, 0, 1, 0], PlacedBlockId.EDGE_INV);
  static final Tile SNAKE = Tile._(2, 3, [1, 0, 1, 1, 0, 1], PlacedBlockId.SNAKE);
  static final Tile SNAKE_INV = Tile._(3, 2, [1, 1, 0, 0, 1, 1], PlacedBlockId.SNAKE_INV);
  static final Tile BLOCK = Tile._(2, 2, [1, 1, 1, 1], PlacedBlockId.BLOCK);
  static final Tile LINE = Tile._(4, 1, [1, 1, 1, 1], PlacedBlockId.LINE);
  static final Tile DEATH = Tile._(1, 1, [1], PlacedBlockId.DEATH);
  static final Tile EMPTY = Tile._(1, 1, [1], PlacedBlockId.EMPTY);
  static final Tile EXPLODED = Tile._(1, 1, [1], PlacedBlockId.EXPLODED);

  static final pbi_to_tile = {
    PlacedBlockId.L: L,
    PlacedBlockId.L_INV: L_INV,
    PlacedBlockId.EDGE: EDGE,
    PlacedBlockId.EDGE_INV: EDGE_INV,
    PlacedBlockId.SNAKE: SNAKE,
    PlacedBlockId.SNAKE_INV: SNAKE_INV,
    PlacedBlockId.BLOCK: BLOCK,
    PlacedBlockId.LINE: LINE,
    PlacedBlockId.DEATH: DEATH,
    PlacedBlockId.EMPTY: EMPTY,
    PlacedBlockId.EXPLODED: EXPLODED,
  };

  final PlacedBlockId id;

  final List<int> _width = [0, 0, 0, 0];
  final List<int> _height = [0, 0, 0, 0];

  final TileMask _mask;
  late final Map<TileRotation, TileMask> _masks;

  Tile._(int width_, int height_, this._mask, this.id) {
    _width[0] = _width[2] = _height[1] = _height[3] = width_;
    _width[1] = _width[3] = _height[0] = _height[2] = height_;

    _masks = {
      TileRotation.ROTATE_0: _rotated(TileRotation.ROTATE_0),
      TileRotation.ROTATE_90: _rotated(TileRotation.ROTATE_90),
      TileRotation.ROTATE_180: _rotated(TileRotation.ROTATE_180),
      TileRotation.ROTATE_270: _rotated(TileRotation.ROTATE_270),
    };
  }

  TileMask _rotated(final TileRotation aRotation) {
    if (aRotation == TileRotation.ROTATE_0) return _mask;

    final int rotatedHeight = height(aRotation);
    final int rotatedWidth = width(aRotation);

    final TileMask rotated = [];
    for (int y = 0; y < rotatedHeight; y++) {
      for (int x = 0; x < rotatedWidth; x++) {
        rotated.add(is_set(x, y, aRotation) ? 1 : 0);
      }
    }
    return rotated;
  }

  int width(final TileRotation aRotation) => _width[aRotation.index];

  int height(final TileRotation aRotation) => _height[aRotation.index];

  int offset_x(final TileRotation aRotation) => -(width(aRotation) ~/ 2);

  int offset_y(final TileRotation aRotation) => -(height(aRotation) ~/ 2);

  int tile_x(final int x, final int y, final TileRotation rotation) {
    if (rotation == TileRotation.ROTATE_0) return x;
    if (rotation == TileRotation.ROTATE_90) return y;
    if (rotation == TileRotation.ROTATE_180) return width(rotation) - 1 - x;
    if (rotation == TileRotation.ROTATE_270) return height(rotation) - 1 - y;
    throw 'unknown rotation: $rotation';
  }

  int tile_y(final int x, final int y, final TileRotation rotation) {
    if (rotation == TileRotation.ROTATE_0) return y;
    if (rotation == TileRotation.ROTATE_90) return width(rotation) - 1 - x;
    if (rotation == TileRotation.ROTATE_180) return height(rotation) - 1 - y;
    if (rotation == TileRotation.ROTATE_270) return x;
    throw 'unknown rotation: $rotation';
  }

  bool is_set(final int aX, final int aY, final TileRotation aRotation) {
    final int x = tile_x(aX, aY, aRotation);
    final int y = tile_y(aX, aY, aRotation);
    return (_mask[x + y * width(TileRotation.ROTATE_0)] & 1) != 0;
  }

  TileMask mask(TileRotation rotation) => _masks[rotation]!;

  bool get is_empty => this == EMPTY;

  String save() => id.name;

  static Tile load(GameData data) => pbi_to_tile[PlacedBlockId.from(data['tile'])]!;

  // Object

  @override
  String toString() => id.toString();
}
