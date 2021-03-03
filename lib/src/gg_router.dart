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

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    // Get parent node
    final parentNode = node(context: context);

    assert(children.length > 0);

    // Create a stream builder rebuilding the tree on active child change.
    final result = StreamBuilder<GgRouterNode?>(
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

        // Otherwise create a GgRouterCore for the active child and return it.
        else {
          activeChildWidget =
              children[activeChildNode.name] ?? Text('Error 404 Not Found');
        }

        return GgRouterCore(
          child: activeChildWidget,
          node: activeChildNode,
        );
      },
    );

    return result;
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

// #############################################################################
class GgRouterContext {
  const GgRouterContext({required this.context});

  final BuildContext context;

  GgRouterNode get node => GgRouter.node(context: context);

  void navigateTo(String path) {
    final node = GgRouter.node(context: context);
    node.navigateTo(path);
  }

  String? get routeSegment {
    final node = GgRouter.node(context: context);
    return node.name;
  }

  String? get activeChildRouteSegment {
    final node = GgRouter.node(context: context);
    return node.activeChild?.name;
  }

  String get routePath {
    final node = GgRouter.node(context: context);
    return node.pathString;
  }

  Stream<void> get onActiveChildChange {
    final node = GgRouter.node(context: context);
    return node.activeChildDidChange;
  }
}

// #############################################################################
extension GgContextRouteExtension on BuildContext {
  GgRouterContext get router => GgRouterContext(context: this);
}
