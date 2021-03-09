// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gg_router/src/gg_router.dart';

import 'gg_route_tree_node.dart';

class GgRouterDelegate extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  // ...........................................................................
  GgRouterDelegate({required this.child})
      : navigatorKey = GlobalKey<NavigatorState>() {
    _listenToRouteChanges();
    _listenToParameterChanges();
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
    return GgRouter(
      child: Overlay(
        initialEntries: [
          OverlayEntry(builder: (context) {
            return child;
          }),
        ],
      ),
      node: _root,
    );
  }

  // ...........................................................................
  @override
  RouteInformation get currentConfiguration {
    Map<String, dynamic> queryParameters = {};
    _root.activeParams.values.forEach((param) {
      queryParameters[param.name] = param.value.toString();
    });

    final uri = Uri(
      pathSegments: _root.activeChildPath,
      queryParameters: queryParameters.length > 0 ? queryParameters : null,
    );

    return RouteInformation(
      location: uri.toString(),
    );
  }

  // ...........................................................................
  @override
  Future<void> setInitialRoutePath(RouteInformation configuration) {
    return super.setInitialRoutePath(configuration);
  }

  // ...........................................................................
  @override
  Future<void> setNewRoutePath(RouteInformation route) {
    try {
      if (route.location != null) {
        late Uri uri;
        try {
          uri = Uri.parse(route.location!);
        } catch (e) {
          print('Error while parsing url ${route.location}');
          return SynchronousFuture(null);
        }

        _root.activeChildPath = uri.pathSegments;
        final Map<String, String> earlySeed = {};

        if (uri.hasQuery) {
          final activeParams = _root.activeParams;
          uri.queryParameters.forEach((key, value) {
            if (activeParams.containsKey(key)) {
              activeParams[key]!.stringValue = value;
            } else {
              earlySeed[key] = value;
            }
          });
        }

        _root.earlySeed = earlySeed;
      }
    } catch (e) {
      print('Error while setNewRoutePath url ${route.location}');
    }

    return SynchronousFuture(null);
  }

  // ######################
  // Private
  // ######################

  // ...........................................................................
  final List<Function()> _dispose = [];
  final _root = GgRouteTreeNode(name: '');

  // ...........................................................................
  _listenToRouteChanges() {
    final s = _root.activeDescendandsDidChange.listen((event) {
      notifyListeners();
    });

    _dispose.add(s.cancel);
  }

  // ...........................................................................
  _listenToParameterChanges() {
    final s = _root.onOwnOrChildParamChange.listen((event) {
      notifyListeners();
    });
    _dispose.add(s.cancel);
  }
}
