import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import '../core/common.dart';
import '../util/auto_dispose.dart';

extension ComponentExtension on Component {
  Messaging get messaging {
    Component? probed = this;
    while (probed is! Messaging) {
      probed = probed?.parent;
      if (probed == null) {
        Component? log = this;
        while (log != null) {
          logWarn('no messaging mixin found in $log');
          log = log.parent;
        }
        logWarn('=> no messaging mixin found in $this');
        throw 'no messaging mixin found';
      }
    }
    return probed;
  }

  void sendMessage<T extends Message>(T message) => messaging.send(message);
}

mixin Messaging on Component {
  final listeners = <Type, List<dynamic>>{};

  Disposable listen<T extends Message>(void Function(T) callback) {
    listeners[T] ??= [];
    listeners[T]!.add(callback);
    return Disposable.wrap(() {
      listeners[T]?.remove(callback);
    });
  }

  void send<T extends Message>(T message) {
    final listener = listeners[T];
    if (listener == null || listener.isEmpty) {
      logWarn('no listener for $T in $listeners');
    } else {
      listener.forEach((it) => it(message));
    }
  }

  @override
  void onRemove() => listeners.clear();
}
