// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_router/gg_router.dart';

main() {
  group('GgPopoverRouter', () {
    // .........................................................................
    late GgEasyWidgetTest<GgPopoverRouter, dynamic> ggOverlayRouter;
    final key = GlobalKey(debugLabel: 'GgPopoverRouter');
    final baseKey = ValueKey('base');
    final Widget base = Container(key: baseKey);

    final routeOnTop0Key = ValueKey('routeOnTop0');
    final Widget routeOnTop0 = Container(key: routeOnTop0Key);

    final routeOnTop1Key = ValueKey('routeOnTop1');
    final Widget routeOnTop1 = Container(key: routeOnTop1Key);
    late GgRouterCore baseRouter;
    GgRouterCore? routeOnTopRouter;

    // .........................................................................
    setUp(WidgetTester tester) async {
      final widget = GgPopoverRouter(
        key: key,
        backgroundWidget: Builder(builder: (context) {
          baseRouter = GgRouter.of(context);
          return base;
        }),
        foregroundRoutes: {
          'routeOnTop0': (context) {
            routeOnTopRouter = GgRouter.of(context);
            return routeOnTop0;
          },
          'routeOnTop1': (context) {
            routeOnTopRouter = GgRouter.of(context);
            return routeOnTop1;
          }
        },
        inAnimation: (context, animation, child, node) => Stack(
          children: [
            Text(
              '${animation.value}',
              key: ValueKey('inAnimation'),
            ),
            child
          ],
        ),
        outAnimation: (context, animation, child, node) => Stack(
          children: [
            Text(
              '${animation.value}',
              key: ValueKey('outAnimation'),
            ),
            child
          ],
        ),
        animationDuration: Duration(milliseconds: 1000),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: GgRouteInformationParser(),
          routerDelegate: GgRouterDelegate(child: widget, defaultRoute: '/'),
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

      expectAnimationValue(String prefix, String? value) {
        final finder = find.byKey(ValueKey('${prefix}Animation'));
        expect(finder, value == null ? findsNothing : findsOneWidget);
        if (value != null) {
          expect((tester.widget(finder) as Text).data, value);
        }
      }

      expect(ggOverlayRouter.width, 800);
      expect(ggOverlayRouter.height, 600);

      // Initially only the base widget is shown
      baseRouter.node.root.navigateTo('.');
      expect(baseRouter.node.root.stagedChildPath, '');
      expect(routeOnTopRouter, isNull);
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(routeOnTop0Key), findsNothing);
      expect(find.byKey(routeOnTop1Key), findsNothing);

      // ....................
      // No animation is done
      expectAnimationValue('in', null);
      expectAnimationValue('out', null);

      // ..............................
      // Now lets route to the routeOnTop0
      baseRouter.navigateTo('./routeOnTop0');
      await tester.pump(Duration(microseconds: 1));

      // .............................
      // The in animation should start
      expectAnimationValue('in', '0.0');
      expectAnimationValue('out', null);

      // Go to the middle of the animation
      await tester.pump(Duration(milliseconds: 500));
      expectAnimationValue('in', '0.5');
      expectAnimationValue('out', null);

      // At the end the animation should be completed
      await tester.pumpAndSettle();
      expectAnimationValue('in', null);
      expectAnimationValue('out', null);

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

      // ...............................
      // Now lets route back to the base
      debugger();
      baseRouter.navigateTo('.');
      debugger();
      await tester.pump(Duration(microseconds: 1));

      // .............................
      // The out animation should start
      expectAnimationValue('in', null);
      expectAnimationValue('out', '0.0');

      // Go to the middle of the animation
      await tester.pump(Duration(milliseconds: 500));
      expectAnimationValue('in', null);
      expectAnimationValue('out', '0.5');

      // At the end the animation should be completed
      await tester.pumpAndSettle();
      expectAnimationValue('in', null);
      expectAnimationValue('out', null);

      // No routeOnTop should be shown anymore
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(routeOnTop0Key), findsNothing);
      expect(find.byKey(routeOnTop1Key), findsNothing);

      await tearDown(tester);
    });
  });
}
