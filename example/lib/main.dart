// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:gg_route/gg_route.dart';

void main() {
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
  final _routerDelegate = GgRouterDelegate(child: GgRouteExample());
  final _routeInformationParser = GgRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GgRouteExample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

// .............................................................................
class GgRouteExample extends StatelessWidget {
  GgRouteExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,

      // .................
      // Create blue route
      child: GgRoute(
        name: 'blue',
        child: Container(
          color: Colors.blue,

          // .........................
          // Create yellow child route
          child: GgRoute(
            name: 'yellow',
            child: Container(color: Colors.yellow),
          ),
        ),
      ),
    );
  }
}
