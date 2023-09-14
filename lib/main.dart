import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  GlobalContext globalContext = GlobalContext();
  LinkedScrollControllerGroup _controllerGroup = LinkedScrollControllerGroup();
  late ScrollController _summary;
  late ScrollController _timeTable;
  int _mouseInWidget = -1;
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _summary = _controllerGroup.addAndGet();
    _timeTable = _controllerGroup.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    _controller = TabController(vsync: this, length: 3);

    var split = CrossSplit(
      globalContext,
      horizontalInitRatio: GlobalStyle.horizontalInitRatio,
      horizontalGrabberSize: GlobalStyle.horizontalGrabberSize,
      verticalInitRatio: GlobalStyle.verticalInitRatio,
      verticalGrabberSize: GlobalStyle.verticalGrabberSize,
      topLeft: Placeholder(color: Colors.black12),
      topRight: Placeholder(color: Colors.black12),
      bottomLeft: Summary(globalContext, _summary),
      bottomRight: TimeTable(globalContext, _timeTable),
    );

    return Scaffold(
      // As per https://github.com/foamify/rounded_corner_example
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: GlobalStyle.appBarHeight,
                child: WindowCaption(
                    backgroundColor: Colors.transparent,
                    brightness: Theme.of(context).brightness),
              ),
              Column(
                children: [
                  Expanded(
                      child: Row(children: [
                    Column(
                      children: [
                        SizedBox(
                            width: GlobalStyle.clockBarWidth,
                            height: GlobalStyle.appBarHeight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                "lib/img/title_clock.svg",
                                alignment: Alignment.centerLeft,
                              ),
                            )),
                        SizedBox(
                            width: GlobalStyle.clockBarWidth,
                            child: WatchManager(globalContext)),
                      ],
                    ),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(
                                right: constraints.maxWidth -
                                    GlobalStyle.clockBarWidth -
                                    3 * GlobalStyle.tabBarTabWidth),
                            height: GlobalStyle.appBarHeight,
                            child: TabBar(
                              padding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              controller: _controller,
                              isScrollable: true,
                              tabs: [
                                SizedBox(
                                  width: GlobalStyle.tabBarTabWidth,
                                  child: Tab(
                                    icon: Icon(Icons.school),
                                  ),
                                ),
                                SizedBox(
                                  width: GlobalStyle.tabBarTabWidth,
                                  child: Tab(
                                    icon: Icon(Icons.menu_book),
                                  ),
                                ),
                                SizedBox(
                                  width: GlobalStyle.tabBarTabWidth,
                                  child: Tab(
                                    icon: Icon(Icons.settings),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: constraints.maxWidth -
                                  GlobalStyle.clockBarWidth,
                              child: TabBarView(
                                  controller: _controller,
                                  children: [
                                    split,
                                    Container(color: Colors.amber),
                                    Container(color: Colors.blue)
                                  ]),
                            ),
                          ),
                        )
                      ],
                    ),
                  ])),
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
          );
        },
      ),
    );
  }
}
