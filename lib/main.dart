import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  late CrossSplit _crossSplit;
  late final TabController _controller;
  late final SplitController _splitController;
  final JoinedScroller _joinedScroller = JoinedScroller();
  ScrollDirection _direction = ScrollDirection.idle;
  double _pixels = -1;

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

  void _scrollState(Notification notification) {
    var from = GlobalContext.fromDateWindow;
    var to = GlobalContext.toDateWindow;
    if (notification is UserScrollNotification) {
      if (_direction == ScrollDirection.idle &&
          notification.direction == ScrollDirection.forward) {
        _direction = notification.direction;
        _pixels = notification.metrics.pixels;
        // print("left");
        GlobalContext.data.loadFT(GlobalSettings.pageViewScrollWaitTimeMS,
            _direction, from, to, () {});
      } else if (_direction == ScrollDirection.idle &&
          notification.direction == ScrollDirection.reverse) {
        _direction = notification.direction;
        _pixels = notification.metrics.pixels;
        // print("right");
        GlobalContext.data.loadFT(GlobalSettings.pageViewScrollWaitTimeMS,
            _direction, from, to, () {});
      } else if (notification.direction == ScrollDirection.idle) {
        print("Back to idle...");
        DateTime from = GlobalContext.fromDateWindow;
        DateTime to = GlobalContext.toDateWindow;
        _direction = notification.direction;
        if (_pixels < notification.metrics.pixels) {
          var next = DataUtils.getNextPage(from, to);
          GlobalContext.fromDateWindow = next["from"]!;
          GlobalContext.toDateWindow = next["to"]!;
          print(
              "page number increased ${GlobalContext.fromDateWindow} ${GlobalContext.toDateWindow}");
        } else if (_pixels > notification.metrics.pixels) {
          var prev = DataUtils.getPreviousPage(from, to);
          GlobalContext.fromDateWindow = prev["from"]!;
          GlobalContext.toDateWindow = prev["to"]!;
          print(
              "page number decreased ${GlobalContext.fromDateWindow} ${GlobalContext.toDateWindow}");
        }
        _pixels = -1;
        GlobalContext.data.loadFT(0, _direction, GlobalContext.fromDateWindow,
            GlobalContext.toDateWindow, () {
          setState(() {
            print("final idle load $_direction");
          });
        });
      }
    }
    if (notification is ScrollUpdateNotification) {
      if (_direction == ScrollDirection.forward) {
        if (_pixels < notification.metrics.pixels) {
          // print("left to right");
          _direction = ScrollDirection.reverse;
          GlobalContext.data.loadFT(GlobalSettings.pageViewScrollWaitTimeMS,
              _direction, from, to, () {});
        }
      } else if (_direction == ScrollDirection.reverse) {
        if (_pixels > notification.metrics.pixels) {
          // print("right to left");
          _direction = ScrollDirection.forward;
          GlobalContext.data.loadFT(GlobalSettings.pageViewScrollWaitTimeMS,
              _direction, from, to, () {});
        }
      }
    }
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
    );

    var split = NotificationListener(
      onNotification: (notification) {
        if (notification is DateChangedNotification) {
          GlobalContext.fromDateWindow = notification.from;
          GlobalContext.toDateWindow = notification.to;
          GlobalContext.data.loadFT(
              0,
              ScrollDirection.idle,
              GlobalContext.fromDateWindow,
              GlobalContext.toDateWindow,
              () => () => setState(() {}));
          return true;
        } else if (notification is DataChangedNotification) {
          _dealWithDataChangedNotification(notification);
        }
        // else if (notification is PageScrolledNotification) {
        //   /**
        //    * In here: change the from-to dates
        //    */
        //   _pixels = -1;
        //   _direction = ScrollDirection.idle;
        //   setState(() {
        //     DateTime from = GlobalContext.fromDateWindow;
        //     DateTime to = GlobalContext.toDateWindow;
        //     print("Page changed $from $to");
        //     if (notification.backwards) {
        //       var prev = DataUtils.getPreviousPage(from, to);
        //       GlobalContext.fromDateWindow = prev["from"]!;
        //       GlobalContext.toDateWindow = prev["to"]!;
        //     } else {
        //       var next = DataUtils.getNextPage(from, to);
        //       GlobalContext.fromDateWindow = next["from"]!;
        //       GlobalContext.toDateWindow = next["to"]!;
        //     }
        //     // GlobalContext.data.load();
        //   });
        //   return true;
        // }
        else if (notification is ScrollNotification) {
          _scrollState(notification);
          return true;
        } else if (notification is StartChangeSplitControllerPageNotification) {
          print("keep scrolling");
          // GlobalContext.data.load(notification.direction);
          var from = GlobalContext.fromDateWindow;
          var to = GlobalContext.toDateWindow;
          // setState(() {
          print("Scroll direction ${notification.direction}");
          if (notification.direction == ScrollDirection.forward) {
            var next = DataUtils.getNextPage(from, to);
            GlobalContext.fromDateWindow = next["from"]!;
            GlobalContext.toDateWindow = next["to"]!;
            print(
                "page number increased ${GlobalContext.fromDateWindow} ${GlobalContext.toDateWindow}");
          } else if (notification.direction == ScrollDirection.reverse) {
            var prev = DataUtils.getPreviousPage(from, to);
            GlobalContext.fromDateWindow = prev["from"]!;
            GlobalContext.toDateWindow = prev["to"]!;
            print(
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
                        print("finally idlying loading $_direction");
                      })));
          SplitContainer.setComponentState(CrossSplitComponent.tr, () {});
          // }
          // );
          return true;
        }

        // ?.then(
        //   (value) {
        //     print("move to next required page");
        //     var from = GlobalContext.fromDateWindow;
        //     var to = GlobalContext.toDateWindow;
        //     if (notification.direction == ScrollDirection.forward) {
        //       var next = DataUtils.getNextPage(from, to);
        //       GlobalContext.fromDateWindow = next["from"]!;
        //       GlobalContext.toDateWindow = next["to"]!;
        //     } else if (notification.direction == ScrollDirection.reverse) {
        //       var prev = DataUtils.getPreviousPage(from, to);
        //       GlobalContext.fromDateWindow = prev["from"]!;
        //       GlobalContext.toDateWindow = prev["to"]!;
        //     }
        //     setState(() {
        //       GlobalContext.data.load(ScrollDirection.idle);
        //     });
        //   },
        // );

        // if (notification.backwards) {
        //   var prev = DataUtils.getPreviousPage(from, to);
        //   _splitController.previousPage();
        //   _setPageBackwardsState(from, to);
        // } else {
        //
        //   _splitController.nextPage();
        //   _setPageForwardState(from, to);
        // }
        else if (notification is ScheduleMarkedNotification) {
          setState(
            () {},
          );
        } else if (notification is ScrollAndFocusNotification) {
          _joinedScroller.animateBothTo(
              notification.offset,
              Curves.linear,
              Duration(
                  milliseconds:
                      GlobalSettings.animationFocusScrollTimeTableMS));
          notification.doAfter();
        }
        // else if (notification is UserScrollNotification) {
        //   if (notification.direction == ScrollDirection.forward) {
        //     return true;
        //   } else if (notification.direction == ScrollDirection.reverse) {
        //     return true;
        //   }
        // }

        return false;
      },
      child: _crossSplit,
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
                    SizedBox(width: GlobalStyle.clockBarWidth),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(
                                right: constraints.maxWidth -
                                    GlobalStyle.clockBarWidth -
                                    3 * GlobalStyle.appBarTabBarTabWidth),
                            height: GlobalStyle.appBarHeight,
                            child: TabBar(
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
                                  GlobalStyle.clockBarWidth,
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
                    clipBehavior: Clip.none,
                    elevation: 20,
                    child: Column(
                      children: [
                        SizedBox(
                            width: GlobalStyle.clockBarWidth - 1,
                            height: GlobalStyle.appBarHeight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                "lib/img/title_clock.svg",
                                alignment: Alignment.centerLeft,
                              ),
                            )),
                        Expanded(
                            child: WatchManager(GlobalStyle.clockBarWidth -
                                GlobalStyle.appBarSeparatorWidth -
                                2 * GlobalStyle.clockBarPadding)),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                  thickness: GlobalStyle.appBarSeparatorWidth,
                  width: GlobalStyle.appBarSeparatorWidth,
                ),
              ]),
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
