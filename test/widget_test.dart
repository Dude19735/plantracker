// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scheduler/data_utils.dart';

void main() {
  test("Test DataUtils.dateTime2Int", () {
    expect(DataUtils.dateTime2Int(DateTime(2023, 1, 1)), 20230101);
    expect(DataUtils.dateTime2Int(DateTime(2023, 1, 10)), 20230110);
    expect(DataUtils.dateTime2Int(DateTime(2023, 1, 20)), 20230120);
    expect(DataUtils.dateTime2Int(DateTime(2023, 1, 30)), 20230130);

    expect(DataUtils.dateTime2Int(DateTime(2023, 2, 1)), 20230201);
    expect(DataUtils.dateTime2Int(DateTime(2023, 2, 10)), 20230210);
    expect(DataUtils.dateTime2Int(DateTime(2023, 2, 20)), 20230220);
    expect(DataUtils.dateTime2Int(DateTime(2023, 2, 28)), 20230228);

    expect(DataUtils.dateTime2Int(DateTime(2023, 10, 1)), 20231001);
    expect(DataUtils.dateTime2Int(DateTime(2023, 10, 10)), 20231010);
    expect(DataUtils.dateTime2Int(DateTime(2023, 10, 20)), 20231020);
    expect(DataUtils.dateTime2Int(DateTime(2023, 10, 30)), 20231030);

    expect(DataUtils.dateTime2Int(DateTime(2023, 12, 31)), 20231231);

    expect(() => DataUtils.dateTime2Int(DateTime(999, 1, 1)), throwsException);
    expect(
        () => DataUtils.dateTime2Int(DateTime(10000, 1, 1)), throwsException);
  });

  test("Test DataUtils.int2DateTime", () {
    expect(() => DataUtils.int2DateTime(9990101), throwsException);
    expect(() => DataUtils.int2DateTime(100001201), throwsException);
    expect(() => DataUtils.int2DateTime(2023010), throwsException);
    expect(() => DataUtils.int2DateTime(20230229), throwsException);
    expect(() => DataUtils.int2DateTime(20231330), throwsException);
    expect(() => DataUtils.int2DateTime(20230132), throwsException);

    expect(DataUtils.int2DateTime(19040229), DateTime(1904, 2, 29));
    expect(DataUtils.int2DateTime(19080229), DateTime(1908, 2, 29));
    expect(DataUtils.int2DateTime(19120229), DateTime(1912, 2, 29));
    expect(DataUtils.int2DateTime(19160229), DateTime(1916, 2, 29));
    expect(DataUtils.int2DateTime(19200229), DateTime(1920, 2, 29));
    expect(DataUtils.int2DateTime(19240229), DateTime(1924, 2, 29));
    expect(DataUtils.int2DateTime(19280229), DateTime(1928, 2, 29));
    expect(DataUtils.int2DateTime(19320229), DateTime(1932, 2, 29));
    expect(DataUtils.int2DateTime(19360229), DateTime(1936, 2, 29));
    expect(DataUtils.int2DateTime(19400229), DateTime(1940, 2, 29));
    expect(DataUtils.int2DateTime(19440229), DateTime(1944, 2, 29));
    expect(DataUtils.int2DateTime(19480229), DateTime(1948, 2, 29));
    expect(DataUtils.int2DateTime(19520229), DateTime(1952, 2, 29));
    expect(DataUtils.int2DateTime(19560229), DateTime(1956, 2, 29));
    expect(DataUtils.int2DateTime(19600229), DateTime(1960, 2, 29));
    expect(DataUtils.int2DateTime(19640229), DateTime(1964, 2, 29));
    expect(DataUtils.int2DateTime(19680229), DateTime(1968, 2, 29));
    expect(DataUtils.int2DateTime(19720229), DateTime(1972, 2, 29));
    expect(DataUtils.int2DateTime(19760229), DateTime(1976, 2, 29));
    expect(DataUtils.int2DateTime(19800229), DateTime(1980, 2, 29));
    expect(DataUtils.int2DateTime(19840229), DateTime(1984, 2, 29));
    expect(DataUtils.int2DateTime(19880229), DateTime(1988, 2, 29));
    expect(DataUtils.int2DateTime(19920229), DateTime(1992, 2, 29));
    expect(DataUtils.int2DateTime(19960229), DateTime(1996, 2, 29));
    expect(DataUtils.int2DateTime(20000229), DateTime(2000, 2, 29));
    expect(DataUtils.int2DateTime(20040229), DateTime(2004, 2, 29));
    expect(DataUtils.int2DateTime(20080229), DateTime(2008, 2, 29));
    expect(DataUtils.int2DateTime(20120229), DateTime(2012, 2, 29));
    expect(DataUtils.int2DateTime(20160229), DateTime(2016, 2, 29));
    expect(DataUtils.int2DateTime(20200229), DateTime(2020, 2, 29));

    expect(DataUtils.int2DateTime(20230101), DateTime(2023, 1, 1));
    expect(DataUtils.int2DateTime(20230110), DateTime(2023, 1, 10));
    expect(DataUtils.int2DateTime(20230120), DateTime(2023, 1, 20));
    expect(DataUtils.int2DateTime(20230130), DateTime(2023, 1, 30));
    expect(DataUtils.int2DateTime(20230201), DateTime(2023, 2, 1));
    expect(DataUtils.int2DateTime(20230210), DateTime(2023, 2, 10));
    expect(DataUtils.int2DateTime(20230220), DateTime(2023, 2, 20));
    expect(DataUtils.int2DateTime(20230228), DateTime(2023, 2, 28));
    expect(DataUtils.int2DateTime(20231001), DateTime(2023, 10, 1));
    expect(DataUtils.int2DateTime(20231010), DateTime(2023, 10, 10));
    expect(DataUtils.int2DateTime(20231020), DateTime(2023, 10, 20));
    expect(DataUtils.int2DateTime(20231030), DateTime(2023, 10, 30));
    expect(DataUtils.int2DateTime(20231231), DateTime(2023, 12, 31));
    expect(DataUtils.int2DateTime(20240229), DateTime(2024, 02, 29));
  });

  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
}
