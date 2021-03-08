// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_router/gg_router.dart';

main() {
  group('GgRouteParamsWidget', () {
    // .........................................................................
    late GgEasyWidgetTest<GgRouteParamsWidget, dynamic> ggRouteParamsWidget;
    final key = GlobalKey(debugLabel: 'GgRouteParamsWidget');

    // .........................................................................
    setUp(WidgetTester tester) async {
      final widget = GgRouteParamsWidget(
        key: key,
        params: {'a': GgRouteParam(seed: 5)},
        builder: (context) {
          return Container();
        },
      );
      expect(widget.updateShouldNotify(widget), true);
      await tester.pumpWidget(widget);
      final ggRouteParamsWidgetFinder = find.byWidget(widget);
      ggRouteParamsWidget = GgEasyWidgetTest(ggRouteParamsWidgetFinder, tester);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should be instantiated correctly',
        (WidgetTester tester) async {
      await setUp(tester);
      expect(ggRouteParamsWidget.width, 800);
      expect(ggRouteParamsWidget.height, 600);
      await tearDown(tester);
    });
  });
}
