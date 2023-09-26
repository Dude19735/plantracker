import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/context.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:scheduler/global_state.dart';
import 'package:scheduler/split.dart';
import 'package:scheduler/summary.dart';
import 'package:scheduler/time_table.dart';
import 'package:scheduler/watch_manager.dart';
import 'package:scheduler/work_schedule.dart';
import 'package:scheduler/split_controller.dart';

Future<void> main() async {
  const String title = "Just something...";
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GlobalState(),
      child: MaterialApp(
        title: 'Namer App',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', 'GB'),
          Locale('de', 'CH'),
          Locale('fr', 'CH'),
        ],
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  GlobalContext globalContext = GlobalContext();
  LinkedScrollControllerGroup _controllerGroup = LinkedScrollControllerGroup();
  late ScrollController _summary;
  late ScrollController _timeTable;
  late final TabController _controller;
  late final SplitController _splitController;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
    _summary = _controllerGroup.addAndGet();
    _timeTable = _controllerGroup.addAndGet();
    _splitController =
        SplitController(animationMs: GlobalSettings.pageChangeDurationMS);
  }

  @override
  Widget build(BuildContext context) {
    var split = NotificationListener(
      onNotification: (notification) {
        if (notification is DateChangedNotification2) {
          setState(() {
            GlobalContext.fromDateWindow = notification.from;
            GlobalContext.toDateWindow = notification.to;
          });
          return true;
        }
        if (notification is PageScrolledNotification) {
          setState(() {
            if (!notification.backwards) {
              Duration d = GlobalContext.toDateWindow
                      .difference(GlobalContext.fromDateWindow) +
                  Duration(days: 1);
              GlobalContext.fromDateWindow =
                  GlobalContext.fromDateWindow.add(d);
              GlobalContext.toDateWindow = GlobalContext.toDateWindow.add(d);
            } else {
              Duration d = GlobalContext.toDateWindow
                      .difference(GlobalContext.fromDateWindow) +
                  Duration(days: 1);
              GlobalContext.fromDateWindow =
                  GlobalContext.fromDateWindow.subtract(d);
              GlobalContext.toDateWindow =
                  GlobalContext.toDateWindow.subtract(d);
            }
          });
          return true;
        }
        if (notification is ChangePageNotification) {
          if (notification.backwards) {
            _splitController.previousPage();
          } else {
            _splitController.nextPage();
          }
        }
        return false;
      },
      child: CrossSplit(
        horizontalInitRatio: GlobalStyle.horizontalInitRatio,
        horizontalGrabberSize: GlobalStyle.horizontalGrabberSize,
        verticalInitRatio: GlobalStyle.verticalInitRatio,
        verticalGrabberSize: GlobalStyle.verticalGrabberSize,
        topLeft: Placeholder(color: Colors.black12),
        topRight: WorkSchedule(_splitController),
        bottomLeft: Summary(_summary),
        bottomRight: TimeTable(_timeTable, _splitController),
      ),
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
                            child: WatchManager()),
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
