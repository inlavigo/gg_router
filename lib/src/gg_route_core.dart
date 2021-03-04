// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'gg_route_tree_node.dart';

class GgRouterCore extends InheritedWidget {
  // ...........................................................................
  GgRouterCore({
    required Widget child,
    required this.node,
  }) : super(
          key: ValueKey(node.pathHashCode),
          child: child,
        );

  final GgRouteTreeNode node;

  // ...........................................................................
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  // ...........................................................................
  static GgRouterCore? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GgRouterCore>();
  }
}
