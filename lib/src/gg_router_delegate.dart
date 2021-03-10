// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';

import 'gg_route_tree_node.dart';

/// This [RouterDelegate] applies changes of the route tree to the application's
/// URI and applies the application's URI to the route tree. Assign an instance
/// of this delegate to a [Router]'s or [MaterialApp]'s routerDelegate.
///
/// ```
/// MaterialApp.router(
///   title: "GgRouterExample",
///   routerDelegate: GgRouterDelegate(child: ...),
///   routeInformationParser: GgRouteInformationParser(),
/// );
/// ```
class GgRouterDelegate extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  // ...........................................................................
  /// The constructor. Takes a child widget to be rendered.
  GgRouterDelegate({required this.child})
      : navigatorKey = GlobalKey<NavigatorState>() {
    _listenToRouteChanges();
    _listenToParameterChanges();
  }

// ...........................................................................
  /// Call this function if the delegate is not needed anymore.
  @override
  void dispose() {
    _dispose.reversed.forEach((element) => element());
    super.dispose();
  }

  // ...........................................................................
  /// The navigator key needed by [PopNavigatorRouterDelegateMixin].
  final GlobalKey<NavigatorState> navigatorKey;
  Widget child;

  // ...........................................................................
  /// Builds the widget tree.
  @override
  Widget build(BuildContext context) {
    return GgRouter.root(
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
      queryParameters[param.name!] = param.value.toString();
    });

    final uri = Uri(
      pathSegments: _root.activeChildPathSegments,
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
    if (route.location != null) {
      late Uri uri;
      try {
        uri = Uri.parse(route.location!);
      } catch (e) {
        print('Error while parsing url ${route.location}');
        return SynchronousFuture(null);
      }

      _root.activeChildPathSegments = uri.pathSegments;
      final Map<String, String> uriParams = {};

      if (uri.hasQuery) {
        final activeParams = _root.activeParams;
        uri.queryParameters.forEach((key, value) {
          if (activeParams.containsKey(key)) {
            activeParams[key]!.stringValue = value;
          } else {
            uriParams[key] = value;
          }
        });
      }

      _root.uriParams = uriParams;
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
    final s = _root.activeDescendantsDidChange.listen((event) {
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
