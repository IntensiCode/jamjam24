import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../core/common.dart';
import '../input/shortcuts.dart';
import '../util/auto_dispose.dart';
import '../util/bitmap_font.dart';
import 'basic_menu_button.dart';

class BasicMenu<T> extends PositionComponent with AutoDispose, HasAutoDisposeShortcuts {
  final SpriteSheet buttonSheet;
  final BitmapFont font;
  final Function(T) onSelected;
  final bool defaultShortcuts;
  final double spacing;

  final _entries = <(T, BasicMenuButton)>[];

  List<T> get entries => _entries.map((it) => it.$1).toList();

  Function(T?) onPreselected = (_) {};

  BasicMenu(
    this.buttonSheet,
    this.font,
    this.onSelected, {
    this.defaultShortcuts = true,
    this.spacing = 10,
    super.position,
    super.size,
    super.anchor,
  });

  @override
  onMount() {
    if (defaultShortcuts) {
      onKey('<Up>', () => preselectPrevious());
      onKey('k', () => preselectPrevious());
      onKey('<Down>', () => preselectNext());
      onKey('j', () => preselectNext());
      onKey('<Enter>', () => select());
      onKey('<Space>', () => select());
    }

    final width = size.isZero() ? gameWidth : size.x;

    var offset = 0.0;
    for (final (_, it) in _entries) {
      it.position.x = width / 2;
      it.position.y = offset;
      it.anchor = Anchor.topCenter;
      offset += it.size.y + spacing;
      if (!it.isMounted) add(it);
    }

    if (size.isZero()) {
      size.x = gameWidth;
      size.y = offset;
    }
  }

  addEntry(T id, String text) {
    _entries.add((
      id,
      BasicMenuButton(
        text,
        sheet: buttonSheet,
        font: font,
        onTap: () => onSelected(id),
      )
    ));
  }

  T? _preselected;

  preselectEntry(T? id) {
    for (final it in _entries) {
      it.$2.selected = it.$1 == id;
    }
    if (_preselected != id) {
      _preselected = id;
      onPreselected(id);
    }
  }

  preselectNext() {
    final idx = _entries.indexWhere((it) => it.$1 == _preselected);
    final it = (idx + 1) % _entries.length;
    preselectEntry(_entries[it].$1);
  }

  preselectPrevious() {
    final idx = _entries.indexWhere((it) => it.$1 == _preselected);
    final it = idx == -1 ? _entries.length - 1 : (idx - 1) % _entries.length;
    preselectEntry(_entries[it].$1);
  }

  select() {
    final it = _preselected;
    if (it != null) onSelected(it);
  }
}
