import 'dart:ui';

import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NewPlane(title: 'Flutter Demo Home Page'),
    );
  }
}

class NewPlane extends StatefulWidget {
  const NewPlane({super.key, required this.title});
  final String title;

  @override
  State<NewPlane> createState() => _NewPlaneState();
}

class _NewPlaneState extends State<NewPlane> {
  final ValueNotifier<String> stringValue = ValueNotifier('');
  @override
  Widget build(BuildContext context) {
    return TwoPane(
      startPane: MyHomePage(
          title: 'page 1',
          onClicked: (value) {
            stringValue.value = value;
          }),
      endPane: ValueListenableBuilder(
          valueListenable: stringValue,
          builder: (_, value, __) {
            return MyDetails(info: value);
          }),
      paneProportion: 0.5,
      panePriority: MediaQuery.sizeOf(context).width > 600
          ? TwoPanePriority.both
          : TwoPanePriority.start,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.onClicked});

  final String title;
  final Function(String) onClicked;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double angle = 360;
  bool hasSensor = false;
  FlutterView? view;
  final items =
      List<int>.generate(10000, (i) => i).map((i) => 'Item $i').toList();
  final ValueNotifier<double> stringValue = ValueNotifier(180);

  @override
  void initState() {
    super.initState();

    view = WidgetsBinding.instance.platformDispatcher.views.first;

    DualScreenInfo.hingeAngleEvents.listen((double hingeAngle) {
      setState(() {
        stringValue.value = hingeAngle;
      });
    });

    DualScreenInfo.hasHingeAngleSensor.then((bool hasHingeSensor) {
      setState(() {
        hasSensor = hasHingeSensor;
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Column(children: [
                  ValueListenableBuilder(
                      valueListenable: stringValue,
                      builder: (_, value, __) {
                        return Text(
                          'Angle of the hinge: $value',
                        );
                      }),
                  Text(
                    'hasSensor: $hasSensor',
                  ),
                  Text('Physical Width: ${view?.physicalSize.width}'),
                  Text('New API Width: ${view?.display.size.width}'),
                  Text('MediaSize Width: ${MediaQuery.sizeOf(context).width}'),
                  const SizedBox(height: 10),
                  Text('Physical height: ${view?.physicalSize.height}'),
                  Text('New API Height: ${view?.display.size.height}'),
                  Text(
                      'MediaSize Height: ${MediaQuery.sizeOf(context).height}'),
                  Text('Screen refresh rate: ${view?.display.refreshRate}'),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ])),
            Expanded(
                flex: 1,
                child: ListView.builder(
                  key: const PageStorageKey('eventsList'),
                  itemCount: items.length,
                  prototypeItem: ListTile(
                    title: Text(items.first),
                  ),
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        final data = MediaQueryData.fromView(view!);
                        if (data.size.shortestSide < 600) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyDetails(
                                        info: items[index],
                                      )));
                        } else {
                          widget.onClicked(items[index]);
                        }
                      },
                      title: Text(items[index]),
                    );
                  },
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MyDetails extends StatefulWidget {
  const MyDetails({super.key, required this.info});

  final String info;

  @override
  State<MyDetails> createState() => _MyDetailsState();
}

class _MyDetailsState extends State<MyDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Current Info:',
            ),
            Text(
              widget.info,
            ),
          ],
        ),
      ),
    );
  }
}
