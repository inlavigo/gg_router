// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:gg_router/src/gg_route_core.dart';

import './gg_route_node.dart';

class GgRouterDelegate extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  // ...........................................................................
  GgRouterDelegate({required this.child})
      : navigatorKey = GlobalKey<NavigatorState>() {
    _listenToRouteChanges();
  }

// ...........................................................................
  @override
  void dispose() {
    _dispose.reversed.forEach((element) => element());
    super.dispose();
  }

  // ...........................................................................
  final GlobalKey<NavigatorState> navigatorKey;
  Widget child;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return GgRouterCore(child: child, node: _root);
  }

  // ...........................................................................
  @override
  RouteInformation get currentConfiguration {
    return RouteInformation(location: _root.activeChildPath.join('/'));
  }

  // ...........................................................................
  @override
  Future<void> setNewRoutePath(RouteInformation route) async {
    if (route.location != null) {
      _root.activeChildPath = route.location!.split('/');
    }
  }

  // ######################
  // Private
  // ######################

  // ...........................................................................
  final List<Function()> _dispose = [];
  final _root = GgRouterNode(name: '');

  // ...........................................................................
  _listenToRouteChanges() {
    _root.activeDescendandsDidChange.listen((event) {
      notifyListeners();
    });
  }
}
