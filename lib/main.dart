import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/context.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:scheduler/global_state.dart';
import 'package:scheduler/split.dart';
import 'package:scheduler/summary.dart';
import 'package:scheduler/time_table.dart';

void main() {
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
  GlobalContext globalContext = GlobalContext();
  LinkedScrollControllerGroup _controllerGroup = LinkedScrollControllerGroup();
  late ScrollController _summary;
  late ScrollController _timeTable;
  int _mouseInWidget = -1;

  @override
  void initState() {
    super.initState();
    _summary = _controllerGroup.addAndGet();
    _timeTable = _controllerGroup.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    globalContext.showSubjectsInSummary = true;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Placeholder"),
        ),
        body: CrossSplit(
          globalContext,
          horizontalInitRatio: 0.25,
          horizontalGrabberSize: 60,
          verticalInitRatio: 0.75,
          verticalGrabberSize: 30,
          topLeft: Placeholder(color: Colors.yellow),
          topRight: Placeholder(color: Colors.orange),
          bottomLeft: Summary(globalContext, _summary),
          bottomRight: TimeTable(globalContext, _timeTable),
        ));
  }
}
