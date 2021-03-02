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

    // Create a stream builder rebuilding the tree on active child change.
    final result = StreamBuilder<GgRouteNode?>(
      stream: parentNode.activeChildDidChange,
      builder: (context, snapShot) {
        var activeChildNode = parentNode.activeChild;
        Widget activeChildWidget;

        // If no active child is available, take child with route "" or "."
        if (activeChildNode == null) {
          final defaultWidget = children[''] ?? children['.'];
          if (defaultWidget != null) {
            return defaultWidget;
          }
        }

        // If no default widget is available, activate the first route
        if (activeChildNode == null) {
          activeChildNode = parentNode.child(name: children.keys.first);
          activeChildNode.isActive = true;
          activeChildWidget = children.values.first;
        }

        // Otherwise create a GgRouteCore for the active child and return it.
        else {
          activeChildWidget =
              children[activeChildNode.name] ?? Text('Error 404 Not Found');
        }

        return GgRouteCore(child: activeChildWidget, node: activeChildNode);
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
      throw ArgumentError(
        'Did not find an instance of GgRouterDelegate.\n'
        'Please wrap your GgRoute into a MaterialApp.router(...) and '
        'assign an instance of GgRouterDelegate to "routerDelegate".\n'
        'For more details look into "gg_router/example/main.dart".',
      );
    }

    return parent;
  }
}

// #############################################################################
extension GgContextRouteExtension on BuildContext {
  void selectRoute(String path) {
    final parent = GgRoute.parent(context: this);
    parent.navigateTo(path);
  }
}
