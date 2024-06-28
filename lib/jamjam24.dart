import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Image, Shortcuts;

import 'core/common.dart';
import 'core/messaging.dart';
import 'core/screens.dart';
import 'core/soundboard.dart';
import 'input/shortcuts.dart';
import 'main_controller.dart';
import 'util/fonts.dart';
import 'util/performance.dart';

class JamJam24 extends FlameGame<MainController>
    with HasKeyboardHandlerComponents, Messaging, Shortcuts, HasPerformanceTracker, ScrollDetector {
  final _ticker = Ticker(ticks: tps);

  JamJam24() : super(world: MainController()) {
    game = this;
    images = this.images;

    if (kIsWeb) logAnsi = false;
  }

  @override
  onGameResize(Vector2 size) {
    super.onGameResize(size);
    camera = CameraComponent.withFixedResolution(
      width: gameWidth,
      height: gameHeight,
      hudComponents: [_ticks(), _frames()],
    );
    camera.viewfinder.anchor = Anchor.topLeft;
  }

  _ticks() => RenderTps(
        scale: Vector2(0.25, 0.25),
        position: Vector2(0, 0),
        anchor: Anchor.topLeft,
      );

  _frames() => RenderFps(
        scale: Vector2(0.25, 0.25),
        position: Vector2(0, 8),
        anchor: Anchor.topLeft,
      );

  @override
  onLoad() async {
    super.onLoad();

    await soundboard.preload();
    await loadFonts(assets);

    add(soundboard);

    // _showInitialScreen();

    // onKey('m', () => soundboard.toggleMute());
    // onKey('t', () => showScreen(Screen.title));

    if (dev) {
      onKey('<C-d>', () => _toggleDebug());
      onKey('<C-m>', () => soundboard.toggleMute());
      onKey('<C-0>', () => showScreen(Screen.title));
      onKey('<C-1>', () => showScreen(Screen.game));
      onKey('<C-->', () => _slowDown());
      onKey('<C-=>', () => _speedUp());
      onKey('<C-S-+>', () => _speedUp());
    }
  }

  _toggleDebug() {
    debug = !debug;
    return KeyEventResult.handled;
  }

  _slowDown() {
    if (_timeScale > 0.125) _timeScale /= 2;
  }

  _speedUp() {
    if (_timeScale < 4.0) _timeScale *= 2;
  }

  double _timeScale = 1;

  @override
  update(double dt) => _ticker.generateTicksFor(dt * _timeScale, (it) => super.update(it));

  @override
  void onScroll(PointerScrollInfo info) {
    super.onScroll(info);
    if (info.scrollDelta.global.y == 0) return;
    send(MouseWheel(info.scrollDelta.global.y.sign));
  }
}
