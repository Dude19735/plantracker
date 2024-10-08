import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/time_table_box.dart';
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
import 'package:scheduler/joined_scroller.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/date.dart';

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
      child: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  GlobalContext globalContext = GlobalContext();
  late CrossSplit _crossSplit;
  late final TabController _controller;
  late final SplitController _splitController;
  final JoinedScroller _joinedScroller = JoinedScroller();
  ScrollDirection _direction = ScrollDirection.idle;
  double _pixels = -1;
  late bool _darkTheme;

  _MyHomePageState() {
    _darkTheme = false;
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
    _splitController = SplitController();
  }

  void _dealWithDataChangedNotification(DataChangedNotification notification) {
    /**
     * This is the place where the data should be saved
     */
    if (notification is DataChangedNotificationTimeTableData) {
      SplitContainer.setComponentState(CrossSplitComponent.bl, () {
        GlobalContext.data.summaryFT(
            GlobalContext.fromDateWindow, GlobalContext.toDateWindow);
      });
    }
  }

  void _padScrollState(Notification notification) {
    var from = GlobalContext.fromDateWindow;
    var to = GlobalContext.toDateWindow;
    if (notification is UserScrollNotification) {
      if (_direction == ScrollDirection.idle &&
          notification.direction == ScrollDirection.forward) {
        _direction = notification.direction;
        _pixels = notification.metrics.pixels;
        Debugger.main("left");

        GlobalContext.data.loadFT(GlobalSettings.pageViewScrollWaitTimeMS,
            _direction, from, to, () {});
      } else if (_direction == ScrollDirection.idle &&
          notification.direction == ScrollDirection.reverse) {
        _direction = notification.direction;
        _pixels = notification.metrics.pixels;
        Debugger.main("right");

        GlobalContext.data.loadFT(GlobalSettings.pageViewScrollWaitTimeMS,
            _direction, from, to, () {});
      } else if (notification.direction == ScrollDirection.idle) {
        Debugger.main("Back to idle...");

        Date from = GlobalContext.fromDateWindow;
        Date to = GlobalContext.toDateWindow;
        _direction = notification.direction;

        if (_pixels < notification.metrics.pixels) {
          var next = DataUtils.getNextPage(from, to);
          GlobalContext.fromDateWindow = next["from"]!;
          GlobalContext.toDateWindow = next["to"]!;
          Debugger.main(
              "page number increased ${GlobalContext.fromDateWindow} ${GlobalContext.toDateWindow}");
        } else if (_pixels > notification.metrics.pixels) {
          var prev = DataUtils.getPreviousPage(from, to);
          GlobalContext.fromDateWindow = prev["from"]!;
          GlobalContext.toDateWindow = prev["to"]!;
          Debugger.main(
              "page number decreased ${GlobalContext.fromDateWindow} ${GlobalContext.toDateWindow}");
        }
        _pixels = -1;
        GlobalContext.data.loadFT(0, _direction, GlobalContext.fromDateWindow,
            GlobalContext.toDateWindow, () {
          setState(() {
            Debugger.main("final idle load $_direction");
          });
        });
      }
    }
    if (notification is ScrollUpdateNotification) {
      if (_direction == ScrollDirection.forward) {
        if (_pixels < notification.metrics.pixels) {
          Debugger.main("left to right");
          _direction = ScrollDirection.reverse;
          GlobalContext.data.loadFT(GlobalSettings.pageViewScrollWaitTimeMS,
              _direction, from, to, () {});
        }
      } else if (_direction == ScrollDirection.reverse) {
        if (_pixels > notification.metrics.pixels) {
          Debugger.main("right to left");
          _direction = ScrollDirection.forward;
          GlobalContext.data.loadFT(GlobalSettings.pageViewScrollWaitTimeMS,
              _direction, from, to, () {});
        }
      }
    }
  }

  void _buttonScrollState(
      StartChangeSplitControllerPageNotification notification) {
    Debugger.main("keep scrolling");
    var from = GlobalContext.fromDateWindow;
    var to = GlobalContext.toDateWindow;

    Debugger.main("Scroll direction ${notification.direction}");
    if (notification.direction == ScrollDirection.forward) {
      var next = DataUtils.getNextPage(from, to);
      GlobalContext.fromDateWindow = next["from"]!;
      GlobalContext.toDateWindow = next["to"]!;
      Debugger.main(
          "page number increased ${GlobalContext.fromDateWindow} ${GlobalContext.toDateWindow}");
    } else if (notification.direction == ScrollDirection.reverse) {
      var prev = DataUtils.getPreviousPage(from, to);
      GlobalContext.fromDateWindow = prev["from"]!;
      GlobalContext.toDateWindow = prev["to"]!;
      Debugger.main(
          "page number decreased ${GlobalContext.fromDateWindow} ${GlobalContext.toDateWindow}");
    }

    _splitController.changePage(
        notification.direction,
        () => GlobalContext.data.loadFT(
            GlobalSettings.pageViewScrollWaitTimeMS,
            ScrollDirection.idle,
            GlobalContext.fromDateWindow,
            GlobalContext.toDateWindow,
            () => setState(() {
                  Debugger.main("finally idlying loading $_direction");
                })));
    SplitContainer.setComponentState(CrossSplitComponent.tr, () {});
  }

  @override
  Widget build(BuildContext context) {
    _crossSplit = CrossSplit(
      horizontalInitRatio: GlobalStyle.splitterHInitRatio,
      horizontalGrabberSize: GlobalStyle.splitterHGrabberSize,
      verticalInitRatio: GlobalStyle.splitterVInitRatio,
      verticalGrabberSize: GlobalStyle.splitterVGrabberSize,
      topLeft: (SplitMetrics metrics) => SizedBox(),
      topRight: (SplitMetrics metrics) =>
          WorkSchedule(metrics, _splitController),
      bottomLeft: (SplitMetrics metrics) => Summary(metrics, _joinedScroller),
      bottomRight: (SplitMetrics metrics) =>
          TimeTable(metrics, _joinedScroller, _splitController),
      minTopLeft: 120,
      minTopRight: 680,
      minBottomLeft: 120,
      minBottomRight: 680,
    );

    var split = NotificationListener(
      onNotification: (notification) {
        if (notification is DateChangedNotification) {
          Debugger.main("date changed");
          GlobalContext.fromDateWindow = notification.from;
          GlobalContext.toDateWindow = notification.to;
          GlobalContext.data.loadFT(
              0,
              ScrollDirection.idle,
              GlobalContext.fromDateWindow,
              GlobalContext.toDateWindow,
              () => setState(() {}));
          return true;
        } else if (notification is DataChangedNotification) {
          _dealWithDataChangedNotification(notification);
        } else if (notification is ScrollNotification) {
          _padScrollState(notification);
          return true;
        } else if (notification is StartChangeSplitControllerPageNotification) {
          _buttonScrollState(notification);
          return true;
        } else if (notification is ScheduleMarkedNotification) {
          setState(
            () {},
          );
          return true;
        } else if (notification is ScrollAndFocusNotification) {
          _joinedScroller.animateBothTo(
              notification.offset,
              Curves.linear,
              Duration(
                  milliseconds:
                      GlobalSettings.animationFocusScrollTimeTableMS));
          notification.doAfter();
        }

        return false;
      },
      child: _crossSplit,
    );

    var scaffold = Scaffold(
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
                    /**
                     * This one is the placeholder for the stack so that
                     * the left sidebar doesn't overlap the tab view
                     */
                    Container(
                        // color: Colors.red,
                        width: GlobalStyle.clockBarWidth +
                            GlobalStyle.clockBarToTabViewSpacer),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            /**
                             * This is the container that contains the buttons
                             * of the tab view on the top left side
                             */
                            // color: Colors.red,
                            margin: EdgeInsets.only(
                                right: constraints.maxWidth -
                                    GlobalStyle.clockBarWidth -
                                    3 * GlobalStyle.appBarTabBarTabWidth -
                                    GlobalStyle.clockBarToTabViewSpacer),
                            height: GlobalStyle.appBarHeight,
                            child: TabBar(
                              tabAlignment: TabAlignment.start,
                              padding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              controller: _controller,
                              isScrollable: true,
                              tabs: [
                                SizedBox(
                                  width: GlobalStyle.appBarTabBarTabWidth,
                                  child: Tab(
                                    icon: Icon(Icons.school),
                                  ),
                                ),
                                SizedBox(
                                  width: GlobalStyle.appBarTabBarTabWidth,
                                  child: Tab(
                                    icon: Icon(Icons.menu_book),
                                  ),
                                ),
                                SizedBox(
                                  width: GlobalStyle.appBarTabBarTabWidth,
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
                                  GlobalStyle.clockBarWidth -
                                  GlobalStyle.clockBarToTabViewSpacer,
                              child: TabBarView(
                                  controller: _controller,
                                  children: [
                                    split,
                                    Container(color: Colors.white),
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
              Row(children: [
                DragToMoveArea(
                  child: Material(
                    /**
                     * This is the entire left sidebar
                     */
                    clipBehavior: Clip.none,
                    elevation: 20,
                    child: Column(
                      children: [
                        /**
                         * This is the tiny widget with the light/dark theme switch
                         */
                        SizedBox(
                            // color: Colors.red,
                            width: GlobalStyle.clockBarWidth -
                                GlobalStyle.clockBarPadding / 2,
                            height: GlobalStyle.appBarHeight,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sunny,
                                  color: Colors.yellow,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, bottom: 4),
                                  child: Switch(
                                    value: _darkTheme,
                                    onChanged: (value) {
                                      setState(() {
                                        _darkTheme = !_darkTheme;
                                      });
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.nightlight,
                                  color: Colors.blue,
                                ),
                              ],
                            )),
                        /**
                         * This is the content of the left side bar with the watch and
                         * timing buttons
                         */
                        Expanded(
                            child: WatchManager(GlobalStyle.clockBarWidth -
                                2 * GlobalStyle.clockBarPadding)),
                      ],
                    ),
                  ),
                ),
                /**
                 * This is the thin line between the sidebar and the shadow
                 * of the sidebar
                 */
                VerticalDivider(
                  // color: Colors.orange,
                  thickness: GlobalStyle.appBarSeparatorWidth,
                  width: GlobalStyle.appBarSeparatorWidth,
                ),
              ]),
              /**
               * This is the overlay-edge around the entire program window
               * that allows grabbing and resizing
               */
              const DragToResizeArea(
                // resizeEdgeColor: Colors.red,
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

    return MaterialApp(
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
      themeMode: _darkTheme ? ThemeMode.dark : ThemeMode.light,
      home: (Platform.isLinux
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              child: scaffold)
          : scaffold),
    );
  }
}
