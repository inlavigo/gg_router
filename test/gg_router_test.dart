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

// #############################################################################
class TestRouteInformationProvider extends RouteInformationProvider
    with ChangeNotifier {
  RouteInformation get value => _routeInformation;
  set routeInformation(RouteInformation routeInformation) {
    _routeInformation = routeInformation;
    notifyListeners();
  }

  @override
  void routerReportsNewRouteInformation(RouteInformation routeInformation) {
    super.routerReportsNewRouteInformation(routeInformation);
  }

  RouteInformation _routeInformation = RouteInformation();
}

// #############################################################################

main() {
  // .........................................................................
  late GgEasyWidgetTest<GgRouter, dynamic> ggRoute;

  late GgRouteInformationParser routeInformationParser;
  late GgRouterDelegate routerDelegate;

  late GgRouterNode lastBuiltNode;
  late String? routeSegment;
  late String? childRouteSegment;
  late String routePath;

  late TestRouteInformationProvider routeInformationProvider;

  late GgEasyWidgetTest a0Button;
  late GgEasyWidgetTest a0OnlyButton;
  late GgEasyWidgetTest b0Button;

  // .........................................................................
  setUp(WidgetTester tester) async {
    // ..............................
    final builder = Builder(builder: (context) {
      final router = context.router;
      lastBuiltNode = router.node;
      routeSegment = context.router.routeSegment;
      childRouteSegment = context.router.activeChildRouteSegment;
      routePath = context.router.routePath;
      return Container();
    });

    // ..............................
    // Create a widget hierarchy /a/b
    final widget = Builder(
      builder: (context) {
        final router = context.router;
        return Column(children: [
          // ...............................
          // A button selecting route a0/a11
          TextButton(
            key: ValueKey('a0/a11 Button'),
            onPressed: () => context.router.navigateTo('a0/a11'),
            child: Container(),
          ),

          // ...............................
          // A button selecting route b0/b11
          TextButton(
            key: ValueKey('b0/b10 Button'),
            onPressed: () => context.router.navigateTo('b0/b10'),
            child: Container(),
          ),

          // ...............................
          // A button selecting route a0
          TextButton(
            key: ValueKey('a0/ Button'),
            onPressed: () => router.navigateTo('a0/'),
            child: Container(),
          ),

          // ..........
          // The routes
          GgRouter(
            {
              '': builder,
              'a0': Builder(builder: (context) {
                return Column(
                  children: [
                    Builder(builder: (context) {
                      return TextButton(
                        key: ValueKey('backButton'),
                        onPressed: () {
                          context.router.navigateTo('.');
                        },
                        child: Container(),
                      );
                    }),
                    GgRouter({
                      '': builder,
                      'a10': builder,
                      'a11': builder,
                    }),
                  ],
                );
              }),
              'b0': Builder(builder: (context) {
                return GgRouter({
                  'b10': builder,
                  'b11': builder,
                });
              }),
            },
          ),
        ]);
      },
    );

    // Create routeInformationProvider
    routeInformationProvider = TestRouteInformationProvider();

    // ........................
    // Create a router delegate
    routeInformationParser = GgRouteInformationParser();
    routerDelegate = GgRouterDelegate(child: widget);

    // .....................
    // Initialize the widget
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: routeInformationParser,
        routerDelegate: routerDelegate,
        routeInformationProvider: routeInformationProvider,
      ),
    );

    // ..................................
    // Create a GgEasyWidgetTest instance
    final ggRouteFinder = find.byWidget(widget);
    ggRoute = GgEasyWidgetTest(ggRouteFinder, tester);

    // ........................
    // Get reference to buttons
    a0Button = GgEasyWidgetTest(find.byKey(ValueKey('a0/a11 Button')), tester);
    a0OnlyButton = GgEasyWidgetTest(find.byKey(ValueKey('a0/ Button')), tester);
    b0Button = GgEasyWidgetTest(find.byKey(ValueKey('b0/b10 Button')), tester);
  }

  // .........................................................................
  tearDown(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  group('GgRouter', () {
    // .........................................................................
    testWidgets('should allow to synchronize URI and widget hierarchy',
        (WidgetTester tester) async {
      // .................
      // Create the widget
      await setUp(tester);
      expect(ggRoute.width, 800);
      expect(ggRoute.height, 600);

      // ................................................
      // Test if node hierarchy is synchronized correctly

      // By default the default route should be selected
      expect(lastBuiltNode.pathString, '/');

      // Now activate /a0 and check if node the hierarchy was rebuilt
      lastBuiltNode.child(name: 'a0').isActive = true;
      await tester.pumpAndSettle();
      expect(lastBuiltNode.pathString, '/a0');
      expect(routeSegment, 'a0');
      expect(routePath, '/a0');
      expect(childRouteSegment, null);

      // Now activate /a0/a11 and check if node the hierarchy was rebuilt
      lastBuiltNode.child(name: 'a11').isActive = true;
      await tester.pumpAndSettle();
      expect(lastBuiltNode.pathString, '/a0/a11');
      expect(routeSegment, 'a11');
      expect(routePath, '/a0/a11');

      // Now activate /b0 -> /b0/b10 should become active
      lastBuiltNode.parent!.parent!.child(name: 'b0').isActive = true;
      await tester.pumpAndSettle();
      expect(lastBuiltNode.pathString, '/b0/b10');

      // Now activate /b11 -> /b0/b11 should become active
      lastBuiltNode.parent!.child(name: 'b11').isActive = true;
      await tester.pumpAndSettle();
      expect(lastBuiltNode.pathString, '/b0/b11');

      // Now let's activate a unknown child. ->
      lastBuiltNode.parent!.child(name: 'unknown').isActive = true;
      await tester.pumpAndSettle();
      final textWidget = tester.widget(find.byType(Text)) as Text;
      expect(textWidget.data, 'Error 404 Not Found');

      // ..............................................................
      // Test if the url is updated correctly from the widget hierarchy
      String? lastUpdateUrl;
      routerDelegate.addListener(() {
        lastUpdateUrl = routerDelegate.currentConfiguration.location;
      });
      lastBuiltNode.parent!.parent!.activeChildPath = ['a0', 'a11'];
      await tester.pumpAndSettle();
      expect(lastUpdateUrl, 'a0/a11');

      lastBuiltNode.parent!.parent!.activeChildPath = ['b0', 'b10'];
      await tester.pumpAndSettle();
      expect(lastUpdateUrl, 'b0/b10');

      // .................................................................
      // Test if url changes are applied to the widget hierarchy correctly
      routeInformationProvider.routeInformation =
          RouteInformation(location: 'a0/a10');

      await tester.pumpAndSettle();
      expect(lastBuiltNode.pathString, '/a0/a10');

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('should allow to switch routes using other widgets',
        (WidgetTester tester) async {
      // .................
      // Create the widget
      await setUp(tester);

      // ...............
      // Press a0 button -> should activate '/a0/a11'
      await a0Button.press();
      expect(lastBuiltNode.pathString, '/a0/a11');

      // Press back button -> should activate '/a0'
      final backButton =
          GgEasyWidgetTest(find.byKey(ValueKey('backButton')), tester);
      await backButton.press();
      expect(lastBuiltNode.pathString, '/a0');

      // Press b0 Button -> Should activate '/b0/b10'
      await b0Button.press();
      expect(lastBuiltNode.pathString, '/b0/b10');

      // ...............
      // Press a0Only Button -> Should activate '/a0'
      await a0OnlyButton.press();
      expect(lastBuiltNode.pathString, '/a0');
    });
  });

  group('GgContextRouteExtension', () {
    // #########################################################################
    group('navigateTo(path)', () {
      test('should process absolute pathes', () {});
      test('should process relative pathes', () {});

      test('should process .. as parent path', () {});

      test('should process . as own path', () {});
    });
  });
}
