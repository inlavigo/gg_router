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
                  GgRouter(
                    {
                      '_INDEX_': subBuilder,
                      'a10': subBuilder,
                      'a11': subBuilder,
                    },
                    key: ValueKey('a0SubRouter'),
                  ),
                ],
              );
            },
            'b0': (context) {
              return GgRouter(
                {
                  'b10': subBuilder,
                  'b11': subBuilder,
                },
                key: ValueKey('b0SubRouter'),
              );
            },
          },
          key: ValueKey('mainRouter'),
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
  setUp(WidgetTester tester,
      {Widget? child, String initialRoute = '/_INDEX_'}) async {
    // Create routeInformationProvider
    routeInformationProvider = TestRouteInformationProvider();

    final widget = child ?? defaultChild;

    // ........................
    // Create a router delegate
    routeInformationParser = GgRouteInformationParser();
    routerDelegate =
        GgRouterDelegate(child: widget, defaultRoute: initialRoute);

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

      a0 = lastBuiltNode.root.findOrCreateChild('a0');
      b0 = lastBuiltNode.root.findOrCreateChild('b0');
      a11 = a0.findOrCreateChild('a11');
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
      a0.navigateTo('.');
      await tester.pumpAndSettle();
      update();
      expect(lastBuiltNode.path, '/a0/_INDEX_');
      expect(routeSegment, '_INDEX_');
      expect(routePath, '/a0/_INDEX_');
      expect(childRouteSegment, null);

      // Now activate /a0/a11 and check if node the hierarchy was rebuilt
      a11.navigateTo('.');
      await tester.pumpAndSettle();
      update();
      expect(lastBuiltNode.path, '/a0/a11');
      expect(routeSegment, 'a11');
      expect(routePath, '/a0/a11');

      // Now activate /b0 -> /a0/a11 should stay visible
      // because no _INDEX_ route has been defined for b0
      lastBuiltNode.parent!.parent!.findOrCreateChild('b0').navigateTo('.');

      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/a0/a11');

      // Now activate /b11 -> /b0/b11 should become visible
      lastBuiltNode.root.navigateTo('/b0/b11');
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/b0/b11');

      // Now let's activate an invalid route. ->
      // The previous defined route should stay visible
      lastBuiltNode.parent!.findOrCreateChild('unknown').navigateTo('.');
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/b0/b11');

      // ..............................................................
      // Test if the url is updated correctly from the widget hierarchy
      String? lastUpdateUrl;
      routerDelegate.addListener(() {
        lastUpdateUrl = routerDelegate.currentConfiguration.location;
      });

      lastBuiltNode.parent!.parent!.stagedChildPathSegments = ['a0', 'a11'];
      await tester.pumpAndSettle();
      expect(lastUpdateUrl, 'a0/a11');

      lastBuiltNode.parent!.parent!.stagedChildPathSegments = ['b0', 'b10'];
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
          'Route "/a0" has no child named "invalidRoute" nor does your GgRouter define a "*" wild card route.');

      // ..................................................
      // Invalid URLs should be removed from the route tree
      expect(lastBuiltNode.root.hasChild(name: 'a0'), true);
      expect(
        lastBuiltNode.root
            .findOrCreateChild('a0')
            .hasChild(name: 'invalidRoute'),
        false,
      );

      // .................................................................
      // Test if an missing _INDEX_ route makes GgRouter showing an error widget.
      // Additionally the error handler should be called.
      lastBuiltNode.root.errorHandler = null;
      lastBuiltNode.root.errorHandler = (error) => receivedError = error;

      routeInformationProvider.routeInformation =
          RouteInformation(location: 'b0/');
      await tester.pumpAndSettle();
      expect(lastBuiltNode.path, '/a0/a10');
      expect(receivedError!.id, 'GRC008505');
      expect(receivedError!.message,
          'Route "/b0" has no "_INDEX_" route and also no defaultRoute set. It cannot be displayed.');

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

        // .............................................................................
        await setUp(tester, child: Builder(builder: (c0) {
          rootRouter = GgRouter.of(c0);
          rootRouter.node.navigateTo('routeA/childRouteA');

          final builder = (BuildContext c1, String x) {
            context = c1;
            router = GgRouter.of(c1);

            final childName = 'childRoute$x';
            router.node.findOrCreateChild(childName).navigateTo('.');

            return GgRouter(
              {
                childName: (c2) {
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
              },
              key: ValueKey('childRouter_$x'),
            );
          };

          return GgRouter(
            {
              'routeA': (c) => builder(c, 'A'),
              'routeB': (c) => builder(c, 'B'),
              'routeC': (c) => builder(c, 'C'),
            },
            key: ValueKey('mainRouter'),
          );
        }));

        await tester.pumpAndSettle();

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
        // GgRouter.of(context).routeNameOfStagedChild should give the name
        // of the visible child route, or null if no child route is visible.
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
        // GgRouter.of(context).indexOfStagedChild should give the index
        // of the visible child route, or null if no child route is visible.
        expect(rootRouter.indexOfActiveChild, 0);
        expect(childRouter.indexOfActiveChild, null);
        router.navigateTo('/routeC');
        expect(rootRouter.routeNameOfActiveChild, 'routeC');
        await tester.pumpAndSettle();
        expect(rootRouter.routeNameOfActiveChild, 'routeC');
        expect(rootRouter.indexOfActiveChild, 2);

        // .......................................................
        // GgRouter.of(context).onStagedChildChange should inform, when the
        // visible child changes
        expect(router.routeName, 'routeC');
        bool? onStagedChildChangeDidFire;
        final s = rootRouter.onActiveChildChange
            .listen((event) => onStagedChildChangeDidFire = true);

        await tester.pumpAndSettle();
        expect(onStagedChildChangeDidFire, isNull);

        // GgRouter.of(context).navigateTo() should allow to navigate relatively
        router.navigateTo('../routeB');
        await tester.pumpAndSettle();
        expect(onStagedChildChangeDidFire, true);

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
        'should update indexOfStagedChild when order of widgets changes',
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
                  final indexOfStagedChild = router.indexOfActiveChild;
                  if (showAAtFirstPlace.value) {
                    expect(indexOfStagedChild, 0);
                    expect(router.routeNameOfActiveChild, 'a');
                  } else {
                    expect(indexOfStagedChild, 1);
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
                            }, key: ValueKey('Router1'))
                          : GgRouter({
                              'b': (_) => Container(),
                              'a': routeA,
                            }, key: ValueKey('Router2'));
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
    group('Default children', () {
      // .......................................................................
      testWidgets(
          'An error should be thrown if defaultChild is not one of the child routes',
          (WidgetTester tester) async {
        await setUp(
          tester,
          child: Builder(builder: (context) {
            return GgRouter(
              {'a': (_) => Container()},
              key: GlobalKey(),
              defaultRoute: 'b',
            );
          }),
        );

        expect(tester.takeException(), predicate((ArgumentError f) {
          expect(f.message,
              'Error GRC008506: The defaultChild "b" does not exist.');
          return true;
        }));
      });

      // .......................................................................
      testWidgets('Should write the default child into the node',
          (WidgetTester tester) async {
        late GgRouteTreeNode root;

        await setUp(
          tester,
          initialRoute: '/a',
          child: Builder(builder: (context) {
            root = GgRouter.of(context).node.root;
            return GgRouter(
              {'a': (_) => Container()},
              key: GlobalKey(),
              defaultRoute: 'a',
            );
          }),
        );

        expect(root.defaultChildName, 'a');
      });
    });

    // #########################################################################
    group('Wild card routes', () {
      // .......................................................................
      testWidgets(
          'If no wild card is defined and an unknown route is opened, an error is thrown.',
          (WidgetTester tester) async {
        // .......................................
        // Define a router with no wild card route
        await setUp(
          tester,
          child: Builder(builder: (context) {
            return GgRouter(
              {
                'a': (_) => Container(),
                '_INDEX_': (_) => Container(),
              },
              key: GlobalKey(),
              defaultRoute: 'a',
            );
          }),
        );

        // ........................................
        // Route to a known route first -> no error
        routerDelegate.root.navigateTo('/a');
        await tester.pumpAndSettle();
        expect(tester.takeException(), null);

        // .................................
        // Route to an unknown route -> error

        // .........................
        GgRouteTreeNodeError? error;
        routerDelegate.root.errorHandler = (err) => error = err;
        routerDelegate.root.navigateTo('/unknown');

        await tester.pumpAndSettle();
        expect(error!.message,
            'Route "/" has no child named "unknown" nor does your GgRouter define a "*" wild card route.');
      });

      // .......................................................................
      testWidgets(
          'If a wild card is defined and we navigate to an unknown route, the wild card route is opened.',
          (WidgetTester tester) async {
        // .......................................
        // Define a router with no wild card route

        final wildCardKey = GlobalKey();
        final routeAKey = GlobalKey();

        await setUp(
          tester,
          child: Builder(builder: (context) {
            return GgRouter(
              {
                'a': (_) => Container(key: routeAKey),
                '_INDEX_': (_) => Container(),
                '*': (_) => Container(key: wildCardKey),
              },
              key: GlobalKey(),
              defaultRoute: 'a',
            );
          }),
        );

        // ............................
        // Route to a known route first
        routerDelegate.root.navigateTo('/a');
        await tester.pumpAndSettle();
        expect(find.byKey(routeAKey), findsOneWidget);
        expect(find.byKey(wildCardKey), findsNothing);

        // .....................................................
        // Route to an unknown route -> wild card route is opened
        routerDelegate.root.navigateTo('/unknown');
        await tester.pumpAndSettle();
        expect(find.byKey(routeAKey), findsNothing);
        expect(find.byKey(wildCardKey), findsOneWidget);
        expect(routerDelegate.currentConfiguration.location, 'unknown');
      });
    });

    // #########################################################################
    group('Route animations', () {
      late Text inAnimationWidget;
      late Text outAnimationWidget;
      int? indexOfChildAnimatingIn;
      int? indexOfChildAnimatingOut;
      String? nameOfChildAnimatingIn;
      String? nameOfChildAnimatingOut;

      update(WidgetTester tester) {
        inAnimationWidget =
            tester.widget(find.byKey(Key('inAnimation'))) as Text;
        outAnimationWidget =
            tester.widget(find.byKey(Key('outAnimation'))) as Text;
      }

      updateAnimationDetails(BuildContext context) {
        indexOfChildAnimatingIn = GgRouter.of(context).indexOfChildAnimatingIn;
        indexOfChildAnimatingOut =
            GgRouter.of(context).indexOfChildAnimatingOut;
        nameOfChildAnimatingIn = GgRouter.of(context).nameOfChildAnimatingIn;
        nameOfChildAnimatingOut = GgRouter.of(context).nameOfChildAnimatingOut;
      }

      checkAnimationDetails(
          int? indexIn, int? indexOut, String? nameIn, String? nameOut) {
        expect(indexOfChildAnimatingIn, indexIn);
        expect(indexOfChildAnimatingOut, indexOut);
        expect(nameOfChildAnimatingIn, nameIn);
        expect(nameOfChildAnimatingOut, nameOut);
      }

      testWidgets('should animate route transitions',
          (WidgetTester tester) async {
        final routeAKey = Key('routeA');
        final routeBKey = Key('routeB');

        // ................................
        // Create a route with two siblings
        final router = GgRouter(
          {
            'routeA': (context) => Container(key: routeAKey),
            'routeB': (context) => Container(key: routeBKey),
          },
          key: ValueKey('mainRouter'),

          // Wrap animated widgets into a stack showing a text with the
          // animation value
          inAnimation: (context, animation, child) {
            updateAnimationDetails(context);
            return Stack(
              children: [
                child,
                Text(
                  '${animation.value}',
                  key: Key('inAnimation'),
                )
              ],
            );
          },
          outAnimation: (context, animation, child) {
            updateAnimationDetails(context);
            return Stack(
              children: [
                child,
                Text(
                  '${animation.value}',
                  key: Key('outAnimation'),
                )
              ],
            );
          },
          animationDuration: Duration(milliseconds: 1000),
        );

        // ........................
        // Create a router delegate
        final routerDelegate = GgRouterDelegate(child: router);
        final root = routerDelegate.root;
        root.findOrCreateChild('routeA').navigateTo('.');

        // .............
        // Create an app
        await tester.pumpWidget(
          MaterialApp.router(
            routeInformationParser: GgRouteInformationParser(),
            routerDelegate: routerDelegate,
          ),
        );
        await tester.pumpAndSettle();

        // ......................................
        // At the beginning routeA should be shown
        expect(find.byKey(routeAKey), findsOneWidget);
        expect(find.byKey(routeBKey), findsNothing);

        // ........................................
        // No animation details should be available
        checkAnimationDetails(null, null, null, null);

        // ..........................
        // Now let's switch to routeB
        root.findOrCreateChild('routeB').navigateTo('.');

        // ..........................
        // At the beginning both, routeA and routeB should be visbible
        // because both are animating
        await tester.pump(Duration(microseconds: 0));
        update(tester);
        expect(find.byKey(routeAKey), findsOneWidget);
        expect(find.byKey(routeBKey), findsOneWidget);

        // The right animation values should be delivered
        expect(inAnimationWidget.data, '0.0');
        expect(outAnimationWidget.data, '0.0');
        checkAnimationDetails(1, 0, 'routeB', 'routeA');

        // Now jump to the middle of the animation and check if the
        // right animation values were delivered.
        await tester.pump(Duration(milliseconds: 500));
        update(tester);
        expect(inAnimationWidget.data, '0.5');
        expect(outAnimationWidget.data, '0.5');

        // Once the animation has finished, only the new route should be
        // visible
        await tester.pump(Duration(milliseconds: 1001));
        expect(find.byKey(routeAKey), findsNothing);
        expect(find.byKey(routeBKey), findsOneWidget);

        // Finish everything
        await tester.pumpAndSettle();
      });
    });

    // #########################################################################
    group('Semantic labels', () {
      test(
          'should throw an exception if semantic labels for non existing routes are defined',
          () {
        expect(() {
          GgRouter({}, semanticLabels: {'xyz': 'X Y Z'}, key: GlobalKey());
        }, throwsA(predicate((ArgumentError e) {
          expect(e.message,
              'You specified a semantic label for route "xyz", but you did not setup a route with name "xyz".');
          return true;
        })));
      });

      test('should pass if semantic labels match the routes', () {
        GgRouter({'xyz': (_) => Container()},
            semanticLabels: {'xyz': 'X Y Z'}, key: GlobalKey());
      });

      testWidgets(
        "Semantic labels should be written to route tree",
        (WidgetTester tester) async {
          // ..................
          // Create a root node
          final root = GgRouteTreeNode.newRoot;

          // ......................
          // Instantiate the router
          await tester.pumpWidget(
            GgRouter.root(
                child: GgRouter(
                  {
                    'xyz': (_) => Container(key: GlobalKey()),
                    'abc': (_) => Container(key: GlobalKey()),
                  },
                  semanticLabels: {
                    'xyz': 'XYZ Label',
                    'abc': 'ABC Label',
                  },
                  key: GlobalKey(),
                  defaultRoute: 'xyz',
                ),
                node: root),
          );

          // ..............................................................
          // Check if the semantic labels have ben written to the node tree
          expect(root.child('xyz')?.semanticLabel, 'XYZ Label');
          expect(root.child('abc')?.semanticLabel, 'ABC Label');
        },
      );

      testWidgets('Semantic labels should also work for PopoverRoute',
          (WidgetTester tester) async {
        // ......................
        // Create a popover route
        final root = GgRouteTreeNode.newRoot;
        await tester.pumpWidget(
          GgRouter.root(
              child: GgPopoverRoute(
                key: GlobalKey(),
                name: 'xyz',
                base: Container(),
                popover: (_) => Container(),
                semanticLabel: 'XYZ Label',
              ),
              node: root),
        );

        // ........................................
        // Has semantic label been written to node?
        expect(root.child('xyz')?.semanticLabel, 'XYZ Label');
      });

      testWidgets(
          'GgRouter.of(context).semanticLabelForPath() should return the right semantic label',
          (WidgetTester tester) async {
        // ...................
        // Create a route tree
        final root = GgRouteTreeNode.newRoot;
        bool didCheck = false;
        await tester.pumpWidget(
          GgRouter.root(
              child: GgRouter(
                {
                  'childA': (_) {
                    return GgRouter(
                      {
                        'childA0': (context) {
                          didCheck = true;

                          // ...................................................
                          // Check if semantic labels can be retrieved correctly
                          expect(
                            GgRouter.of(context).semanticLabelForPath('../'),
                            'childA',
                          );

                          expect(
                            GgRouter.of(context).semanticLabelForPath('../../'),
                            root.name,
                          );

                          expect(
                            GgRouter.of(context)
                                .semanticLabelForPath('../../childB'),
                            'childB Label',
                          );

                          return Container();
                        }
                      },
                      key: GlobalKey(),
                      defaultRoute: 'childA0',
                    );
                  },
                  'childB': (_) {
                    return Container();
                  },
                },
                semanticLabels: {'childB': 'childB Label'},
                key: GlobalKey(),
                defaultRoute: 'childA',
              ),
              node: root),
        );

        // .....................
        // Check semantic labels
        expect(didCheck, true);
      });
    });
  });
}
