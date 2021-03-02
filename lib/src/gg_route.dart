// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'package:flutter/material.dart';
import './gg_route_core.dart';
import './gg_route_node.dart';

// #############################################################################
class GgRoute extends StatelessWidget {
  const GgRoute(this.children) : super();

  // ...........................................................................
  final Map<String, Widget> children;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    // Get parent node
    final parentNode = parent(context: context);

    assert(children.length > 0);

    // If no child is active currently, activate default child
    if (parentNode.activeChild == null) {
      parentNode.child(name: children.keys.first).isActive = true;
    }

    // Create a stream builder rebuilding the tree on active child change.
    final result = StreamBuilder<GgRouteNode?>(
      stream: parentNode.activeChildDidChange,
      builder: (context, snapShot) {
        final activeChildNode = parentNode.activeChild;

        // If no active child is available, return an empty container.
        if (activeChildNode == null) {
          return Container();
        }
        // Otherwise create a GgRouteCore for the active child and return it.
        else {
          final activeChildWidget =
              children[activeChildNode.name] ?? Text('Error 404 Not Found');

          final routeCore =
              GgRouteCore(child: activeChildWidget, node: activeChildNode);

          return routeCore;
        }
      },
    );

    return result;
  }

  // ...........................................................................
  static GgRouteNode parent({
    required BuildContext context,
  }) {
    final parent = GgRouteCore.of(context)?.node;

    if (parent == null) {
      throw ArgumentError('Did not find an instance of GgRouterDelegate.\n'
          'Please wrap your GgRoute into a MaterialApp.router(...) and '
          'assign an instance of GgRouterDelegate to "routerDelegate".\n'
          'For more details look into "gg_router/example/main.dart".');
    }

    return parent;
  }
}

// #############################################################################
extension GgContextRouteExtension on BuildContext {
  void selectRoute(String relativePath) {
    final segments = relativePath.split('/');

    final parent = GgRoute.parent(context: this);
    parent.activeChildPath = segments;
  }
}
