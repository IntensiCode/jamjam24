import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../util/extensions.dart';

enum GameKey {
  left,
  right,
  up,
  down,
  fire1,
  fire2,
  inventory,
  useOrExecute,
  soft1,
  soft2,
}

mixin HasGameKeys on KeyboardHandler {
  late final keyboard = HardwareKeyboard.instance;

  static final leftKeys = ['Arrow Left', 'A', 'H'];
  static final rightKeys = ['Arrow Right', 'D', 'L'];
  static final downKeys = ['Arrow Down', 'S'];
  static final upKeys = ['Arrow Up', 'W'];
  static final fireKeys1 = ['Space', 'J'];
  static final fireKeys2 = ['Enter', 'Shift', 'K'];
  static final inventoryKeys = ['Tab', 'Home', 'I'];
  static final useOrExecuteKeys = ['Enter', 'U'];
  static final softKeys1 = ['Control Left', 'F1'];
  static final softKeys2 = ['Control Right', 'F4'];

  static final mapping = {
    GameKey.left: leftKeys,
    GameKey.right: rightKeys,
    GameKey.up: upKeys,
    GameKey.down: downKeys,
    GameKey.fire1: fireKeys1,
    GameKey.fire2: fireKeys2,
    GameKey.inventory: inventoryKeys,
    GameKey.useOrExecute: useOrExecuteKeys,
    GameKey.soft1: softKeys1,
    GameKey.soft2: softKeys2,
  };

  void Function(GameKey) onPressed = (_) {};
  void Function(GameKey) onReleased = (_) {};

  // held states

  final Map<GameKey, bool> held = Map.fromIterable(GameKey.values, value: (_) => false);
  final Map<GameKey, int> taps = Map.fromIterable(GameKey.values, value: (_) => 0);

  bool get alt => keyboard.isAltPressed;

  bool get ctrl => keyboard.isControlPressed;

  bool get meta => keyboard.isMetaPressed;

  bool get shift => keyboard.isShiftPressed;

  bool get left => held[GameKey.left] == true;

  bool get right => held[GameKey.right] == true;

  bool get up => held[GameKey.up] == true;

  bool get down => held[GameKey.down] == true;

  bool get primaryFire => held[GameKey.fire1] == true;

  bool get secondaryFire => held[GameKey.fire2] == true;

  bool get soft1 => held[GameKey.soft1] == true;

  bool get soft2 => held[GameKey.soft2] == true;

  bool isHeld(GameKey key) => held[key] == true;

  List<String> _labels(LogicalKeyboardKey key) =>
      [key.keyLabel, ...key.synonyms.map((it) => it.keyLabel)].mapList((it) => it == ' ' ? 'Space' : it).toList();

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyRepeatEvent) {
      return true; // super.onKeyEvent(event, keysPressed);
    }
    if (event case KeyDownEvent it) {
      final labels = _labels(it.logicalKey);
      for (final entry in mapping.entries) {
        final key = entry.key;
        final keys = entry.value;
        if (keys.any((it) => labels.contains(it))) {
          held[key] = true;
          onPressed(key);
          _ticks[key] = _tick;
          taps.update(key, (it) => it + 1, ifAbsent: () => 1);
        }
      }
    }
    if (event case KeyUpEvent it) {
      final labels = _labels(it.logicalKey);
      for (final entry in mapping.entries) {
        final key = entry.key;
        final keys = entry.value;
        if (keys.any((it) => labels.contains(it))) {
          if (_ticks[key] == _tick) {
            _ticks[key] = -1;
          } else {
            held[key] = false;
            onReleased(key);
          }
        }
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // on android it seems key up is sent immediately for some keys like space.
    // to still have other components to "see" the key down, this hack. in
    // [onKeyEvent], if pressed, the _ticks is set. if released and it's the
    // same tick, _ticks is set to -1. then next time this update is called
    // (aka "next tick"), this will trigger the release.
    final too_quick = _ticks.entries.where((it) => it.value == -1);
    for (final it in too_quick) {
      held[it.key] = false;
      onReleased(it.key);
      _ticks[it.key] = 0;
    }
    _tick++;
  }

  int _tick = 0;
  final _ticks = <GameKey, int>{};
}
