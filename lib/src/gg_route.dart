// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'package:flutter/material.dart';
import 'package:gg_route/gg_route.dart';

// #############################################################################
class GgRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async {
    if (routeInformation.location == null) {
      return Uri();
    }
    final uri = Uri.parse(routeInformation.location!);
    return uri;
  }

  @override
  RouteInformation restoreRouteInformation(Uri configuration) {
    return RouteInformation(location: '/a/b');
  }
}

// #############################################################################
class GgRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  // ...........................................................................
  GgRouterDelegate({required this.child})
      : navigatorKey = GlobalKey<NavigatorState>();

  // ...........................................................................
  final GlobalKey<NavigatorState> navigatorKey;
  Widget child;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return child;
  }

  // ...........................................................................
  @override
  Uri get currentConfiguration {
    print('currentConfiguration');
    return Uri();
  }

  // ...........................................................................
  @override
  Future<void> setNewRoutePath(Uri path) async {
    print('setNewRoutePath $path');
  }
}

// #############################################################################
class GgRouteCore extends InheritedWidget {
  // ...........................................................................
  GgRouteCore({
    Key? key,
    required this.name,
    required Widget child,
    required this.node,
  }) : super(key: key, child: child);

  // final Widget child;
  final String name;

  final GgRouteNode node;

  // ...........................................................................
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  // ...........................................................................
  static GgRouteCore? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GgRouteCore>();
  }
}

// #############################################################################

class GgRoute extends StatefulWidget {
  GgRoute({Key? key, required this.child, required this.name})
      : super(key: key);

  final Widget child;
  final String name;

  @override
  _GgRouteState createState() => _GgRouteState();
}

// #############################################################################
class _GgRouteState extends State<GgRoute> {
  GgRouteNode? node;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    // Get parent lite route

    _initNode(context);

    final core = GgRouteCore(
      name: widget.name,
      child: widget.child,
      node: node!,
    );

    return core;
  }

  // ...........................................................................
  bool get isRoot => node!.parent == null;

  // ...........................................................................
  _initNode(BuildContext context) {
    if (node == null) {
      final existingParentNode = GgRouteCore.of(context)?.node;

      final parentNode = existingParentNode ?? GgRouteNode(name: '_root');

      node = parentNode.child(name: widget.name);
    }
  }
}
