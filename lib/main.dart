import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/chart.dart';

import 'package:scheduler/globalstate.dart';
import 'package:scheduler/split.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/summary.dart';
// import 'package:scheduler/chart.dart';

void main() {
  // print(Data<SummaryData>.fromJsonStr(Data.testDataSummaryView()).toString());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GlobalState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Placeholder"),
        ),
        body: CrossSplit(
          horizontalInitRatio: 0.25,
          horizontalGrabberSize: 60,
          verticalInitRatio: 0.75,
          verticalGrabberSize: 30,
          topLeft: Placeholder(color: Colors.yellow),
          topRight: Placeholder(color: Colors.orange),
          // bottomLeft: LineChartWidget([
          //   PricePoint(x: 0.25, y: 0.5),
          //   PricePoint(x: 0.3, y: 0.6),
          //   PricePoint(x: 0.35, y: 0.8),
          //   PricePoint(x: 0.4, y: 0.3)
          // ]),
          bottomLeft: Summary(
              Data<SummaryData>.fromJsonStr(Data.testDataSummaryView())),
          bottomRight: Placeholder(color: Colors.brown),
        ));
  }
}
