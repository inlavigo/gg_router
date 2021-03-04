// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';

import 'gg_route_tree_node.dart';
import 'gg_router_widget.dart';

// #############################################################################
class GgRouter {
  // ...........................................................................
  static GgRouter of(BuildContext context) {
    return GgRouter(context: context);
  }

  // ...........................................................................
  GgRouter({required BuildContext context}) {
    _node = GgRouterWidget.node(context: context);
  }

  // ...........................................................................
  GgRouteTreeNode get node => _node;

  // ...........................................................................
  void navigateTo(String path) {
    node.navigateTo(path);
  }

  // ...........................................................................
  String? get routeName {
    return node.name;
  }

  // ...........................................................................
  String? get routeNameOfActiveChild {
    return node.activeChild?.name;
  }

  // ...........................................................................
  int? get indexOfActiveChild {
    return node.activeChild?.index;
  }

  // ...........................................................................
  String get routePath {
    return node.pathString;
  }

  // ...........................................................................
  Stream<void> get onActiveChildChange {
    return node.activeChildDidChange;
  }

  // ######################
  // Private
  // ######################
  late GgRouteTreeNode _node;
}
