// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_router/src/gg_router_widget.dart';

main() {
  group('GgRouterDelegate', () {
    // .........................................................................
    late GgRouterDelegate routerDelegate;
    late GgRouteInformationParser routeInformationParser;
    late GgRouter router;

    // .........................................................................
    setUp(WidgetTester tester) async {
      final builder = (BuildContext context) {
        router = GgRouter.of(context);
        return Container();
      };

      final widget = GgRouterWidget({
        'routeA': builder,
        'routeB': builder,
        'routeC': builder,
      });
      routeInformationParser = GgRouteInformationParser();
      routerDelegate = GgRouterDelegate(child: widget);
      final app = MaterialApp.router(
          routeInformationParser: routeInformationParser,
          routerDelegate: routerDelegate);
      await tester.pumpWidget(app);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should work correctly', (WidgetTester tester) async {
      await setUp(tester);

      // ...........................................
      // should inform when the active route changes
      bool routeDidChange = false;
      routerDelegate.addListener(() => routeDidChange = true);
      await tester.pumpAndSettle();
      expect(routeDidChange, true);
      routeDidChange = false;

      router.navigateTo('/routeB');
      await tester.pumpAndSettle();
      routeDidChange = true;

      // ...........................................
      // Should provide the RouteInformation for the currently set path
      router.navigateTo('/routeC');
      await tester.pumpAndSettle();
      expect(routerDelegate.currentConfiguration.location!, 'routeC');
      expect(router.node.root.activeChildPathString, 'routeC');

      // ...........................................
      // Should apply RouteInformation to the route node tree
      routerDelegate.setNewRoutePath(RouteInformation(location: '/routeA'));
      expect(router.node.root.activeChildPathString, 'routeA');

      await tearDown(tester);
    });

    // .........................................................................
    test('dispose', () {
      final delegate = GgRouterDelegate(child: Container());
      delegate.dispose();
    });
  });
}
