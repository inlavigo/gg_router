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
import 'package:gg_value/gg_value.dart';

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

  late GgRouteTreeNode lastBuiltNode;
  late String? routeSegment;
  late String? childRouteSegment;
  late String routePath;

  late TestRouteInformationProvider routeInformationProvider;

  late GgEasyWidgetTest a0Button;
  late GgEasyWidgetTest a0OnlyButton;
  late GgEasyWidgetTest b0Button;

  // ..............................
  final subBuilder = (BuildContext context) {
    final router = GgRouter.of(context);
    lastBuiltNode = router.node;
    routeSegment = GgRouter.of(context).routeName;
    childRouteSegment = GgRouter.of(context).routeNameOfActiveChild;
    routePath = GgRouter.of(context).routePath;
    return Container();
  };

  // ..............................
  // Create a widget hierarchy /a/b
  final defaultChild = Builder(
    builder: (context) {
      final router = GgRouter.of(context);
      router.node.root.errorHandler = null;
      router.node.root.errorHandler = (_) {};
      return Column(children: [
        // ...............................
        // A button selecting route a0/a11
        TextButton(
          key: ValueKey('a0/a11 Button'),
          onPressed: () => GgRouter.of(context).navigateTo('a0/a11'),
          child: Container(),
        ),

        // ...............................
        // A button selecting route b0/b11
        TextButton(
          key: ValueKey('b0/b10 Button'),
          onPressed: () => GgRouter.of(context).navigateTo('b0/b10'),
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
            '_INDEX_': subBuilder,
            'a0': (context) {
              return Column(
                children: [
                  Builder(builder: (context) {
                    return TextButton(
                      key: ValueKey('backButton'),
                      onPressed: () {
                        GgRouter.of(context).navigateTo('.');
                      },
                      child: Container(),
                    );
                  }),
                  GgRouter({
                    '_INDEX_': subBuilder,
                    'a10': subBuilder,
                    'a11': subBuilder,
                  }),
                ],
              );
            },
            'b0': (context) {
              return GgRouter({
                'b10': subBuilder,
                'b11': subBuilder,
              });
            },
          },
        ),
      ]);
    },
  );

  // ...........................................................................
  updateAAndBButtons(WidgetTester tester) {
    // ........................
    // Get reference to buttons
    a0Button = GgEasyWidgetTest(find.byKey(ValueKey('a0/a11 Button')), tester);
    a0OnlyButton = GgEasyWidgetTest(find.byKey(ValueKey('a0/ Button')), tester);
    b0Button = GgEasyWidgetTest(find.byKey(ValueKey('b0/b10 Button')), tester);
  }

  // .........................................................................
  setUp(WidgetTester tester, {Widget? child}) async {
    // Create routeInformationProvider
    routeInformationProvider = TestRouteInformationProvider();

    final widget = child ?? defaultChild;

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

    await tester.pumpAndSettle();

    // ..................................
    // Create a GgEasyWidgetTest instance
    final ggRouteFinder = find.byWidget(widget);
    ggRoute = GgEasyWidgetTest(ggRouteFinder, tester);
  }

  // .........................................................................
  tearDown(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  group('GgRouter', () {
    late GgRouteTreeNode index;
    late GgRouteTreeNode a0;
    late GgRouteTreeNode b0;
    late GgRouteTreeNode a11;

    update() {
      index = lastBuiltNode;

      a0 = lastBuiltNode.root.child('a0');
      b0 = lastBuiltNode.root.child('b0');
      a11 = a0.child('a11');
    }

    // .........................................................................
    testWidgets('should allow to synchronize URI and widget hierarchy',
        (WidgetTester tester) async {
      // .................
      // Create the widget
      await setUp(tester);
      update();
      updateAAndBButtons(tester);
      expect(ggRoute.width, 800);
      expect(ggRoute.height, 600);

      // ................................................
      // Test if node hierarchy is synchronized correctly

      // By default the default route should be selected
      expect(index.path, '/_INDEX_');

      // The right widget indices should have been assigned
      expect(index.widgetIndex, 0);
      expect(a0.widgetIndex, 1);
      expect(b0.widgetIndex, 2);

      // Now activate /a0 and check if node the hierarchy was rebuilt
      a0.isActive = true;
      await tester.pumpAndSettle();
      update();
      expect(lastBuiltNode.path, '/a0/_INDEX_');
      expect(routeSegment, '_INDEX_');
      expect(routePath, '/a0/_INDEX_');
      expect(childRouteSegment, null);

      // Now activate /a0/a11 and check if node the hierarchy was rebuilt
      a11.isActive = true;
      await tester.pumpAndSettle();
      update();
      expect(lastBuiltNode.path, '/a0/a11');
      expect(routeSegment, 'a11');
      expect(routePath, '/a0/a11');

      // Now activate /b0 -> /b0/b10 should become active
      lastBuiltNode.parent!.parent!.child('b0').isActive = true;
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/b0/b10');

      // Now activate /b11 -> /b0/b11 should become active
      lastBuiltNode.parent!.child('b11').isActive = true;
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/b0/b11');

      // Now let's activate an invalid route. ->
      // The previous defined route should stay active
      lastBuiltNode.parent!.child('unknown').isActive = true;
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/b0/b11');

      // ..............................................................
      // Test if the url is updated correctly from the widget hierarchy
      String? lastUpdateUrl;
      routerDelegate.addListener(() {
        lastUpdateUrl = routerDelegate.currentConfiguration.location;
      });
      lastBuiltNode.parent!.parent!.activeChildPathSegments = ['a0', 'a11'];
      await tester.pumpAndSettle();
      expect(lastUpdateUrl, 'a0/a11');

      lastBuiltNode.parent!.parent!.activeChildPathSegments = ['b0', 'b10'];
      await tester.pumpAndSettle();
      expect(lastUpdateUrl, 'b0/b10');

      // .................................................................
      // Test if url changes are applied to the widget hierarchy correctly
      routeInformationProvider.routeInformation =
          RouteInformation(location: 'a0/a10');

      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/a0/a10');

      // .................................................................
      // Test if an invalid url makes GgRouter showing an error widget.
      // Additionally the error handler should be called.
      GgRouteTreeNodeError? receivedError;
      lastBuiltNode.root.errorHandler = null;
      lastBuiltNode.root.errorHandler = (error) => receivedError = error;

      routeInformationProvider.routeInformation =
          RouteInformation(location: 'a0/invalidRoute');
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/a0/a10');
      expect(receivedError!.id, 'GRC008448');
      expect(receivedError!.message,
          'Route "/a0" has no child named "invalidRoute".');

      // ..................................................
      // Invalid URLs should be removed from the route tree
      expect(lastBuiltNode.root.hasChild(name: 'a0'), true);
      expect(
        lastBuiltNode.root.child('a0').hasChild(name: 'invalidRoute'),
        false,
      );

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('should allow to switch routes using other widgets',
        (WidgetTester tester) async {
      // .................
      // Create the widget
      await setUp(tester);
      updateAAndBButtons(tester);

      // ...............
      // Press a0 button -> should activate '/a0/a11'
      await a0Button.press();
      expect(lastBuiltNode.path, '/a0/a11');

      // Press back button -> should activate '/a0/_INDEX_'
      final backButton =
          GgEasyWidgetTest(find.byKey(ValueKey('backButton')), tester);
      await backButton.press();
      expect(lastBuiltNode.path, '/a0/_INDEX_');

      // Press b0 Button -> Should activate '/b0/b10'
      await b0Button.press();
      expect(lastBuiltNode.path, '/b0/b10');

      // ...............
      // Press a0Only Button -> Should activate '/a0/_INDEX_'
      await a0OnlyButton.press();
      expect(lastBuiltNode.path, '/a0/_INDEX_');
    });

    // .........................................................................
    testWidgets(
      'GgRouter.of(context) should work correctly',
      (WidgetTester tester) async {
        BuildContext? context;

        late GgRouterCore rootRouter;
        late GgRouterCore rootRouter2;
        late GgRouterCore router;
        late GgRouterCore childRouter;
        late String? lastBuiltParam;

        await setUp(tester, child: Builder(builder: (c0) {
          rootRouter = GgRouter.of(c0);

          final builder = (BuildContext c1, String x) {
            context = c1;
            router = GgRouter.of(c1);
            return GgRouter({
              'childRoute$x': (c2) {
                childRouter = GgRouter.of(c2);
                rootRouter2 = GgRouter.of(c2, rootRouter: true);
                return GgRouteParams(
                  params: {'param': GgRouteParam(seed: x)},
                  child: Builder(
                    builder: (c3) {
                      lastBuiltParam = GgRouter.of(c3).param('param')?.value;
                      return Container();
                    },
                  ),
                );
              }
            });
          };

          return GgRouter({
            'routeA': (c) => builder(c, 'A'),
            'routeB': (c) => builder(c, 'B'),
            'routeC': (c) => builder(c, 'C'),
          });
        }));

        expect(context!, isNotNull);

        // .............................................................
        // GgRouter.of(context) should give the current context's router
        expect(router, isInstanceOf<GgRouterCore>());
        expect(childRouter, isInstanceOf<GgRouterCore>());

        // .......................................................
        // GgRouter.of(context).node should give the route node assigned to the
        // current context, in our case this is the first route
        expect(router.node.name, 'routeA');
        expect(childRouter.node.name, 'childRouteA');

        // .......................................................
        // GgRouter.of(context).routeName should give the name of the
        // route segment
        expect(router.routeName, 'routeA');
        expect(childRouter.routeName, 'childRouteA');

        // .......................................................
        // GgRouter.of(context).routeNameOfActiveChild should give the name
        // of the active child route, or null if no child route is active.
        expect(router.routeNameOfActiveChild, 'childRouteA');
        expect(childRouter.routeNameOfActiveChild, null);

        // .......................................................
        // GgRouter.of(context).routePath should give the complete path
        // of the route
        expect(router.routePath, '/routeA');
        expect(childRouter.routePath, '/routeA/childRouteA');

        // .......................................................
        // GgRouter.of(context).routeParam('param') should give the param
        // with name 'param.
        expect(lastBuiltParam, 'A');

        // .............................................................
        // GgRouter.of(context, rootRouter: true) should the root router
        expect(rootRouter2, rootRouter);

        // .......................................................
        // GgRouter.of(context).indexOfActiveChild should give the index
        // of the active child route, or null if no child route is active.
        expect(rootRouter.indexOfActiveChild, 0);
        expect(childRouter.indexOfActiveChild, null);
        router.navigateTo('/routeC');
        await tester.pumpAndSettle();
        expect(rootRouter.indexOfActiveChild, 2);

        // .......................................................
        // GgRouter.of(context).onActiveChildChange should inform, when the
        // active child changes
        bool? onActiveChildChangeDidFire;
        final s = router.onActiveChildChange
            .listen((event) => onActiveChildChangeDidFire = true);

        await tester.pumpAndSettle();
        expect(onActiveChildChangeDidFire, isNull);

        // GgRouter.of(context).navigateTo() should allow to navigate relatively
        router.navigateTo('../routeB');
        await tester.pumpAndSettle();
        expect(onActiveChildChangeDidFire, true);

        expect(router.routePath, '/routeB');
        expect(childRouter.routePath, '/routeB/childRouteB');

        // GgRouter.of(context).navigateTo() should allow to navigate absolutely
        childRouter.navigateTo('/routeC');
        await tester.pumpAndSettle();
        expect(router.routePath, '/routeC');
        expect(childRouter.routePath, '/routeC/childRouteC');

        // GgRouter.of(context) should throw if context is not a child of
        // GgRouterDelegate

        await tester.pumpWidget(
          Builder(
            builder: (context) {
              GgRouter.of(context);
              return Container();
            },
          ),
        );

        expect(tester.takeException().message,
            GgRouter.noGgRouterDelegateFoundError);

        s.cancel();

        await tearDown(tester);
      },
    );

    // .........................................................................
    testWidgets(
        'should update indexOfActiveChild when order of widgets changes',
        (WidgetTester tester) async {
      routeInformationProvider = TestRouteInformationProvider();

      final showAAtFirstPlace = GgValue(seed: false);

      await setUp(tester,
          child: StreamBuilder(
              stream: showAAtFirstPlace.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                // Create route a. Route a will be on first place in variant 1
                // and on second place in variant 2.
                final routeA = (_) {
                  final router = GgRouter.of(context);
                  final indexOfActiveChild = router.indexOfActiveChild;
                  if (showAAtFirstPlace.value) {
                    expect(indexOfActiveChild, 0);
                    expect(router.routeNameOfActiveChild, 'a');
                  } else {
                    expect(indexOfActiveChild, 1);
                    expect(router.routeNameOfActiveChild, 'a');
                  }

                  return Container();
                };

                return StreamBuilder(
                    stream: GgRouter.of(context).onActiveChildChange,
                    builder: (context, snapshot) {
                      // Exchange the places of route 'a'
                      return showAAtFirstPlace.value
                          ? GgRouter({
                              'a': routeA,
                              'b': (_) => Container(),
                            })
                          : GgRouter({
                              'b': (_) => Container(),
                              'a': routeA,
                            });
                    });
              }));

      await tester.pumpAndSettle();
      showAAtFirstPlace.value = true;
      routerDelegate.root.navigateTo('a');
      await tester.pumpAndSettle();
      showAAtFirstPlace.value = false;
      await tester.pumpAndSettle();
    });

    // #########################################################################
    // group('Route animations', () {
    //   testWidgets('switch between two siblings', (WidgetTester tester) async {
    //     final routeAKey = Key('routeA');
    //     final routeBKey = Key('routeB');

    //     // ................................
    //     // Create a route with two siblings
    //     final router = GgRouter({
    //       'routeA': (context) => Container(key: routeAKey),
    //       'routeB': (context) => Container(key: routeBKey),
    //     });

    //     // ........................
    //     // Create a router delegate
    //     final routerDelegate = GgRouterDelegate(child: router);
    //     final root = routerDelegate.root;
    //     root.child('routeA').isActive = true;

    //     // .............
    //     // Create an app
    //     await tester.pumpWidget(
    //       MaterialApp.router(
    //         routeInformationParser: GgRouteInformationParser(),
    //         routerDelegate: routerDelegate,
    //       ),
    //     );
    //     await tester.pumpAndSettle();

    //     // ......................................
    //     // At the beginning routeA should be shown
    //     expect(find.byKey(routeAKey), findsOneWidget);
    //     expect(find.byKey(routeBKey), findsNothing);

    //     // ..........................
    //     // Now let's switch to routeB
    //     root.child('childB').isActive = true;

    //     // At the beginning both, routeA and routeB should be visbible
    //     // because both are animating
    //     tester.pumpFrames(router, Duration(milliseconds: 1));
    //     expect(find.byKey(routeAKey), findsOneWidget);
    //     expect(find.byKey(routeBKey), findsOneWidget);
    //   });
    // });
  });
}
