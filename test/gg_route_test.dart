// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_route/gg_route.dart';
import 'package:gg_route/src/gg_route_core.dart';
import 'package:gg_value/gg_value.dart';

main() {
  group('GgRoute', () {
    // .........................................................................
    late GgEasyWidgetTest<GgRoute, dynamic> ggRoute;

    late GgRouteInformationParser routeInformationParser;
    late GgRouterDelegate routerDelegate;

    late Widget hierarchyAB;
    late Widget hierarchyAC;

    late GgRouteNode root;
    late GgRouteNode nodeA;
    late GgRouteNode nodeB;
    GgRouteNode? nodeC;

    late StreamController<bool> showHierarchyAC;

    // .........................................................................
    setUp(WidgetTester tester) async {
      // ..............................
      // Create a widget hierarchy /a/b
      hierarchyAB = GgRoute(
        name: 'a',
        child: GgRoute(
          name: 'b',
          child: Builder(builder: (context) {
            nodeB = GgRouteCore.of(context)!.node;
            nodeA = nodeB.parent!;
            root = nodeA.parent!;
            return Container();
          }),
        ),
      );

      // ..............................
      // Create a widget hierarchy /a/c
      hierarchyAC = GgRoute(
        name: 'a',
        child: GgRoute(
          name: 'c',
          child: Builder(builder: (context) {
            nodeC = GgRouteCore.of(context)!.node;
            nodeA = nodeB.parent!;
            root = nodeA.parent!;
            return Container();
          }),
        ),
      );

      // ..............................
      // Create switcher
      showHierarchyAC = StreamController<bool>();
      final switcher = StreamBuilder(
        stream: showHierarchyAC.stream,
        builder: (context, snapshot) {
          bool showHierarchyAC = snapshot.hasData && snapshot.data == true;
          return showHierarchyAC ? hierarchyAC : hierarchyAB;
        },
      );

      // ........................
      // Create a router delegate
      routeInformationParser = GgRouteInformationParser();
      routerDelegate = GgRouterDelegate(child: switcher);

      // .....................
      // Initialize the widget
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: routeInformationParser,
          routerDelegate: routerDelegate,
        ),
      );

      // ..................................
      // Create a GgEasyWidgetTest instance
      final ggRouteFinder = find.byWidget(hierarchyAB);
      ggRoute = GgEasyWidgetTest(ggRouteFinder, tester);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
      showHierarchyAC.close();
    }

    // .........................................................................
    testWidgets('should be instantiated correctly',
        (WidgetTester tester) async {
      // .................
      // Create the widget
      await setUp(tester);
      expect(ggRoute.width, 800);
      expect(ggRoute.height, 600);

      // ................................................
      // Check if a node hierarchy /a/b/ has been created
      expect(root.pathString, '/');
      expect(nodeA.pathString, '/a');
      expect(nodeB.pathString, '/a/b');

      // The path /a/b should be active
      expect(root.activeChildPath.join('/'), 'a/b');
      expect(root.isActive, true);
      expect(nodeA.isActive, true);
      expect(nodeB.isActive, true);

      // ................................
      // Switch to the hierarchy /a/b1/c1
      showHierarchyAC.add(true);
      await tester.pumpAndSettle();

      // Check if node hierarchy /a/c has been created
      expect(nodeC, isNotNull);
      expect(nodeC!.parent, nodeA);

      // Check if path a/c is active
      expect(root.activeChildPath.join('/'), 'a/c');

      // Check if node b is not active anymore
      expect(nodeB.isActive, false);

      await tearDown(tester);
    });
  });
}
