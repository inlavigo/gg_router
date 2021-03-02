// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_router/src/gg_route_core.dart';

main() {
  group('GgRouterCore', () {
    // .........................................................................
    late GgEasyWidgetTest<GgRouterCore, dynamic> ggRouteCore;
    final child = Container();
    late GgRouterNode node;

    // .........................................................................
    setUp(WidgetTester tester) async {
      node = GgRouterNode(name: '');

      final widget = GgRouterCore(
        child: child,
        node: node,
      );
      await tester.pumpWidget(widget);
      final ggRouteCoreFinder = find.byWidget(widget);
      ggRouteCore = GgEasyWidgetTest(ggRouteCoreFinder, tester);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should be instantiated correctly',
        (WidgetTester tester) async {
      await setUp(tester);
      expect(ggRouteCore.width, 800);
      expect(ggRouteCore.height, 600);
      await tearDown(tester);
    });
  });
}
