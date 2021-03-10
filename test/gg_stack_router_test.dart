// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_router/gg_router.dart';

main() {
  group('GgStackRouter', () {
    // .........................................................................
    late GgEasyWidgetTest<GgStackRouter, dynamic> ggOverlayRouter;
    final key = GlobalKey(debugLabel: 'GgStackRouter');
    final baseKey = ValueKey('base');
    final Widget base = Container(key: baseKey);

    final routeOnTop0Key = ValueKey('routeOnTop0');
    final Widget routeOnTop0 = Container(key: routeOnTop0Key);

    final routeOnTop1Key = ValueKey('routeOnTop1');
    final Widget routeOnTop1 = Container(key: routeOnTop1Key);
    late GgRouterState baseRouter;
    GgRouterState? routeOnTopRouter;

    // .........................................................................
    setUp(WidgetTester tester) async {
      final widget = GgStackRouter(
        key: key,
        baseWidget: Builder(builder: (context) {
          baseRouter = GgRouter.of(context);
          return base;
        }),
        routesOnTop: {
          'routeOnTop0': (context) {
            routeOnTopRouter = GgRouter.of(context);
            return routeOnTop0;
          },
          'routeOnTop1': (context) {
            routeOnTopRouter = GgRouter.of(context);
            return routeOnTop1;
          }
        },
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: GgRouteInformationParser(),
          routerDelegate: GgRouterDelegate(child: widget),
        ),
      );
      final ggOverlayRouterFinder = find.byWidget(widget);
      ggOverlayRouter = GgEasyWidgetTest(ggOverlayRouterFinder, tester);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should be instantiated correctly',
        (WidgetTester tester) async {
      await setUp(tester);
      expect(ggOverlayRouter.width, 800);
      expect(ggOverlayRouter.height, 600);

      // Initially only the base widget is shown
      expect(baseRouter.node.root.activeChildPathString, '');
      expect(routeOnTopRouter, isNull);
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(routeOnTop0Key), findsNothing);
      expect(find.byKey(routeOnTop1Key), findsNothing);

      // ..............................
      // Now lets route to the routeOnTop0
      baseRouter.navigateTo('./routeOnTop0');
      await tester.pumpAndSettle();

      // The routeOnTop0 should be shown infront of the base.
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(routeOnTop0Key), findsOneWidget);
      expect(find.byKey(routeOnTop1Key), findsNothing);

      // ..............................
      // Now lets route to the routeOnTop1
      baseRouter.navigateTo('./routeOnTop1');
      await tester.pumpAndSettle();

      // The routeOnTop1 should be shown infront of the base.
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(routeOnTop0Key), findsNothing);
      expect(find.byKey(routeOnTop1Key), findsOneWidget);

      // ..............................
      // Now lets route back to the base
      baseRouter.navigateTo('.');
      await tester.pumpAndSettle();

      // No routeOnTop should be shown anymore
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(routeOnTop0Key), findsNothing);
      expect(find.byKey(routeOnTop1Key), findsNothing);

      await tearDown(tester);
    });
  });
}
