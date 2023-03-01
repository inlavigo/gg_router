// @license
// Copyright (c) 2019 - 2023 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_value/gg_value.dart';

void main() {
  late WidgetTester tester;

  Widget dummy(BuildContext context) => const SizedBox();
  late GgValue<WidgetBuilder?> closeButton;
  late GgValue<WidgetBuilder?> backButton;

  late GgNavigationPageOverridesProvider navigationPageOverrides;
  GgNavigationPageOverrides? receivedOverrides;
  late GgRouteTreeNode node;

  group('NavigationPageOverrides', () {
    // .........................................................................
    Future<void> setUp(WidgetTester tst) async {
      node = GgRouteTreeNode.newRoot;

      navigationPageOverrides = GgNavigationPageOverridesProvider(
        child: Builder(
          builder: (context) {
            receivedOverrides = GgNavigationPageOverrides.of(context);
            closeButton = receivedOverrides!.closeButton;
            backButton = receivedOverrides!.backButton;
            return const SizedBox();
          },
        ),
      );

      tester = tst;
      final widget = GgRouter.root(
        node: node,
        child: navigationPageOverrides,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        ),
      );

      await tester.pumpAndSettle();
    }

    // .........................................................................
    Future<void> tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should be instantiated correctly',
        (WidgetTester tester) async {
      await setUp(tester);

      // Initially, there are no overrides for close and back button
      expect(receivedOverrides, isNotNull);
      expect(closeButton.value, isNull);
      expect(backButton.value, isNull);

      // Overwrite back and close button
      closeButton.value = dummy;
      backButton.value = dummy;
      await tester.pumpAndSettle();
      expect(closeButton.value, dummy);
      expect(backButton.value, dummy);

      // Now lets switch to another route
      node.findOrCreateChild('another-route');
      node.navigateTo('another-route');
      await tester.pumpAndSettle();

      // The overrides should be reset on route change
      expect(closeButton.value, isNull);
      expect(backButton.value, isNull);

      // Cleanup
      await tearDown(tester);
    });
  });
}
