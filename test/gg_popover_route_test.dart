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
  group('GgPopoverRoute', () {
    // .........................................................................
    late GgEasyWidgetTest<GgPopoverRoute, dynamic> ggOverlayRouter;
    final key = GlobalKey(debugLabel: 'GgPopoverRoute');

    final baseKey = ValueKey('base');
    final Widget base = Text('Base', key: baseKey);

    final popoverKey = ValueKey('popover');
    final Widget popover = Text('Popover', key: popoverKey);

    late GgRouteTreeNode root;

    GgRouterCore? routeOnTopRouter;

    // .........................................................................
    setUp(WidgetTester tester) async {
      final widget = GgPopoverRoute(
        key: key,
        name: 'popover',
        base: base,
        popover: (_) => popover,
        inAnimation: (context, animation, child) => Stack(
          children: [
            Text(
              '${animation.value}',
              key: ValueKey('inAnimation'),
            ),
            child
          ],
        ),
        outAnimation: (context, animation, child) => Stack(
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
      final routerDelegate = GgRouterDelegate(child: widget, defaultRoute: '/');
      root = routerDelegate.root;
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: GgRouteInformationParser(),
          routerDelegate: routerDelegate,
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
      root.navigateTo('.');
      expect(root.stagedChildPath, '');
      expect(routeOnTopRouter, isNull);
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(popoverKey), findsNothing);

      // ....................
      // No animation is done
      expectAnimationValue('in', null);
      expectAnimationValue('out', null);

      // .........................
      // Now lets open the popover
      root.navigateTo('./popover');
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
      expect(find.byKey(popoverKey), findsOneWidget);

      // ...............................
      // Now lets route back to the base
      root.navigateTo('.');
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
      expect(find.byKey(popoverKey), findsNothing);

      await tearDown(tester);
    });
  });
}
