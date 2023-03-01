// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_value/gg_value.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';

void main() {
  configureApp();
  runApp(GgRouterExample());
}

const debugShowCheckedModeBanner = false;

// #############################################################################
class MyNavigationPage extends StatelessWidget {
  const MyNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GgNavigationPage(
      // Setup page content
      showBackButton: false,
      pageContent: (ctx2) => Center(
        child: Column(
          children: [
            Row(children: [
              Spacer(),
            ]),
            Spacer(),
            _checkBox(context),
            Container(
              height: 30,
            ),
            TextButton(
              key: ValueKey('Details Button'),
              onPressed: () => GgRouter.of(ctx2).navigateTo('details'),
              child: Text('Details'),
            ),
            Spacer(),
          ],
        ),
      ),
      children: {
        'details': GgNavigationPage(
          pageContent: (ctx3) => Container(
            color: Color(0xFF555555),
            child: Center(
                child: TextButton(
                    key: ValueKey('More Details Button'),
                    onPressed: () {
                      GgRouter.of(ctx3).navigateTo('more-details');
                    },
                    child: Text('More details'))),
          ),
          children: {
            'more-details': GgNavigationPage(
              pageContent: (_) => Container(
                color: Color(0xFF666666),
                child: Center(
                  child: Text('More details'),
                ),
              ),
            )
          },
          semanticLabels: {
            'more-details': 'More Details',
          },
        )
      },
      semanticLabels: {
        'details': 'Details',
      },
    );
  }

  // ...........................................................................
  // ...........................................................................
  Widget _checkBox(BuildContext context) {
    final GgValue param = GgRouter.of(context).param('visit')!;

    return Row(children: [
      Expanded(child: Container()),
      SizedBox(
        width: 200,
        height: 50,
        child: Container(
          color: Color(0x11FFFFFF),
          child: StreamBuilder(
            stream: param.stream,
            builder: (context, snapshot) {
              return CheckboxListTile(
                title: Text("Visit Event"),
                value: param.value,
                onChanged: (newValue) => param.value = newValue as bool,
              );
            },
          ),
        ),
      ),
      Expanded(child: Container()),
    ]);
  }
}

// #############################################################################
class GgRouterExample extends StatelessWidget {
  GgRouterExample({Key? key}) : super(key: key);

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "GgRouterExample",
      routerDelegate: GgRouterDelegate(
        child: _appContent,
        saveState: _saveState,
        restoreState: _restoreState,
        defaultRoute: '/sports/basketball',
      ),
      routeInformationParser: GgRouteInformationParser(),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(brightness: Brightness.dark),
      theme: ThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      showSemanticsDebugger: false,
    );
  }

  // ...........................................................................
  Widget get _appContent {
    return Scaffold(
      appBar: AppBar(
        title: Text('GgRouter'),
        actions: <Widget>[
          _routeButton('Sports', 'sports'),
          _routeButton('Transportation', 'transportation'),
          _routeButton('Places', 'places'),
          Container(
            width: debugShowCheckedModeBanner ? 50 : 0,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          _initErrorHandler(context);
          return GgRouter(
            {
              '_INDEX_': _indexPage,
              'sports': _sportsPage,
              'transportation': _transportationPage,
              'places': _placesPage,
              '*': _wildCardPage,
            },
            key: ValueKey('mainRouter'),
            inAnimation: _zoomIn,
            outAnimation: _zoomOut,
            semanticLabels: {
              '_INDEX_': 'Navigate to Index Page',
              'sports': 'Navigate to Sports Page',
              'transportation': 'Navigate to Transportation Page',
              'places': 'Navigate to Places Page',
              '*': 'Another Page',
            },
          );
        },
      ),
    );
  }

  // ...........................................................................
  _initErrorHandler(BuildContext context) {
    final node = GgRouter.of(context).node;
    node.errorHandler = null;
    node.errorHandler = (error) {
      final snackBar = SnackBar(
        content: Text(error.message),
        duration: Duration(seconds: 6),
        backgroundColor: Colors.red,
      );

      scheduleMicrotask(
          () => ScaffoldMessenger.of(context).showSnackBar(snackBar));
    };
  }

  // ...........................................................................
  Widget _text(String text, BuildContext context, bool isStaged) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final onPrimaryInactive = onPrimary.withAlpha(120);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Text(
        text,
        style: TextStyle(color: isStaged ? onPrimary : onPrimaryInactive),
      ),
    );
  }

  // ...........................................................................
  Widget _bigIcon(BuildContext context, IconData icon) {
    return Center(
      child: Icon(
        icon,
        size: 200,
        color: Color(0x33FFFFFF),
      ),
    );
  }

  // ...........................................................................
  Widget _routeButton(String title, String route) {
    return Builder(builder: (context) {
      final router = GgRouter.of(context);

      return StreamBuilder(
        stream: router.onActiveChildChange,
        builder: (context, snapshot) {
          final isStaged = router.routeNameOfActiveChild == route;
          final path = '$route/_LAST_';
          final semanticLabel = router.semanticLabelForPath(route);

          return Semantics(
            excludeSemantics: true,
            label: semanticLabel,
            child: TextButton(
              key: ValueKey(route),
              onPressed: () => router.navigateTo(path),
              child: _text(title, context, isStaged),
            ),
          );
        },
      );
    });
  }

  // ...........................................................................
  Widget _dialogContent(BuildContext context) {
    return GgNavigationPageRoot(
      // Customize animation
      inAnimation: _navigateIn(context),
      outAnimation: _navigateOut(context),

      // Customize navigation bar style
      navigationBarBackgroundColor: null,
      navigationBarPadding: 10,

      // Customize back button
      navigationBarBackButton: (_) => Icon(
        Icons.arrow_back_ios_new,
        size: 18.0,
      ),

      // Customize close button
      navigationBarCloseButton: (_) => Icon(
        Icons.close,
        size: 18.0,
      ),

      child: MyNavigationPage(),
    );
  }

  // ...........................................................................
  Widget _dialog(BuildContext context) {
    return Dialog(
      child: _dialogContent(context),
    );
  }

  // ...........................................................................
  Widget _indexPage(BuildContext context) {
    return Center(
      key: ValueKey('indexPage'),
      child: Text(
        'GgRouter',
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }

  // ...........................................................................
  Widget _wildCardPage(BuildContext context) {
    final routeName = GgRouter.of(context).routeName;

    return Center(
      key: ValueKey('wildCardPage'),
      child: Text(
        'Wildcard: $routeName',
        key: ValueKey('WildCardText: $routeName'),
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }

  // ...........................................................................
  Widget _sportsPage(BuildContext context) {
    final router = GgRouter.of(context);

    return Scaffold(
      key: ValueKey('sportsPage'),
      bottomNavigationBar: StreamBuilder(
          stream: router.onActiveChildChange,
          builder: (context, snapshot) {
            final index = router.indexOfActiveChild ?? 0;

            return BottomNavigationBar(
              currentIndex: index,
              items: [
                BottomNavigationBarItem(
                  label: 'Basketball',
                  icon: Icon(Icons.sports_basketball),
                ),
                BottomNavigationBarItem(
                  label: 'Football',
                  icon: Icon(Icons.sports_football),
                ),
                BottomNavigationBarItem(
                  label: 'Handball',
                  icon: Icon(Icons.sports_handball),
                ),
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    router.navigateTo('basketball/_LAST_');
                    break;
                  case 1:
                    router.navigateTo('football/_LAST_');
                    break;
                  case 2:
                    router.navigateTo('handball/_LAST_');
                    break;
                }
              },
            );
          }),
      body: GgRouter(
        {
          'basketball': (context) {
            return GgRouteParams(
              params: {
                'visit': GgRouteParam<bool>(seed: false),
              },
              child: GgPopoverRoute(
                key: ValueKey('dialog'),
                name: 'popover',
                semanticLabel: 'Popover Dialog Example',
                base: Listener(
                  child: _bigIcon(context, Icons.sports_basketball),
                  onPointerUp: (_) =>
                      GgRouter.of(context).navigateTo('./popover'),
                ),
                popover: _dialog,
                inAnimation: _rotateIn,
                outAnimation: _rotateOut,
              ),
            );
          },
          'football': (c) => _bigIcon(c, Icons.sports_football),
          'handball': (c) => _bigIcon(c, Icons.sports_handball),
        },
        key: ValueKey('sportsRouter'),
        defaultRoute: 'basketball',
        inAnimation: _moveIn,
        outAnimation: _moveOut,
      ),
    );
  }

  // ...........................................................................
  Widget _transportationPage(BuildContext context) {
    final router = GgRouter.of(context);

    return Scaffold(
      key: ValueKey('transportationPage'),
      bottomNavigationBar: StreamBuilder(
          stream: router.onActiveChildChange,
          builder: (context, snapshot) {
            final index = router.indexOfActiveChild ?? 0;

            return BottomNavigationBar(
              currentIndex: index,
              items: [
                BottomNavigationBarItem(
                  label: 'Bus',
                  icon: Icon(Icons.directions_bus),
                ),
                BottomNavigationBarItem(
                  label: 'Bike',
                  icon: Icon(Icons.directions_bike),
                ),
                BottomNavigationBarItem(
                  label: 'Car',
                  icon: Icon(Icons.directions_car),
                ),
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    router.navigateTo('bus');
                    break;
                  case 1:
                    router.navigateTo('bike');
                    break;
                  case 2:
                    router.navigateTo('car');
                    break;
                }
              },
            );
          }),
      body: GgRouter(
        {
          'bus': (c) => _bigIcon(c, Icons.directions_bus),
          'bike': (c) => _bigIcon(c, Icons.directions_bike),
          'car': (c) => _bigIcon(c, Icons.directions_car),
        },
        key: ValueKey('/transportation'),
        defaultRoute: 'bus',
        inAnimation: _moveIn,
        outAnimation: _moveOut,
      ),
    );
  }

// ...........................................................................
  Widget _placesPage(BuildContext context) {
    final router = GgRouter.of(context);
    // return Container(color: Colors.green);

    return Scaffold(
      bottomNavigationBar: StreamBuilder(
          key: ValueKey('placesPage'),
          stream: router.onActiveChildChange,
          builder: (context, snapshot) {
            final index = router.indexOfActiveChild ?? 0;

            return BottomNavigationBar(
              currentIndex: index,
              items: [
                BottomNavigationBarItem(
                  label: 'Airpot',
                  icon: Icon(Icons.airplanemode_active),
                ),
                BottomNavigationBarItem(
                  label: 'Park',
                  icon: Icon(Icons.park),
                ),
                BottomNavigationBarItem(
                  label: 'Hospital',
                  icon: Icon(Icons.local_hospital),
                ),
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    router.navigateTo('airport');
                    break;
                  case 1:
                    router.navigateTo('park');
                    break;
                  case 2:
                    router.navigateTo('hospital');
                    break;
                }
              },
            );
          }),
      body: GgRouter(
        {
          'airport': (c) => _bigIcon(c, Icons.airplanemode_active),
          'park': (c) => _bigIcon(c, Icons.park),
          'hospital': (c) => _bigIcon(c, Icons.local_hospital),
        },
        key: ValueKey('/places'),
        defaultRoute: 'airport',
        inAnimation: _moveIn,
        outAnimation: _moveOut,
      ),
    );
  }

  // ...........................................................................
  _saveState(String state) async {
    (await (SharedPreferences.getInstance()))
        .setString('lastApplicationState', state);
  }

  // ...........................................................................
  Future<String?> _restoreState() async {
    final result = (await (SharedPreferences.getInstance()))
        .getString('lastApplicationState');
    return result;
  }

  // ...........................................................................
  Widget _zoomOut(
    BuildContext context,
    Animation animation,
    Widget child,
    Size size,
  ) {
    // print(GgRouter.of(context).nameOfChildAnimatingIn);
    // print(GgRouter.of(context).nameOfChildAnimatingOut);

    // In the first part of the animation the old widget is faded out
    final scale = animation.value < 0.5
        ? Curves.easeInOut.transform(1.0 - (animation.value * 2.0))
        : 0.0;

    return Transform.scale(
      scale: scale,
      child: child,
    );
  }

  // ...........................................................................
  Widget _zoomIn(
    BuildContext context,
    Animation animation,
    Widget child,
    Size size,
  ) {
    // In the second part of the animation the new widget is faded in
    final scale = animation.value >= 0.5
        ? Curves.easeInOut.transform(((animation.value - 0.5) * 2.0))
        : 0.0;

    return Transform.scale(
      scale: scale,
      child: child,
    );
  }

  // ...........................................................................
  Widget _moveIn(
    BuildContext context,
    Animation animation,
    Widget child,
    Size size,
  ) {
    final w = size.width;
    final h = size.height;
    final index = GgRouter.of(context).indexOfChildAnimatingIn;

    final fromLeft = Offset(-w * (1.0 - animation.value), 0);
    final fromBottom = Offset(0, h * (1.0 - animation.value));
    final fromRight = Offset(w * (1.0 - animation.value), 0);

    Offset offset = index == 0
        ? fromLeft
        : index == 1
            ? fromBottom
            : fromRight;

    return Transform.translate(
      offset: offset,
      child: child,
    );
  }

  // ...........................................................................
  Widget _moveOut(
    BuildContext context,
    Animation animation,
    Widget child,
    Size size,
  ) {
    final w = size.width;
    final h = size.height;
    final index = GgRouter.of(context).indexOfChildAnimatingOut;

    final toRight = Offset(w * (animation.value), 0);
    final toBottom = Offset(0, h * (animation.value));
    final toLeft = Offset(w * (-animation.value), 0);

    Offset offset = index == 0
        ? toLeft
        : index == 1
            ? toBottom
            : toRight;

    return Transform.translate(
      offset: offset,
      child: child,
    );
  }

  // ...........................................................................
  Widget _rotateIn(
    BuildContext context,
    Animation animation,
    Widget child,
    Size size,
  ) {
    // print(GgRouter.of(context).nameOfChildAnimatingIn);
    // print(GgRouter.of(context).nameOfChildAnimatingOut);
    final scale = animation.value;
    final angle = 2 * pi * animation.value;
    final fade = animation.value;

    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: angle,
        child: Opacity(
          opacity: fade,
          child: child,
        ),
      ),
    );
  }

  // ...........................................................................
  Widget _rotateOut(
    BuildContext context,
    Animation animation,
    Widget child,
    Size size,
  ) {
    final scale = 1.0 - animation.value;
    final angle = -2 * pi * animation.value;
    final fade = 1.0 - animation.value;

    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: angle,
        child: Opacity(
          opacity: fade,
          child: child,
        ),
      ),
    );
  }

  // ...........................................................................
  Widget _moveInFromRight(Animation animation, Widget child, double width) {
    return Transform.translate(
        offset: Offset(
            (1.0 - Curves.easeInOut.transform(animation.value)) * width, 0),
        child: child);
  }

  // ...........................................................................
  Widget _moveOutToRight(Animation animation, Widget child, double width) {
    return Transform.translate(
      offset: Offset(Curves.easeInOut.transform(animation.value) * width, 0),
      child: child,
    );
  }

  // ...........................................................................
  GgAnimationBuilder _navigateIn(BuildContext context) {
    return (BuildContext context, Animation animation, Widget child,
        Size size) {
      final currentRoute = GgRouter.of(context).nameOfChildAnimatingIn;

      return currentRoute != '_INDEX_'
          ? GgShowInForeground(
              child: _moveInFromRight(animation, child, size.width))
          : child;
    };
  }

  // ...........................................................................
  GgAnimationBuilder _navigateOut(BuildContext context) {
    return (BuildContext context, Animation animation, Widget child,
        Size size) {
      final currentRoute = GgRouter.of(context).nameOfChildAnimatingOut;

      return currentRoute != '_INDEX_'
          ? GgShowInForeground(
              child: _moveOutToRight(animation, child, size.width))
          : child;
    };
  }
}
