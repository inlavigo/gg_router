// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'package:flutter/material.dart';
import 'gg_route_core.dart';
import 'gg_route_node.dart';

// #############################################################################
class GgRouter extends StatelessWidget {
  const GgRouter(this.children) : super();

  // ...........................................................................
  final Map<String, Builder> children;

  static final errorWidgetKey = GlobalKey();

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    // Get parent node
    final parentNode = node(context: context);

    _createChildNodes(parentNode);

    assert(children.length > 0);

    // Create a stream builder rebuilding the tree on active child change.
    final result = StreamBuilder<GgRouterNode?>(
      stream: parentNode.activeChildDidChange,
      builder: (context, snapShot) {
        GgRouterNode? nodeToBeShown = parentNode.activeChild;

        // ...............................................
        // Use previous route, if current route is invalid
        bool routeIsValid =
            nodeToBeShown == null || children.keys.contains(nodeToBeShown.name);

        if (!routeIsValid) {
          final invalidNode = nodeToBeShown;
          nodeToBeShown = parentNode.previousActiveChild;
          nodeToBeShown?.isActive = true;
          parentNode.removeChild(invalidNode);
          // Todo: Add error handling here
        }

        // ..............................................
        // If parentNode has no activeChild, look, if a child widget with
        // key "" is defined. If such a child widget is available,
        // return that child widget directly. This widget will be assigned
        // to the parent route, therefor no other node needs to be
        // activated.
        if (nodeToBeShown == null && children.keys.contains("")) {
          final defaultWidget = children[""]!;
          return defaultWidget;
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
        Widget widgetToBeShown = children[nodeToBeShown.name]!;

        return GgRouterCore(
          child: widgetToBeShown,
          node: nodeToBeShown,
        );
      },
    );

    return result;
  }

  // ...........................................................................
  _createChildNodes(GgRouterNode parentNode) {
    children.keys.forEach((routeName) {
      parentNode.child(name: routeName);
    });
  }

  // ...........................................................................
  static GgRouterNode node({
    required BuildContext context,
  }) {
    final result = GgRouterCore.of(context)?.node;

    if (result == null) {
      throw ArgumentError(
        'Did not find an instance of GgRouterDelegate.\n'
        'Please wrap your GgRouter into a MaterialApp.router(...) and '
        'assign an instance of GgRouterDelegate to "routerDelegate".\n'
        'For more details look into "gg_router/example/main.dart".',
      );
    }

    return result;
  }
}
