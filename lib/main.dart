import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/context.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'package:scheduler/global_state.dart';
import 'package:scheduler/split.dart';
import 'package:scheduler/summary.dart';
import 'package:scheduler/time_table.dart';
import 'package:scheduler/watch_manager.dart';
import 'package:scheduler/work_toggler.dart';

Future<void> main() async {
  const String title = "Dell Power Manager by VA";
  const Size minSize = Size(1280, 720);
  const Size currentSize = Size(1280, 720);

  WidgetsFlutterBinding.ensureInitialized();
  WindowManager.instance.ensureInitialized();
  Window.setEffect(effect: WindowEffect.transparent);

  WindowOptions windowOptions = const WindowOptions(
    size: currentSize,
    minimumSize: minSize,
    windowButtonVisibility: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (!Platform.isLinux) {
      await windowManager.setHasShadow(false);
    }
    // windowManager.setAsFrameless();
    windowManager.show();
  });

  runApp(const MyApp());
}

// Future<void> main() async {
//   const Size minSize = Size(1280, 800);
//   const Size currentSize = minSize;

//   WidgetsFlutterBinding.ensureInitialized();
//   WindowManager.instance.ensureInitialized();

//   WindowOptions windowOptions = const WindowOptions(
//     size: currentSize,
//     minimumSize: minSize,
//   );
//   windowManager.waitUntilReadyToShow(windowOptions, () async {
//     windowManager.show();
//   });

//   runApp(const MyApp());
// }

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
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple, brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple, brightness: Brightness.dark),
        ),
        themeMode: ThemeMode.system,
        home: (Platform.isLinux
            ? ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
                child: MyHomePage())
            : MyHomePage()),
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
    double appBarHeight = GlobalStyle.appBarHeight;
    return Scaffold(
      // As per https://github.com/foamify/rounded_corner_example
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: appBarHeight,
                child: WindowCaption(
                  backgroundColor: Colors.transparent,
                  brightness: Theme.of(context).brightness,
                  title: Text("lol"),
                ),
              ),
              Expanded(
                child:
                    //     Row(
                    //   children: [
                    //     Container(width: 100),
                    //     RotatedBox(
                    //       quarterTurns: 1,
                    //       child: GlobalStyle.createShadowContainer(
                    //           context,
                    //           WorkToggler(() {
                    //             print("L");
                    //           }, () {
                    //             print("R");
                    //           }, 500, Colors.orange, Colors.red),
                    //           width: 300.0,
                    //           height: 50.0,
                    //           margin: 0.0),
                    //     ),
                    //   ],
                    // )
                    Row(
                  children: [
                    SizedBox(
                        width: GlobalStyle.clockBarWidth,
                        child: WatchManager(globalContext)),
                    Expanded(
                      child: CrossSplit(
                        globalContext,
                        horizontalInitRatio: GlobalStyle.horizontalInitRatio,
                        horizontalGrabberSize:
                            GlobalStyle.horizontalGrabberSize,
                        verticalInitRatio: GlobalStyle.verticalInitRatio,
                        verticalGrabberSize: GlobalStyle.verticalGrabberSize,
                        topLeft: Placeholder(color: Colors.black12),
                        topRight: Placeholder(color: Colors.black12),
                        bottomLeft: Summary(globalContext, _summary),
                        bottomRight: TimeTable(globalContext, _timeTable),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const DragToResizeArea(
            enableResizeEdges: [
              ResizeEdge.topLeft,
              ResizeEdge.top,
              ResizeEdge.topRight,
              ResizeEdge.left,
              ResizeEdge.right,
              ResizeEdge.bottomLeft,
              ResizeEdge.bottomLeft,
              ResizeEdge.bottomRight,
            ],
            child: SizedBox(),
          ),
        ],
      ),
    );

    // return Scaffold(
    // appBar: AppBar(
    //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //   title: Text("Placeholder"),
    // ),
    //     body: Row(
    //   children: [
    //     SizedBox(width: 200, child: WatchManager(globalContext)),
    //     Expanded(
    //       child: CrossSplit(
    //         globalContext,
    //         horizontalInitRatio: GlobalStyle.horizontalInitRatio,
    //         horizontalGrabberSize: GlobalStyle.horizontalGrabberSize,
    //         verticalInitRatio: GlobalStyle.verticalInitRatio,
    //         verticalGrabberSize: GlobalStyle.verticalGrabberSize,
    //         topLeft: Placeholder(color: Colors.black12),
    //         topRight: Placeholder(color: Colors.black12),
    //         bottomLeft: Summary(globalContext, _summary),
    //         bottomRight: TimeTable(globalContext, _timeTable),
    //       ),
    //     ),
    //   ],
    // ));
  }
}
