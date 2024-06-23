import '../core/game.dart';
import '../core/random.dart';
import 'tile.dart';

class TileSet {
  static final List<Tile> tiles = [
    Tile.L,
    Tile.L_INV,
    Tile.EDGE,
    Tile.EDGE_INV,
    Tile.SNAKE,
    Tile.SNAKE_INV,
    Tile.BLOCK,
    Tile.LINE,
  ];

  static Tile from(PlacedBlockId id) => switch (id) {
        PlacedBlockId.EMPTY => Tile.EMPTY,
        PlacedBlockId.DEATH => Tile.DEATH,
        PlacedBlockId.EXPLODED => Tile.EXPLODED,
        _ => tiles.firstWhere((e) => e.id == id),
      };

  static Tile pick_random() => tiles[rng.nextInt(tiles.length)];
}
