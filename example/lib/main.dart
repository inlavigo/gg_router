// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:gg_route/gg_route.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';

void main() {
  configureApp();
  runApp(MyApp());
}

// .............................................................................
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static final routeRootKey = GlobalKey();
}

// .............................................................................
class _MyAppState extends State<MyApp> {
  final _routerDelegate = GgRouterDelegate(
      child: Scaffold(
    body: GgRouteExample(),
  ));
  final _routeInformationParser = GgRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GgRouteExample',
      theme: ThemeData(
        primaryColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 2),
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

// .............................................................................

class GgRouteExample extends StatefulWidget {
  GgRouteExample({Key? key}) : super(key: key);

  @override
  _GgRouteExampleState createState() => _GgRouteExampleState();
}

class _GgRouteExampleState extends State<GgRouteExample> {
  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ......................................
        // Define /yellow, /green, /red
        GgRoute({
          '': _box(Colors.black),
          'yellow': _box(Colors.yellow),
          'green': _box(Colors.green),
          'red': _box(Colors.red,
              child: Column(
                // ..................................................
                // Define /red, /red/hello, /red/world
                children: [
                  GgRoute({
                    '': _text(''),
                    'hello': _text('hello'),
                    'world': _text('world'),
                  }),

                  // ...................................
                  // Define buttons to switch sub routes
                  Container(
                    color: Color(0xDDFFFFFF),
                    child: Row(
                      children: [
                        _naviButton('./hello', './hello'),
                        _naviButton('./world', './world'),
                        _naviButton('../yellow', '../yellow'),
                        _naviButton('/green', '/green'),
                      ],
                    ),
                  )
                ],
              )),
        }),

        // ...................
        // Define buttons to switch routes main routes
        Row(
          children: [
            _naviButton('Green', '/green'),
            _naviButton('Yellow', '/yellow'),
            _naviButton('Red', '/red'),
          ],
        ),
      ],
    );
  }

  // ...........................................................................
  Widget _box(Color color, {Widget? child}) {
    return Expanded(
        child: Container(
      color: color,
      child: child,
    ));
  }

  // ...........................................................................
  Widget _text(String text) => Expanded(child: Center(child: Text(text)));

  // ...........................................................................
  Widget _naviButton(String buttonText, String route) {
    return Builder(builder: (context) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: TextButton(
          onPressed: () => context.navigateTo(route),
          child: Text(buttonText),
        ),
      );
    });
  }
}
