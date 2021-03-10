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
  group('GgOverlayRouter', () {
    // .........................................................................
    late GgEasyWidgetTest<GgRouterOverlayWidget, dynamic> ggOverlayRouter;
    final key = GlobalKey(debugLabel: 'GgOverlayRouter');
    final baseKey = ValueKey('base');
    final Widget base = Container(key: baseKey);

    final overlay0Key = ValueKey('overlay0');
    final Widget overlay0 = Container(key: overlay0Key);

    final overlay1Key = ValueKey('overlay1');
    final Widget overlay1 = Container(key: overlay1Key);
    late GgRouterState baseRouter;
    GgRouterState? overlayRouter;

    // .........................................................................
    setUp(WidgetTester tester) async {
      final widget = GgRouterOverlayWidget(
        key: key,
        base: Builder(builder: (context) {
          baseRouter = GgRouter.of(context);
          return base;
        }),
        overlays: {
          'overlay0': (context) {
            overlayRouter = GgRouter.of(context);
            return overlay0;
          },
          'overlay1': (context) {
            overlayRouter = GgRouter.of(context);
            return overlay1;
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
      expect(overlayRouter, isNull);
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(overlay0Key), findsNothing);
      expect(find.byKey(overlay1Key), findsNothing);

      // ..............................
      // Now lets route to the overlay0
      baseRouter.navigateTo('./overlay0');
      await tester.pumpAndSettle();

      // The overlay0 should be shown infront of the base.
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(overlay0Key), findsOneWidget);
      expect(find.byKey(overlay1Key), findsNothing);

      // ..............................
      // Now lets route to the overlay1
      baseRouter.navigateTo('./overlay1');
      await tester.pumpAndSettle();

      // The overlay1 should be shown infront of the base.
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(overlay0Key), findsNothing);
      expect(find.byKey(overlay1Key), findsOneWidget);

      // ..............................
      // Now lets route back to the base
      baseRouter.navigateTo('.');
      await tester.pumpAndSettle();

      // No overlay should be shown anymore
      expect(find.byKey(baseKey), findsOneWidget);
      expect(find.byKey(overlay0Key), findsNothing);
      expect(find.byKey(overlay1Key), findsNothing);

      await tearDown(tester);
    });
  });
}
