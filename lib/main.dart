import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:scheduler/globalstate.dart';
import 'package:scheduler/split.dart';

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
        bottomLeft: Placeholder(color: Colors.purple),
        bottomRight: Placeholder(color: Colors.brown),
      )
    ); 
  }
}
