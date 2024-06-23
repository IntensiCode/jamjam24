import 'package:collection/collection.dart';

/// To handle "proper" equality checks on all models, this base class
/// requires each model to provide all data [fields]. It implements
/// [hashCode], [==] and [toString] using [DeepCollectionEquality] on the
/// this list of [fields].
mixin BaseModel {
  List<dynamic> get fields;

  @override
  int get hashCode => Object.hashAll(fields);

  @override
  bool operator ==(Object other) {
    if (other is! BaseModel) return false;
    return const DeepCollectionEquality().equals(fields, other.fields);
  }

  @override
  String toString() => fields.toString();
}
