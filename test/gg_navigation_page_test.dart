// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
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
      final navPage = GgNavigationPageRoot(
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

    // .........................................................................
    testWidgets(
        'should throw an exception when GgNavigationPage is not wrapped into a root',
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
      expect(exception.message, GgNavigationPage.noNavigationPageRootFound);
    });

    // .........................................................................
    testWidgets('should decorate the index page with a navigation bar',
        (WidgetTester tester) async {
      // Create a navigation page using that router
      final navPage = GgNavigationPageRoot(
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

    // .........................................................................
    testWidgets(
        'should take over inAnimation, outAnimation and animationDuration froom root',
        (WidgetTester tester) async {
      // Define animationDuration, inAnimation, outAnimation
      final animationDuration = Duration(milliseconds: 345);

      final GgAnimationBuilder inAnimation = (
        BuildContext context,
        Animation animation,
        Widget child,
      ) {
        return child;
      };

      final GgAnimationBuilder outAnimation = (
        BuildContext context,
        Animation animation,
        Widget child,
      ) {
        return child;
      };

      // Create a widget
      final rootNode = GgRouteTreeNode.newRoot;
      final contentKey = GlobalKey();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GgRouter.root(
            node: rootNode,
            child: GgNavigationPageRoot(
              pageContent: (_) => Container(),
              animationDuration: animationDuration,
              inAnimation: inAnimation,
              outAnimation: outAnimation,
              children: {
                'childA': (_) {
                  return GgNavigationPage(
                      pageContent: (_) => Container(key: contentKey));
                }
              },
            ),
          ),
        ),
      );

      rootNode.navigateTo('/childA');
      await tester.pumpAndSettle();

      // Find the child page
      final routerFinder = find.byType(GgRouter);
      expect(routerFinder, findsNWidgets(3));

      final router1 = tester.widget<GgRouter>(routerFinder.at(1));
      final router2 = tester.widget<GgRouter>(routerFinder.at(2));

      // Check if child page has taken over animation values from root

      expect(router1.animationDuration, animationDuration);
      expect(router1.inAnimation, inAnimation);
      expect(router1.outAnimation, outAnimation);

      expect(router2.animationDuration, animationDuration);
      expect(router2.inAnimation, inAnimation);
      expect(router2.outAnimation, outAnimation);
    });
  });
}
