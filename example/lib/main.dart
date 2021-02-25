import 'package:flutter/material.dart';
import 'package:gg_lite_route/gg_lite_route.dart';

void main() {
  runApp(MyApp());
}

// .............................................................................
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GgLiteRouteExample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GgLiteRouteExample(),
    );
  }

  static final liteRouteRootKey = GlobalKey();
}

// .............................................................................
class GgLiteRouteExample extends StatelessWidget {
  GgLiteRouteExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 3)),
      builder: (context, snapshot) {
        return Container(
          color: Colors.white,
          child: GgLiteRoute(
            name: 'blue',
            child: Container(
              color: Colors.blue,
              child: GgLiteRoute(
                name: 'yellow',
                child: Container(color: Colors.yellow),
              ),
            ),
          ),
        );
      },
    );
  }
}
