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
    late GgRouteTreeNode rootNode;
    late GgRouter routerRoot;

    // .........................................................................
    setUp(WidgetTester tester, Widget widget) async {
      rootNode = GgRouteTreeNode.newRoot;
      routerRoot = GgRouter.root(child: widget, node: rootNode);
      await tester.pumpWidget(routerRoot);
      await tester.pumpAndSettle();
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    GgNavigationPage _otherNavigationPage() {
      final result = GgNavigationPage(
        router: GgRouter({'_INDEX_': (_) => Container()},
            key: GlobalKey(debugLabel: 'otherNavigationPages router')),
      );

      return result;
    }

    // .........................................................................
    testWidgets(
        'should throw an exception when router does not contain an index route',
        (WidgetTester tester) async {
      final router = GgRouter(
        {'a': (_) => Container()},
        key: GlobalKey(),
        defaultRoute: 'a',
      );
      await setUp(tester, GgNavigationPage(router: router));

      var exception = tester.takeException();

      expect(exception, isNotNull);
      expect(exception.message, GgNavigationPage.indexRouteIsMissingError);

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets(
        'should throw an exception when index route shows a navigation page',
        (WidgetTester tester) async {
      // Create a router which has a navigation page as index
      // (which is not allowed)
      final router = GgRouter(
        {'_INDEX_': (_) => _otherNavigationPage()},
        key: GlobalKey(debugLabel: 'Outer Router'),
      );

      // Create a navigation page using that router
      final navPage = GgNavigationPage(router: router);

      // An error should be thrown complaining about index child being
      // an navigation page
      await tester.pumpWidget(
          GgRouter.root(child: navPage, node: GgRouteTreeNode.newRoot));
      final exception = tester.takeException();
      expect(exception.message,
          GgNavigationPage.indexWidgetMustNotBeANavigationPage);
    });

    // .........................................................................
    testWidgets(
        'should throw an exception when child route is not a navigation page',
        (WidgetTester tester) async {
      // Create a router which has a child not being an navigation page
      final router = GgRouter(
        {
          '_INDEX_': (_) => Container(),
          'child': (_) => Container(), // This must be a navigation page
        },
        key: GlobalKey(debugLabel: 'Outer Router'),
        defaultRoute: 'child',
      );

      // Create a navigation page using that router
      final navPage = GgNavigationPage(router: router);

      // Navigate to child
      final root = GgRouteTreeNode.newRoot;
      root.navigateTo('/child');

      // An error should be thrown complaining about index child being
      // an navigation page
      await tester.pumpWidget(GgRouter.root(child: navPage, node: root));
      final exception = tester.takeException();
      expect(exception.message,
          GgNavigationPage.otherChildrenMustBeANavigationPage);
    });
  });

  // .........................................................................
  testWidgets('should decorate the index page with a navigation bar',
      (WidgetTester tester) async {
    // Create a router which has a child not being an navigation page
    final router = GgRouter(
      {
        '_INDEX_': (_) => Container(),
      },
      key: GlobalKey(debugLabel: 'Decorated index page'),
    );

    // Create a navigation page using that router
    final navPage = GgNavigationPage(router: router);

    // Expect the container to be decorated with a navigation bar
    await tester.pumpWidget(
        GgRouter.root(child: navPage, node: GgRouteTreeNode.newRoot));

    final indexPage = GgEasyWidgetTest(find.byType(GgPageWithNavBar), tester);
    expect(indexPage.width, 800);
    expect(indexPage.height, 600);
  });
}
