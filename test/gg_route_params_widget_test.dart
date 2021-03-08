// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:gg_router/gg_router.dart';

main() {
  group('GgRouteParamsWidget', () {
    // .........................................................................
    final key = GlobalKey(debugLabel: 'GgRouteParamsWidget');

    // .........................................................................
    setUp(WidgetTester tester, {Widget? child}) async {
      final widget = GgRouteParamsWidget(
        key: key,
        params: {'a': GgRouteParam(seed: 5)},
        child: child ?? Container(),
      );

      await tester.pumpWidget(widget);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should write the params into node',
        (WidgetTester tester) async {
      await setUp(tester);
      await tearDown(tester);
    });

    // .........................................................................
    testWidgets(
        'should throw an exception if a parameter is used multiple times in the same route.',
        (WidgetTester tester) async {
      await setUp(
        tester,
        child: GgRouteParamsWidget(
          params: {'a': GgRouteParam(seed: 5)},
          child: Container(),
        ),
      );

      expect(
          tester.takeException().message,
          'Cannot process route param "a". '
          'There is already a parent GgRouteParams object, containing a route param with the name "a". '
          'Make sure you are using unique param names accross a route and its parents.');

      await tearDown(tester);
    });
  });
}
