// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:jamjam24/game/hiscore.dart';

void main() {
  test('hiscore rank equals', () {
    final a = HiscoreRank(100, 10, 'a');
    final b = HiscoreRank(100, 10, 'a');
    expect(a, equals(b));
  });

  test('hiscore rank not equals: name', () {
    final a = HiscoreRank(100, 10, 'a');
    final b = HiscoreRank(100, 10, 'b');
    expect(a, isNot(equals(b)));
  });

  test('hiscore rank not equals: level', () {
    final a = HiscoreRank(100, 10, 'a');
    final b = HiscoreRank(100, 11, 'a');
    expect(a, isNot(equals(b)));
  });

  test('hiscore rank not equals: score', () {
    final a = HiscoreRank(100, 10, 'a');
    final b = HiscoreRank(101, 10, 'a');
    expect(a, isNot(equals(b)));
  });
}
