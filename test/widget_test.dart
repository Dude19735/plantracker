// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:scheduler/data_utils.dart';
import 'package:scheduler/date.dart';

void main() {
  test("Test Date.compareTo", () {
    expect(Date(2023, 1, 1).compareTo(Date(2023, 1, 1)), 0);
    expect(Date(2023, 1, 2).compareTo(Date(2023, 1, 1)), 1);
    expect(Date(2023, 1, 1).compareTo(Date(2023, 1, 2)), -1);
    expect(Date(2023, 2, 1).compareTo(Date(2023, 1, 1)), 1);
    expect(Date(2023, 1, 1).compareTo(Date(2023, 2, 1)), -1);
    expect(Date(2024, 1, 1).compareTo(Date(2023, 1, 1)), 1);
    expect(Date(2023, 1, 1).compareTo(Date(2024, 1, 1)), -1);
  });

  test("Test Date.init", () {
    expect(() => Date(999, 1, 1), throwsException);
    expect(() => Date(10000, 1, 1), throwsException);
    expect(() => Date(2023, 2, 29), throwsException);
    expect(() => Date(2024, 2, 30), throwsException);
    expect(() => Date(2024, 3, 32), throwsException);
    expect(() => Date(2024, 4, 31), throwsException);
  });

  test("Test Date.toInt", () {
    expect(Date(2023, 1, 1).toInt(), 20230101);
    expect(Date(2023, 1, 10).toInt(), 20230110);
    expect(Date(2023, 1, 20).toInt(), 20230120);
    expect(Date(2023, 1, 30).toInt(), 20230130);

    expect(Date(2023, 2, 1).toInt(), 20230201);
    expect(Date(2023, 2, 10).toInt(), 20230210);
    expect(Date(2023, 2, 20).toInt(), 20230220);
    expect(Date(2023, 2, 28).toInt(), 20230228);

    expect(Date(2023, 10, 1).toInt(), 20231001);
    expect(Date(2023, 10, 10).toInt(), 20231010);
    expect(Date(2023, 10, 20).toInt(), 20231020);
    expect(Date(2023, 10, 30).toInt(), 20231030);

    expect(Date(2023, 12, 31).toInt(), 20231231);
  });

  test("Test Date.fromInt", () {
    expect(() => Date.fromInt(9990101), throwsException);
    expect(() => Date.fromInt(100001201), throwsException);
    expect(() => Date.fromInt(2023010), throwsException);
    expect(() => Date.fromInt(20230229), throwsException);
    expect(() => Date.fromInt(20231330), throwsException);
    expect(() => Date.fromInt(20230132), throwsException);
    expect(() => Date.fromInt(20230229), throwsException);
    expect(Date.fromInt(20240229).compareTo(Date(2024, 2, 29)), 0);
    expect(() => Date.fromInt(20230229), throwsException);
    expect(() => Date.fromInt(20230431), throwsException);

    expect(Date.fromInt(19040229).compareTo(Date(1904, 2, 29)), 0);
    expect(Date.fromInt(19080229).compareTo(Date(1908, 2, 29)), 0);
    expect(Date.fromInt(19120229).compareTo(Date(1912, 2, 29)), 0);
    expect(Date.fromInt(19160229).compareTo(Date(1916, 2, 29)), 0);
    expect(Date.fromInt(19200229).compareTo(Date(1920, 2, 29)), 0);
    expect(Date.fromInt(19240229).compareTo(Date(1924, 2, 29)), 0);
    expect(Date.fromInt(19280229).compareTo(Date(1928, 2, 29)), 0);
    expect(Date.fromInt(19320229).compareTo(Date(1932, 2, 29)), 0);
    expect(Date.fromInt(19360229).compareTo(Date(1936, 2, 29)), 0);
    expect(Date.fromInt(19400229).compareTo(Date(1940, 2, 29)), 0);
    expect(Date.fromInt(19440229).compareTo(Date(1944, 2, 29)), 0);
    expect(Date.fromInt(19480229).compareTo(Date(1948, 2, 29)), 0);
    expect(Date.fromInt(19520229).compareTo(Date(1952, 2, 29)), 0);
    expect(Date.fromInt(19560229).compareTo(Date(1956, 2, 29)), 0);
    expect(Date.fromInt(19600229).compareTo(Date(1960, 2, 29)), 0);
    expect(Date.fromInt(19640229).compareTo(Date(1964, 2, 29)), 0);
    expect(Date.fromInt(19680229).compareTo(Date(1968, 2, 29)), 0);
    expect(Date.fromInt(19720229).compareTo(Date(1972, 2, 29)), 0);
    expect(Date.fromInt(19760229).compareTo(Date(1976, 2, 29)), 0);
    expect(Date.fromInt(19800229).compareTo(Date(1980, 2, 29)), 0);
    expect(Date.fromInt(19840229).compareTo(Date(1984, 2, 29)), 0);
    expect(Date.fromInt(19880229).compareTo(Date(1988, 2, 29)), 0);
    expect(Date.fromInt(19920229).compareTo(Date(1992, 2, 29)), 0);
    expect(Date.fromInt(19960229).compareTo(Date(1996, 2, 29)), 0);
    expect(Date.fromInt(20000229).compareTo(Date(2000, 2, 29)), 0);
    expect(Date.fromInt(20040229).compareTo(Date(2004, 2, 29)), 0);
    expect(Date.fromInt(20080229).compareTo(Date(2008, 2, 29)), 0);
    expect(Date.fromInt(20120229).compareTo(Date(2012, 2, 29)), 0);
    expect(Date.fromInt(20160229).compareTo(Date(2016, 2, 29)), 0);
    expect(Date.fromInt(20200229).compareTo(Date(2020, 2, 29)), 0);

    expect(Date.fromInt(20230101).compareTo(Date(2023, 1, 1)), 0);
    expect(Date.fromInt(20230110).compareTo(Date(2023, 1, 10)), 0);
    expect(Date.fromInt(20230120).compareTo(Date(2023, 1, 20)), 0);
    expect(Date.fromInt(20230130).compareTo(Date(2023, 1, 30)), 0);
    expect(Date.fromInt(20230201).compareTo(Date(2023, 2, 1)), 0);
    expect(Date.fromInt(20230210).compareTo(Date(2023, 2, 10)), 0);
    expect(Date.fromInt(20230220).compareTo(Date(2023, 2, 20)), 0);
    expect(Date.fromInt(20230228).compareTo(Date(2023, 2, 28)), 0);
    expect(Date.fromInt(20231001).compareTo(Date(2023, 10, 1)), 0);
    expect(Date.fromInt(20231010).compareTo(Date(2023, 10, 10)), 0);
    expect(Date.fromInt(20231020).compareTo(Date(2023, 10, 20)), 0);
    expect(Date.fromInt(20231030).compareTo(Date(2023, 10, 30)), 0);
    expect(Date.fromInt(20231231).compareTo(Date(2023, 12, 31)), 0);
    expect(Date.fromInt(20240229).compareTo(Date(2024, 02, 29)), 0);
  });

  test("Test Date.addDays", () {
    const List<int> dpm = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    const List<int> dpmLpY = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    
    // add one month
    for(int month=1; month<=12; ++month){
      for(int d=0; d<dpm[month-1]; ++d){
        expect(Date(2023, month, 1).addDays(d).compareTo(Date(2023,month,1+d)), 0);
      }
      expect(Date(2023, month, 1).addDays(dpm[month-1]).compareTo(Date(month==12 ? 2024 : 2023,month==12 ? 1 : month+1,1)), 0);
    }

    for(int month=1; month<=12; ++month){
      for(int d=0; d<dpmLpY[month-1]; ++d){
        expect(Date(2024, month, 1).addDays(d).compareTo(Date(2024,month,1+d)), 0);
      }
      expect(Date(2024, month, 1).addDays(dpmLpY[month-1]).compareTo(Date(month==12 ? 2025 : 2024,month==12 ? 1 : month+1,1)), 0);
    }

    // add one year in non leap year
    int days = 0;
    for(int month=1; month<=12; ++month){
      for(int d=0; d<dpm[month-1]; ++d){
        expect(Date(2023, 1, 1).addDays(days).compareTo(Date(2023,month,1+d)), 0);
        days++;
      }
    }
    expect(days, 365);
    expect(Date(2023, 1, 1).addDays(days).compareTo(Date(2024,1,1)), 0);

    // add one year in leap year
    days = 0;
    for(int month=1; month<=12; ++month){
      for(int d=0; d<dpmLpY[month-1]; ++d){
        expect(Date(2024, 1, 1).addDays(days).compareTo(Date(2024,month,1+d)), 0);
        days++;
      }
    }
    expect(days, 366);
    expect(Date(2024, 1, 1).addDays(days).compareTo(Date(2025,1,1)), 0);

    // do some over leap year border tests
    expect(Date(2023, 10, 23).addDays(365).compareTo(Date(2024,10,22)), 0);
    expect(Date(2023, 10, 23).addDays(366).compareTo(Date(2024,10,23)), 0);
    expect(Date(2022, 10, 23).addDays(365).compareTo(Date(2023,10,23)), 0);
  });

  test("Test Date.subDays", () {
    const List<int> dpm = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    const List<int> dpmLpY = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    
    // add one month
    for(int month=12; month>0; --month){
      for(int d=0; d<dpm[month-1]; ++d){
        expect(Date(2023, month, dpm[month-1]).subtractDays(d).compareTo(Date(2023,month,dpm[month-1]-d)), 0);
      }
      expect(Date(2023, month, dpm[month-1]).subtractDays(dpm[month-1]).compareTo(Date(month==1 ? 2022 : 2023,month==1 ? 12 : month-1, month==1 ? dpm[11] : dpm[month-2])), 0);
    }

    // add one month for a leap year
    for(int month=12; month>0; --month){
      for(int d=0; d<dpmLpY[month-1]; ++d){
        expect(Date(2024, month, dpmLpY[month-1]).subtractDays(d).compareTo(Date(2024, month, dpmLpY[month-1]-d)), 0);
      }
      expect(Date(2024, month, dpmLpY[month-1]).subtractDays(dpmLpY[month-1]).compareTo(Date(month==1 ? 2023 : 2024,month==1 ? 12 : month-1, month==1 ? dpmLpY[11] : dpmLpY[month-2])), 0);
    }

    // add one year in non leap year
    int days = 0;
    for(int month=12; month>0; --month){
      for(int d=0; d<dpm[month-1]; ++d){
        expect(Date(2023, 12, 31).subtractDays(days).compareTo(Date(2023, month, dpm[month-1]-d)), 0);
        days++;
      }
    }
    expect(days, 365);
    expect(Date(2023, 12, 31).subtractDays(days).compareTo(Date(2022,12,31)), 0);

    // add one year in leap year
    days = 0;
    for(int month=12; month>0; --month){
      for(int d=0; d<dpmLpY[month-1]; ++d){
        expect(Date(2024, 12, 31).subtractDays(days).compareTo(Date(2024, month, dpmLpY[month-1]-d)), 0);
        days++;
      }
    }
    expect(days, 366);
    expect(Date(2024, 12, 31).subtractDays(days).compareTo(Date(2023,12,31)), 0);

    // do some over leap year border tests
    expect(Date(2024, 10, 23).subtractDays(365).compareTo(Date(2023,10,24)), 0);
    expect(Date(2024, 10, 23).subtractDays(366).compareTo(Date(2023,10,23)), 0);
    expect(Date(2023, 10, 23).subtractDays(365).compareTo(Date(2022,10,23)), 0);
  });

  test("Test Date.isLeap", () {
    List<int> leaps = [
      1904, 1908, 1912, 1916, 1920, 1924, 1928, 1932, 1936, 1940, 1944, 1948, 1952, 1956, 1960,
      1964, 1968, 1972, 1976, 1980, 1984, 1988, 1992, 1996, 2000, 2004, 2008, 2012, 2016, 2020, 
      2024, 2028, 2032, 2036, 2040, 2044, 2048, 2052, 2056, 2060, 2064, 2068, 2072, 2076, 2080, 
      2084, 2088, 2092, 2096, 2104, 2108, 2112, 2116, 2120, 2124, 2128, 2132, 2136, 2140, 2144, 
      2148, 2152, 2156, 2160, 2164, 2168, 2172, 2176, 2180, 2184, 2188, 2192, 2196, 2204, 2208, 
      2212, 2216, 2220, 2224, 2228, 2232, 2236, 2240, 2244, 2248, 2252, 2256, 2260, 2264, 2268, 
      2272, 2276, 2280, 2284, 2288, 2292, 2296, 2304, 2308, 2312, 2316, 2320, 2324, 2328, 2332, 
      2336, 2340, 2344, 2348, 2352, 2356, 2360, 2364, 2368, 2372, 2376, 2380, 2384, 2388, 2392, 
      2396, 2400, 2404, 2408, 2412, 2416, 2420, 2424, 2428, 2432, 2436, 2440, 2444, 2448, 2452, 
      2456, 2460, 2464, 2468, 2472, 2476, 2480, 2484, 2488, 2492, 2496, 2504, 2508, 2512, 2516, 
      2520, 2524, 2528, 2532, 2536, 2540, 2544, 2548, 2552, 2556, 2560, 2564, 2568, 2572, 2576, 
      2580, 2584, 2588, 2592, 2596, 2600, 2604, 2608, 2612, 2616, 2620, 2624, 2628, 2632, 2636, 
      2640, 2644, 2648, 2652, 2656, 2660, 2664, 2668, 2672, 2676, 2680, 2684, 2688, 2692, 2696, 
      2704, 2708, 2712, 2716, 2720, 2724, 2728, 2732, 2736, 2740, 2744, 2748, 2752, 2756, 2760, 
      2764, 2768, 2772, 2776, 2780, 2784, 2788, 2792, 2796, 2800, 2804, 2808, 2812, 2816, 2820, 
      2824, 2828, 2832, 2836, 2840, 2844, 2848, 2852, 2796, 2800, 2804, 2808, 2812, 2816, 2820, 
      2824, 2828, 2832, 2836, 2840, 2844, 2848, 2852, 2856, 2860, 2864, 2868, 2872, 2876, 2880, 
      2884, 2888, 2892, 2896, 2904, 2908, 2912, 2916, 2920, 2924, 2928, 2932, 2936, 2940, 2944, 
      2948, 2952, 2956, 2960, 2964, 2968, 2972, 2976, 2980, 2984, 2988, 2992, 2996
    ];
    for(var y in leaps){
      expect(Date(y,1,1).isLeap(), true);
    }
  });
}
