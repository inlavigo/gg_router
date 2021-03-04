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

  final _routerDelegate = GgRouterDelegate(
      child: Scaffold(
    body: GgRouterExample(),
  ));
  final _routeInformationParser = GgRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
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
        body: GgRouter(
          {
            'sports': _sportsPage,
            'transportation': _transportationPage,
            'places': _placesPage,
          },
        ),
      ),
    );
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
  Builder _bigIcon(IconData icon) {
    return Builder(
      builder: (context) {
        return Center(
          child: Icon(
            icon,
            size: 200,
            color: Colors.grey.shade400,
          ),
        );
      },
    );
  }

  // ...........................................................................
  Widget _routeButton(String title, String route) {
    return Builder(builder: (context) {
      final router = context.router;

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
  Builder get _dialog {
    return Builder(
      builder: (context) {
        return Dialog(
            child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  context.router.navigateTo('..');
                },
              ),
            ),
            Center(
              child: Text('Let\'s play basketball.'),
            ),
          ],
        ));
      },
    );
  }

  // ...........................................................................
  Builder get _sportsPage {
    return Builder(
      builder: (context) {
        final router = context.router;
        return Scaffold(
          bottomNavigationBar: StreamBuilder(
              stream: router.onActiveChildChange,
              builder: (context, snapshot) {
                final activeChildRouteSegment =
                    router.routeNameOfActiveChild ?? 'basketball';

                final index = ['basketball', 'football', 'handball']
                    .indexOf(activeChildRouteSegment);

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
              'basketball': Builder(
                builder: (context) {
                  return GgOverlayRouter(
                    base: Listener(
                      child: _bigIcon(Icons.sports_basketball),
                      onPointerUp: (_) => context.router.navigateTo('dialog'),
                    ),
                    overlays: {
                      'dialog': _dialog,
                    },
                  );
                },
              ),
              'football': _bigIcon(Icons.sports_football),
              'handball': _bigIcon(Icons.sports_handball),
            },
          ),
        );
      },
    );
  }

  // ...........................................................................
  Builder get _transportationPage {
    return Builder(
      builder: (context) {
        final router = context.router;
        return Scaffold(
          bottomNavigationBar: StreamBuilder(
              stream: router.onActiveChildChange,
              builder: (context, snapshot) {
                final activeChildRouteSegment =
                    router.routeNameOfActiveChild ?? 'bus';

                final index =
                    ['bus', 'bike', 'car'].indexOf(activeChildRouteSegment);

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
              'bus': _bigIcon(Icons.directions_bus),
              'bike': _bigIcon(Icons.directions_bike),
              'car': _bigIcon(Icons.directions_car),
            },
          ),
        );
      },
    );
  }

// ...........................................................................
  Builder get _placesPage {
    return Builder(
      builder: (context) {
        final router = context.router;
        return Scaffold(
          bottomNavigationBar: StreamBuilder(
              stream: router.onActiveChildChange,
              builder: (context, snapshot) {
                final activeChildRouteSegment =
                    router.routeNameOfActiveChild ?? 'airport';

                final index = ['airport', 'park', 'hospital']
                    .indexOf(activeChildRouteSegment);

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
              'airport': _bigIcon(Icons.airplanemode_active),
              'park': _bigIcon(Icons.park),
              'hospital': _bigIcon(Icons.local_hospital),
            },
          ),
        );
      },
    );
  }
}
