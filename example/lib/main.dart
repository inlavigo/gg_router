// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';

void main() {
  configureApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: GgRouterDelegate(
        child: Scaffold(
          body: GgRouterExample(),
        ),
      ),
      routeInformationParser: GgRouteInformationParser(),
    );
  }
}

// .............................................................................
class GgRouterExample extends StatelessWidget {
  const GgRouterExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GgRouterExample",
      home: Scaffold(
        appBar: AppBar(
          title: Text('GgRouter'),
          actions: <Widget>[
            _routeButton('Sports', 'sports'),
            _routeButton('Transportation', 'transportation'),
            _routeButton('Places', 'places'),
            Container(
              width: 50,
            ),
          ],
        ),
        body: Builder(
          builder: (context) {
            _initErrorHandler(context);
            return GgRouterWidget(
              {
                'sports': _sportsPage,
                'transportation': _transportationPage,
                'places': _placesPage,
              },
            );
          },
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    };
  }

  // ...........................................................................
  Widget _text(String text, BuildContext context, bool isActive) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final onPrimaryInactive = onPrimary.withAlpha(120);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Text(
        text,
        style: TextStyle(color: isActive ? onPrimary : onPrimaryInactive),
      ),
    );
  }

  // ...........................................................................
  Widget _bigIcon(BuildContext context, IconData icon) {
    return Center(
      child: Icon(
        icon,
        size: 200,
        color: Colors.grey.shade400,
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
          final isActive = router.routeNameOfActiveChild == route;
          return TextButton(
            onPressed: () => router.navigateTo('$route/_LAST_'),
            child: _text(title, context, isActive),
          );
        },
      );
    });
  }

  // ...........................................................................
  Widget _dialog(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                GgRouter.of(context).navigateTo('..');
              },
            ),
          ),
          Center(
            child: Text('Let\'s play basketball.'),
          ),
        ],
      ),
    );
  }

  // ...........................................................................
  Widget _sportsPage(BuildContext context) {
    final router = GgRouter.of(context);
    return Scaffold(
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
      body: GgRouterWidget(
        {
          'basketball': (context) {
            return GgRouteParamsWidget(
              prefix: 'bktbl',
              params: {
                'players': GgRouteParam(seed: 5),
                'temperature': GgRouteParam(seed: 21.5),
                'funny': GgRouteParam(seed: true),
              },
              builder: (context) {
                return GgRouterOverlayWidget(
                  base: Listener(
                    child: _bigIcon(context, Icons.sports_basketball),
                    onPointerUp: (_) =>
                        GgRouter.of(context).navigateTo('dialog'),
                  ),
                  overlays: {
                    'dialog': _dialog,
                  },
                );
              },
            );
          },
          'football': (c) => _bigIcon(c, Icons.sports_football),
          'handball': (c) => _bigIcon(c, Icons.sports_handball),
        },
      ),
    );
  }

  // ...........................................................................
  Widget _transportationPage(BuildContext context) {
    final router = GgRouter.of(context);
    return Scaffold(
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
      body: GgRouterWidget(
        {
          'bus': (c) => _bigIcon(c, Icons.directions_bus),
          'bike': (c) => _bigIcon(c, Icons.directions_bike),
          'car': (c) => _bigIcon(c, Icons.directions_car),
        },
      ),
    );
  }

// ...........................................................................
  Widget _placesPage(BuildContext context) {
    final router = GgRouter.of(context);
    return Scaffold(
      bottomNavigationBar: StreamBuilder(
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
      body: GgRouterWidget(
        {
          'airport': (c) => _bigIcon(c, Icons.airplanemode_active),
          'park': (c) => _bigIcon(c, Icons.park),
          'hospital': (c) => _bigIcon(c, Icons.local_hospital),
        },
      ),
    );
  }
}
