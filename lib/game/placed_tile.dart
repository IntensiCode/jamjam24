// ignore_for_file: unnecessary_this

import '../core/game.dart';
import 'game_object.dart';
import 'tile.dart';
import 'tile_set.dart';

class PlacedTile with HasGameData {
  static final PlacedTile EXPLODED = PlacedTile(Tile.EXPLODED);
  static final PlacedTile EMPTY = PlacedTile(Tile.EMPTY);
  static final PlacedTile DEATH = PlacedTile(Tile.DEATH);

  PlacedTile([Tile? tile]) : tile = tile ?? Tile.EMPTY;

  bool draw_drop_guide = false; // TODO move into player
  bool ghost = false;

  final IntPosition position = IntPosition.zero();

  PlacedTile? drop_guide;

  Tile tile;
  TileRotation rotation = TileRotation.ROTATE_0;

  bool get is_still_valid => is_valid_for_placement;

  bool get is_valid_for_placement => tile != Tile.EMPTY;

  bool get is_basic_tile => tile != Tile.EXPLODED && tile != Tile.EMPTY && tile != Tile.DEATH;

  int get width => tile.width(rotation);

  int get height => tile.height(rotation);

  int get offset_x => tile.offset_x(rotation);

  int get offset_y => tile.offset_y(rotation);

  int get pos_x => position.x + offset_x;

  int get pos_y => position.y + offset_y;

  void reset() {
    draw_drop_guide = false;
    position.x = position.y = -1;
    tile = Tile.EMPTY;
    rotation = TileRotation.ROTATE_0;
  }

  void init(PlacedTile it, IntPosition position) {
    tile = it.tile;
    rotation = it.rotation;
    this.position.set_to(position);
  }

  void init_(PlacedTile tile) {
    init__(tile.tile, tile.rotation, tile.position.x, tile.position.y);
  }

  void init__(Tile it, TileRotation rotation, int x, int y) {
    this.position.x = x;
    this.position.y = y;
    this.tile = it;
    this.rotation = rotation;
  }

  bool is_set(int x, int y) => tile.is_set(x, y, rotation);

  // HasGameData

  @override
  void load_state(GameData data) {
    position.x = data['pos_x'] as int;
    position.y = data['pos_y'] as int;
    tile = TileSet.from(PlacedBlockId.from(data['tile']));
    rotation = TileRotation.from(data['rotation']);
  }

  @override
  GameData save_state(GameData data) => data
    ..['pos_x'] = position.x
    ..['pos_y'] = position.y
    ..['tile'] = tile.id.name
    ..['rotation'] = rotation.name;

  // Object

  @override
  String toString() => 'PlacedTile(tile: $tile, rotation: $rotation, position: $position)';
}
