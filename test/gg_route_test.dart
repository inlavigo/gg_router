// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_route/gg_route.dart';
import 'package:gg_route/src/gg_route_core.dart';

main() {
  group('GgRoute', () {
    // .........................................................................
    late GgEasyWidgetTest<GgRoute, dynamic> ggRoute;

    late GgRouteInformationParser routeInformationParser;
    late GgRouterDelegate routerDelegate;

    late GgRouteNode lastBuiltNode;

    // .........................................................................
    setUp(WidgetTester tester) async {
      // ..............................
      final builder = Builder(builder: (context) {
        lastBuiltNode = GgRouteCore.of(context)!.node;
        return Container();
      });

      // ..............................
      // Create a widget hierarchy /a/b
      final widget = GgRoute(
        {
          'a0': GgRoute({
            'a10': builder,
            'a11': builder,
          }),
          'b0': GgRoute({
            'b10': builder,
            'b11': builder,
          })
        },
      );

      // ........................
      // Create a router delegate
      routeInformationParser = GgRouteInformationParser();
      routerDelegate = GgRouterDelegate(child: widget);

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
      final ggRouteFinder = find.byWidget(widget);
      ggRoute = GgEasyWidgetTest(ggRouteFinder, tester);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
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
      // Check if a node hierarchy /a0/a10/ has been created
      expect(lastBuiltNode.pathString, '/a0/a10');

      // Now activate /a0/a11 and check if node the hierarchy was rebuilt
      lastBuiltNode.parent!.child(name: 'a11').isActive = true;
      await tester.pumpAndSettle();
      expect(lastBuiltNode.pathString, '/a0/a11');

      // Now activate /b0 -> /b0/b10 should become active
      lastBuiltNode.parent!.parent!.child(name: 'b0').isActive = true;
      await tester.pumpAndSettle();
      expect(lastBuiltNode.pathString, '/b0/b10');

      // Now activate /b11 -> /b0/b11 should become active
      lastBuiltNode.parent!.child(name: 'b11').isActive = true;
      await tester.pumpAndSettle();
      expect(lastBuiltNode.pathString, '/b0/b11');

      // Now let's activate a unknown child. ->
      lastBuiltNode.parent!.child(name: 'unknown').isActive = true;
      await tester.pumpAndSettle();
      final textWidget = tester.widget(find.byType(Text)) as Text;
      expect(textWidget.data, 'Error 404 Not Found');

      await tearDown(tester);
    });
  });
}
