// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';

void main() {
  configureApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _routerDelegate = GgRouterDelegate(
      child: Scaffold(
    body: GgRouterExample(),
  ));
  final _routeInformationParser = GgRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GgRouterExample',
      theme: ThemeData(
        primaryColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 2),
      ),
      debugShowCheckedModeBanner: false,
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

// .............................................................................
class GgRouterExample extends StatelessWidget {
  const GgRouterExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ......................................
        // Define /yellow, /green, /red
        GgRouter({
          '': _box(Colors.black),
          'yellow': _box(Colors.yellow),
          'green': _box(Colors.green),
          'red': _box(Colors.red,
              child: Column(
                // ..................................................
                // Define /red, /red/hello, /red/world
                children: [
                  GgRouter({
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
