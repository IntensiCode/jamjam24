import 'package:collection/collection.dart';
import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import '../core/game.dart';
import '../core/soundboard.dart';
import '../util/extensions.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_object.dart';
import 'kind_of_line.dart';
import 'placed_tile.dart';
import 'tile.dart';

typedef BlockRow = List<PlacedBlockId>;

class BlockContainer extends Component with GameObject {
  int get width => size.width;

  int get height => size.height;

  late IntSize size;
  late List<BlockRow> rows;
  late IntPosition start_position;

  final _kind_of_line = KindOfLine();

  bool can_be_placed(PlacedTile it) {
    final x = it.pos_x;
    if (x < 0 || x > width - it.width) return false;

    final y = it.pos_y;
    if (y > height - it.height) return false;

    return !is_placement_blocked(it);
  }

  bool is_placement_blocked(PlacedTile it) {
    final x = it.pos_x;
    final y = it.pos_y;
    final width = it.width;
    final height = it.height;
    for (int y_ = 0; y_ < height; y_++) {
      final offset_y = y + y_;
      if (offset_y < 0) continue;
      for (int x_ = 0; x_ < width; x_++) {
        if (!it.is_set(x_, y_)) continue;
        if (is_blocked(x + x_, offset_y)) return true;
      }
    }
    return false;
  }

  bool is_blocked(int x, int y) {
    if (x < 0 || x >= width) return true;
    if (y < 0 || y >= height) return true;
    final tile = rows[y][x];
    if (tile == PlacedBlockId.EMPTY) return false;
    if (tile == PlacedBlockId.EXPLODED) return false;
    return true;
  }

  void insert_bottom_line() {
    rows.removeAt(0);
    rows.add(_empty_line(size.width));

    clear_all.on_line_inserted();
    exploding_blocks.on_line_inserted();
    exploding_lines.on_line_inserted();
  }

  void make_death_row([int? line_index]) {
    line_index ??= rows.length - 1;
    rows[line_index].fill(PlacedBlockId.DEATH);
  }

  void place_block(final int x, final int y, final PlacedBlockId id) {
    if (x < 0 || x >= size.width) throw '$x !in 0..${size.width - 1}';
    if (y < 0 || y >= size.height) throw '$y !in 0..${size.height - 1}';
    rows[y][x] = id;
    soundboard.trigger(Sound.placed);
  }

  int check_lines(PlacedTile it) => check_full_lines(it.pos_y, it.height);

  int check_full_lines(final int from_row, final int row_count) {
    int removed = 0;
    for (int y = from_row; y < from_row + row_count; y++) {
      if (y < 0) continue;
      if (is_death_row(y)) continue;
      if (!is_full_row(y)) continue;
      removed++;
      explode_line(y, removed);
    }
    if (removed > 0) soundboard.trigger(Sound.line);
    return removed;
  }

  bool is_death_row(final int row) => rows[row].every((it) => it == PlacedBlockId.DEATH);

  bool is_full_row(final int row) => rows[row].none((it) => it.is_empty);

  void explode_line(final int row, final int sequence_index) {
    // See also #checkForExplodedLine and #doRemoveLine.
    // This method handles only the FX and replaces blocks with the EXPLODING_MARKER!
    deploy_extra(row, sequence_index);
    if (configuration.explode_lines) explosions.spawn_for_row(row, sequence_index);
    exploding_lines.trigger_at(row, sequence_index);
  }

  void deploy_extra(final int row, final int clear_size) {
    final it = extras.spawn_in_row(row, clear_size);

    final special_id = _kind_of_line.update_for(rows[row]);
    if (special_id == null) return;

    extras.spawn(special_id, it.x, it.y);

    player.on_special_extra(special_id);
  }

  void erase_block(final int x, final int y) {
    if (x < 0 || x >= width) return;
    if (y < 0 || y >= height) return;
    if (rows[y][x] == PlacedBlockId.EMPTY) return;
    rows[y][x] = PlacedBlockId.EMPTY;
  }

  void insert(PlacedTile it) {
    for (int y = 0; y < it.height; y++) {
      final row = it.pos_y + y;
      if (row < 0) continue;
      for (int x = 0; x < it.width; x++) {
        if (!it.is_set(x, y)) continue;
        rows[row][it.pos_x + x] = it.tile.id;
      }
    }
  }

  void place_tile(PlacedTile it) {
    insert(it);

    final removed = check_lines(it);
    player.on_score_lines(removed);
    player.on_score_placed_tile();

    soundboard.trigger(Sound.placed);
  }

  void detonate(PlacedTile aTile) {
    insert(aTile);
    detonating_blocks.detonate_at(aTile.position.x, aTile.pos_y + aTile.height);
    soundboard.trigger(Sound.detonated);
  }

  void explode_block(int aX, int aY) {
    final tile = rows[aY][aX];
    if (tile == PlacedBlockId.EMPTY || tile == PlacedBlockId.EXPLODED) return;
    rows[aY][aX] = PlacedBlockId.EXPLODED;
    exploding_blocks.spawn_at(aX, aY, width);
  }

  void do_remove_line(int aLineIndex) {
    rows.removeAt(aLineIndex);
    rows.insert(0, _empty_line(size.width));

    clear_all.on_line_removed();
    exploding_blocks.on_line_removed(aLineIndex);
    exploding_lines.on_line_removed(aLineIndex);
  }

  void clear_exploded_line(int aLineIndex) {
    bool dirty = false;
    for (int x = 0; x < width; x++) {
      final block = rows[aLineIndex][x];
      if (block == PlacedBlockId.EXPLODED) {
        rows[aLineIndex][x] = PlacedBlockId.EMPTY;
      } else if (block != PlacedBlockId.EMPTY) {
        dirty = true;
      }
    }
    if (!dirty) do_remove_line(aLineIndex);
  }

  // Component

  @override
  void onLoad() {
    size = visual.container_size;
    start_position = IntPosition(size.width ~/ 2, Tile.MAX_TILE_SIZE - 1);
    _reset_container();
    logInfo('container size: $size, start position: $start_position');
  }

  void _reset_container() {
    rows = List.generate(size.height, (_) => _empty_line(size.width));
  }

  static _empty_line(int width) => List.filled(width, PlacedBlockId.EMPTY);

  @override
  void update(double dt) {
    if (!detonating_blocks.is_active) check_full_lines(0, height);
  }

  // GameObject

  @override
  void on_start_new_game() => _reset_container();

  // HasGameData

  @override
  void load_state(GameData state) {
    size = IntSize(state['width'], state['height']);
    rows = _load_blocks(state['rows']);
    start_position = IntPosition(state['start_position_x'], state['start_position_y']);
  }

  @override
  GameData save_state(GameData data) => data
    ..['width'] = size.width
    ..['height'] = size.height
    ..['rows'] = _save_blocks()
    ..['start_position_x'] = start_position.x
    ..['start_position_y'] = start_position.y;

  String _save_blocks() => rows.map((it) => it.map((it) => it.id).join('')).join('\n');

  List<BlockRow> _load_blocks(String data) =>
      data.split('\n').map((it) => it.split('').map((it) => PlacedBlockId.from_id(it)).toList()).toList();
}
