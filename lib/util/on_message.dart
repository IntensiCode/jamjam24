import '../core/common.dart';
import '../core/messaging.dart';
import 'auto_dispose.dart';

extension AutoDisposeComponentExtensions on AutoDispose {
  void onMessage<T extends Message>(void Function(T) callback) =>
      autoDispose('listen-$T', messaging.listen<T>(callback));
}
