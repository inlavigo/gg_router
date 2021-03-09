// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_value/gg_value.dart';

import 'gg_route_tree_node.dart';

// #############################################################################
class GgRouter extends InheritedWidget {
  // ...........................................................................
  GgRouter({
    required Widget child,
    required GgRouteTreeNode node,
  })   : _node = node,
        super(
          key: ValueKey(node.pathHashCode),
          child: child,
        );

  // ...........................................................................
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  // ...........................................................................
  static GgRouter of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<GgRouter>();
    if (result != null) {
      return result;
    } else {
      throw Exception(
        'Did not find an instance of GgRouterDelegate.\n'
        'Please wrap your GgRouter into a MaterialApp.router(...) and '
        'assign an instance of GgRouterDelegate to "routerDelegate".\n'
        'For more details look into "gg_router/example/main.dart".',
      );
    }
  }

  // ...........................................................................
  GgRouteTreeNode get node => _node;

  // ...........................................................................
  void navigateTo(String path) {
    _node.navigateTo(path);
  }

  // ...........................................................................
  String? get routeName {
    return _node.name;
  }

  // ...........................................................................
  String? get routeNameOfActiveChild {
    return _node.activeChild?.name;
  }

  // ...........................................................................
  int? get indexOfActiveChild {
    return _node.activeChild?.index;
  }

  // ...........................................................................
  String get routePath {
    return _node.pathString;
  }

  // ...........................................................................
  Stream<void> get onActiveChildChange {
    return _node.activeChildDidChange;
  }

  // ...........................................................................
  GgValue? param(String name) => node.param(name);

  // ...........................................................................
  GgValue? ownOrParentParam(String name) => node.ownOrParentParam(name);

  // ######################
  // Private
  // ######################
  final GgRouteTreeNode _node;
}
