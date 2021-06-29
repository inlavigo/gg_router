// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_router/src/gg_navigation_page.dart';

main() {
  group('GgNavigationPage', () {
    // .........................................................................
    GgNavigationPage _otherNavigationPage() {
      final result = GgNavigationPage(
        pageContent: (_) => Container(),
      );

      return result;
    }

    // .........................................................................
    testWidgets(
        'should throw an exception when index route shows a navigation page',
        (WidgetTester tester) async {
      // Create a navigation page using that router
      final navPage = GgNavigationPage(
        pageContent: (_) => _otherNavigationPage(),
      );

      // An error should be thrown complaining about index child being
      // an navigation page
      await tester.pumpWidget(
          GgRouter.root(child: navPage, node: GgRouteTreeNode.newRoot));
      final exception = tester.takeException();
      expect(exception.message,
          GgNavigationPage.indexWidgetMustNotBeANavigationPage);
    });
  });

  // .........................................................................
  testWidgets('should decorate the index page with a navigation bar',
      (WidgetTester tester) async {
    // Create a navigation page using that router
    final navPage = GgNavigationPage(
      pageContent: (_) => Container(),
    );

    // Expect the container to be decorated with a navigation bar
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: GgRouter.root(child: navPage, node: GgRouteTreeNode.newRoot)));

    final indexPage = GgEasyWidgetTest(find.byType(GgPageWithNavBar), tester);
    expect(indexPage.width, 800);
    expect(indexPage.height, 600);
  });
}
