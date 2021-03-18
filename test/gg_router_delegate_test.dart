// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_router/src/gg_router.dart';

main() {
  group('GgRouterDelegate', () {
    // .........................................................................
    late GgRouterDelegate routerDelegate;
    late GgRouteInformationParser routeInformationParser;
    late GgRouterCore router;

    const exampleData =
        '{"routeB":{"b": 1234}, "${GgRouteTreeNode.stagedChildJsonKey}":"routeB"}';

    // .........................................................................
    setUp(
      WidgetTester tester, {
      Function(String state)? saveState,
      Future<String?> Function()? restoreState,
    }) async {
      final builder =
          (Map<String, GgRouteParam> params) => (BuildContext context) {
                router = GgRouter.of(context);
                return GgRouteParams(
                    child: Container(key: ValueKey('content')), params: params);
              };

      final paramsA = GgRouteParam(seed: 5);
      final paramsB = GgRouteParam(seed: 6);

      final widget = GgRouter(
        {
          'routeA': builder({'a': paramsA}),
          'routeB': builder({'b': paramsB}),
          'routeC':
              builder({'c': GgRouteParam(seed: 7), 'd': GgRouteParam(seed: 8)}),
        },
        key: ValueKey('router'),
      );
      routeInformationParser = GgRouteInformationParser();
      routerDelegate = GgRouterDelegate(
        child: widget,
        saveState: saveState,
        restoreState: restoreState,
      );
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
      // should inform when the visible route changes
      bool routeDidChange = false;
      routerDelegate.addListener(() => routeDidChange = true);
      await tester.pumpAndSettle();
      expect(routeDidChange, false);
      routeDidChange = false;

      router.navigateTo('/routeB');
      await tester.pumpAndSettle();
      routeDidChange = true;

      // ........................................................
      // Set an initial route configuration with a null location.
      // => no routing should happen
      var result =
          routerDelegate.setInitialRoutePath(RouteInformation(location: null));
      expect(result, isInstanceOf<Future<void>>());
      await result;

      // ........................................................
      // Navigate to the root route. This should also lead to no navigation.
      // The app will navigate to the last saved state.
      result =
          routerDelegate.setInitialRoutePath(RouteInformation(location: '/'));
      expect(result, isInstanceOf<Future<void>>());
      await result;

      // ...........................................
      // Should provide the RouteInformation for the currently set path
      result = routerDelegate
          .setInitialRoutePath(RouteInformation(location: '/routeC'));
      await tester.pumpAndSettle();
      expect(routerDelegate.currentConfiguration.location!, 'routeC?c=7&d=8');
      expect(router.node.root.stagedChildPath, 'routeC');

      // ....................................................
      // Should apply RouteInformation to the route node tree
      routerDelegate.setNewRoutePath(RouteInformation(location: '/routeA'));
      expect(router.node.root.stagedChildPath, 'routeA');
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

      // ............................................
      // Should not do anything if URL contains errors
      final invalidRouteInformation = RouteInformation(location: ' \$d\$30:!!');
      routerDelegate.setNewRoutePath(invalidRouteInformation);

      await tester.pumpAndSettle();
      expect(routerDelegate.currentConfiguration.location!, 'routeA?a=6');

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('should load the data given by restoreState callback',
        (WidgetTester tester) async {
      await setUp(
        tester,
        restoreState: () => SynchronousFuture(exampleData),
      );
      expect(routerDelegate.root.stagedChildPath, 'routeB');
      expect(routerDelegate.root.child('routeB').param('b')?.value, 1234);
    });

    // .........................................................................
    testWidgets(
        'should save the route state automatically when a save callback is given',
        (WidgetTester tester) async {
      String? savedData;

      // Setup delegate with a saveState callback
      await setUp(tester, saveState: (state) => savedData = state);
      await tester.pumpAndSettle();
      savedData = null;

      // Change the route. The new route state should be saved automatically.
      routerDelegate.root.navigateTo('routeB');
      await tester.pumpAndSettle();
      expect(savedData,
          contains('"${GgRouteTreeNode.stagedChildJsonKey}":"routeB"'));
    });

    // .........................................................................
    testWidgets('should show an empty container until data is loaded',
        (WidgetTester tester) async {
      // Setup a completer yielding last saved state
      final loadData = Completer<String?>();

      // Start application.
      await setUp(
        tester,
        restoreState: () => loadData.future,
      );

      // Until completer has not completed, a loading
      // screen should be shown.
      var loadingScreen = find.byKey(ValueKey('RouterDelegateLoadingScreen'));
      expect(loadingScreen, findsOneWidget);
      var content = find.byKey(ValueKey('content'));
      expect(content, findsNothing);

      await tester.pumpAndSettle();

      // Now lets complete the loading
      loadData.complete(exampleData);
      await tester.pumpAndSettle();
      loadingScreen = find.byKey(ValueKey('RouterDelegateLoadingScreen'));
      expect(loadingScreen, findsNothing);
      content = find.byKey(ValueKey('content'));
      expect(content, findsOneWidget);
    });

    // .........................................................................
    test('dispose', () {
      final delegate = GgRouterDelegate(child: Container());
      delegate.dispose();
    });
  });
}
