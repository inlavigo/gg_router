// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';
import 'gg_router.dart';
import 'gg_route_tree_node.dart';

// #############################################################################
class GgRouterWidget extends StatelessWidget {
  const GgRouterWidget(this.children) : super();

  // ...........................................................................
  final Map<String, Widget Function(BuildContext)> children;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    // Get parent node
    final parentNode = node(context: context);

    _createChildNodes(parentNode);

    assert(children.length > 0);

    // Create a stream builder rebuilding the tree on active child change.
    final result = StreamBuilder<GgRouteTreeNode?>(
      stream: parentNode.activeChildDidChange,
      builder: (context, snapShot) {
        GgRouteTreeNode? nodeToBeShown = parentNode.activeChild;

        // ...............................................
        // Use previous route, if current route is invalid
        bool routeIsValid =
            nodeToBeShown == null || children.keys.contains(nodeToBeShown.name);

        if (!routeIsValid) {
          final invalidNode = nodeToBeShown;
          nodeToBeShown = parentNode.previousActiveChild;
          nodeToBeShown?.isActive = true;
          parentNode.removeChild(invalidNode);
          parentNode.setError(
            GgRouterError(
              id: 'GRC008448',
              message:
                  'Route "${parentNode.pathString}" has no child named "${invalidNode.name}".',
            ),
          );
        }

        // ..............................................
        // If parentNode has no activeChild, look, if a child widget with
        // key "" is defined. If such a child widget is available,
        // return that child widget directly. This widget will be assigned
        // to the parent route, therefor no other node needs to be
        // activated.
        if (nodeToBeShown == null && children.keys.contains("")) {
          final defaultWidget = children[""]!;
          return defaultWidget(context);
        }

        // ..............................................
        // If no active child is defined and no default route is defined,
        // take the first possible child.
        if (nodeToBeShown == null) {
          nodeToBeShown = parentNode.child(name: children.keys.first);
        }

        // .............................
        // Activate the node to be shown
        nodeToBeShown.isActive = true;

        // .....................................
        // Show the widget belonging to the node
        final widgetToBeShown = children[nodeToBeShown.name]!;

        return GgRouter(
          child: Builder(builder: (c) => widgetToBeShown(c)),
          node: nodeToBeShown,
        );
      },
    );

    return result;
  }

  // ...........................................................................
  _createChildNodes(GgRouteTreeNode parentNode) {
    children.keys.forEach((routeName) {
      parentNode.child(name: routeName);
    });
  }

  // ...........................................................................
  static GgRouteTreeNode node({
    required BuildContext context,
  }) {
    final result = GgRouter.of(context).node;
    return result;
  }
}
