// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_router/src/gg_router.dart';

main() {
  group('GgRouterDelegate', () {
    // .........................................................................
    late GgRouterDelegate routerDelegate;
    late GgRouteInformationParser routeInformationParser;
    late GgRouterState router;

    // .........................................................................
    setUp(WidgetTester tester) async {
      final builder =
          (Map<String, GgRouteParam> params) => (BuildContext context) {
                router = GgRouter.of(context);
                return GgRouteParams(child: Container(), params: params);
              };

      final paramsA = GgRouteParam(seed: 5);
      final paramsB = GgRouteParam(seed: 6);

      final widget = GgRouter({
        'routeA': builder({'a': paramsA}),
        'routeB': builder({'b': paramsB}),
        'routeC':
            builder({'c': GgRouteParam(seed: 7), 'd': GgRouteParam(seed: 8)}),
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
      expect(routeDidChange, false);
      routeDidChange = false;

      router.navigateTo('/routeB');
      await tester.pumpAndSettle();
      routeDidChange = true;

      // ...........................................
      // Should provide the RouteInformation for the currently set path
      router.navigateTo('/routeC');
      await tester.pumpAndSettle();
      expect(routerDelegate.currentConfiguration.location!, 'routeC?c=7&d=8');
      expect(router.node.root.activeChildPathString, 'routeC');

      // ....................................................
      // Should apply RouteInformation to the route node tree
      routerDelegate.setNewRoutePath(RouteInformation(location: '/routeA'));
      expect(router.node.root.activeChildPathString, 'routeA');
      expect(routerDelegate.currentConfiguration.location!, 'routeA?a=5');
      await tester.pumpAndSettle();

      // ..............................
      // Should also write query params
      routerDelegate
          .setNewRoutePath(RouteInformation(location: '/routeA?a=123'));
      router.node.param('a')!.value = 6;

      // ..............................
      // Should write unknown parameters to uriParams
      routerDelegate
          .setNewRoutePath(RouteInformation(location: '/routeA?unknown=456'));
      expect(router.node.uriParamForName('unknown'), '456');

      // ............................................
      // Should write changes of a param to the route
      router.node.param('a')!.value = 6;
      await tester.pumpAndSettle();
      expect(routerDelegate.currentConfiguration.location!, 'routeA?a=6');

      await tearDown(tester);
    });

    // .........................................................................
    test('dispose', () {
      final delegate = GgRouterDelegate(child: Container());
      delegate.dispose();
    });
  });
}
