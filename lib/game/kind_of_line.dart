import 'package:collection/collection.dart';

import '../core/game.dart';

class KindOfLine {
  static const Map<PlacedBlockId, ExtraId> PLACED_BLOCK_TO_EXTRA = {
    PlacedBlockId.L: ExtraId.detonate,
    PlacedBlockId.L_INV: ExtraId.new_bomb,
    PlacedBlockId.EDGE: ExtraId.score_bonus,
    PlacedBlockId.EDGE_INV: ExtraId.death_row,
    PlacedBlockId.SNAKE: ExtraId.eraser,
    PlacedBlockId.SNAKE_INV: ExtraId.random,
    PlacedBlockId.BLOCK: ExtraId.slow_down,
    PlacedBlockId.LINE: ExtraId.clear,
  };

  ExtraId? extraID;

  ExtraId? update_for(final List<PlacedBlockId> line) {
    extraID = null;

    for (final id in PlacedBlockId.values) {
      if (line.every((it) => it == id)) {
        extraID = PLACED_BLOCK_TO_EXTRA[id];
      }
    }

    if (blocksOfEachColorPresent(line)) extraID = ExtraId.random;

    return extraID;
  }

  bool blocksOfEachColorPresent(List<PlacedBlockId> line) {
    for (final id in PlacedBlockId.values) {
      if (line.none((it) => it == id)) return false;
    }
    return true;
  }
}
