// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:screen_app/main.dart';
import 'package:screen_app/widgets/util/nameFormatter.dart';

void main() {
  textMatch();
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const App());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
}

void textMatch() {
  var listPanel = ["midea.mfswitch.*",
    "zk527b6c944a454e9fb15d3cc1f4d55b",
    "ok523b6c941a454e9fb15d3cc1f4d55b",
    "midea.knob.*"];
  test('name1', (){
    expect('midea.mfswitch.adads'.contains(RegExp(listPanel[0])), true);
  });
  test('name2', (){
    expect(true, 'midea.mfswitc0.adads'.contains(RegExp(listPanel[0])));
  });
  test('name3', (){
    expect(true, 'zk527b6c944a454e9fb15d3cc1f4d55b'.contains(RegExp(listPanel[1])));
  });
  test('name4', (){
    expect(true, 'ok523b6c941a454e9fb15d3cc1f4d55b'.contains(RegExp(listPanel[2])));
  });
  test('name5', (){
    expect(true, 'midea.knob'.contains(RegExp(listPanel[3])));
  });
}

void testNameFormatCase() {
  test("name-format-maxLimit", () {
    expect(NameFormatter.formLimitString("Widgea", 6, 4, 1), "Widgea");
  });
  test("name-format-normal", () {
    expect(NameFormatter.formLimitString("Widgeagggggggggg", 6, 1, 2), "W...gg");
    expect(NameFormatter.formLimitString("Widgeagggggggggg", 6, 2, 2), "Wi...gg");
    expect(NameFormatter.formLimitString("Widgeagggggggggg", 6, 8, 9), "Widgea");
  });
  test("name-format-tail-none", () {
    expect(NameFormatter.formLimitString("Widgeagggggggggg", 6, 4, 0), "Widg...");
    expect(NameFormatter.formLimitString("Widgeaggggggggggggggggggggggggg", 25, 20, 0), "Widgeagggggggggggggg...");
  });
}
