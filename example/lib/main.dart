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
    final router = context.router;
    return MaterialApp(
      title: "GgRouterExample",
      home: Scaffold(
        appBar: AppBar(
          title: Text('GgRouter'),
          actions: <Widget>[
            TextButton(
              onPressed: () => router.navigateTo('sports'),
              child: _text('Sports', context),
            ),
            TextButton(
              onPressed: () => router.navigateTo('transportation'),
              child: _text('Transportation', context),
            ),
            TextButton(
              onPressed: () => router.navigateTo('places'),
              child: _text('Places', context),
            ),
            Container(
              width: 50,
            ),
          ],
        ),
        body: GgRouter(
          {
            'sports': Builder(
              builder: (context) {
                final router = context.router;
                return Scaffold(
                  bottomNavigationBar: StreamBuilder(
                      stream: router.onActiveChildChange,
                      builder: (context, snapshot) {
                        final activeChildRouteSegment =
                            router.activeChildRouteSegment ?? 'basketball';

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
                                router.navigateTo('basketball');
                                break;
                              case 1:
                                router.navigateTo('football');
                                break;
                              case 2:
                                router.navigateTo('handball');
                                break;
                            }
                          },
                        );
                      }),
                  body: GgRouter(
                    {
                      'basketball': _bigIcon(Icons.sports_basketball),
                      'football': _bigIcon(Icons.sports_football),
                      'handball': _bigIcon(Icons.sports_handball),
                    },
                  ),
                );
              },
            ),
            'transportation': Builder(builder: (context) {
              return Scaffold(
                bottomNavigationBar: BottomNavigationBar(
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
                ),
              );
            }),
            'places': Builder(builder: (context) {
              return Scaffold(
                bottomNavigationBar: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      label: 'Airport',
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
                ),
              );
            }),
          },
        ),
      ),
    );

    /* Column(
      children: [
        // ......................................
        // Define /yellow, /green, /red
        GgRouter({
          '': _box(Colors.black),
          'yellow': _box(Colors.yellow),
          'green': _box(Colors.green),
          'red': _box(Colors.red,
              child: Column(
                // ..................................................
                // Define /red, /red/hello, /red/world
                children: [
                  GgRouter({
                    '': _text(''),
                    'hello': _text('hello'),
                    'world': _text('world'),
                  }),

                  // ...................................
                  // Define buttons to switch sub routes
                  Container(
                    color: Color(0xDDFFFFFF),
                    child: Row(
                      children: [
                        _naviButton('./hello', './hello'),
                        _naviButton('./world', './world'),
                        _naviButton('../yellow', '../yellow'),
                        _naviButton('/green', '/green'),
                      ],
                    ),
                  )
                ],
              )),
        }),

        // ...................
        // Define buttons to switch routes main routes
        Row(
          children: [
            _naviButton('Green', '/green'),
            _naviButton('Yellow', '/yellow'),
            _naviButton('Red', '/red'),
          ],
        ),
      ],

    );*/
  }

  // ...........................................................................
  Widget _text(String text, BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Text(
        text,
        style: TextStyle(color: onPrimary),
      ),
    );
  }

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
}
