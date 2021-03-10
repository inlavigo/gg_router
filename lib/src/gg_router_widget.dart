// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_value/gg_value.dart';
import 'gg_route_tree_node.dart';

// #############################################################################
class GgRouterWidget extends StatefulWidget {
  const GgRouterWidget(this.children)
      : _rootChild = null,
        _rootNode = null,
        super();

  const GgRouterWidget.root(
      {Key? key, required Widget child, required GgRouteTreeNode node})
      : _rootChild = child,
        _rootNode = node,
        children = const {},
        super(key: key);

  // ...........................................................................
  final Map<String, Widget Function(BuildContext)> children;

  // ...........................................................................
  @override
  GgRouterWidgetState createState() => GgRouterWidgetState();

  // ...........................................................................
  static const noGgRouterDelegateFoundError =
      'Did not find an instance of GgRouterDelegate.\n'
      'Please wrap your GgRouter into a MaterialApp.router(...) and '
      'assign an instance of GgRouterDelegate to "routerDelegate".\n'
      'For more details look into "gg_router/example/main.dart".';

  // ...........................................................................
  static GgRouterWidgetState of(
    BuildContext context, {
    bool rootRouter = false,
  }) {
    GgRouterWidgetState? routerWidgetState;
    if (context is StatefulElement && context.state is GgRouterWidgetState) {
      routerWidgetState = context.state as GgRouterWidgetState;
    }
    if (rootRouter) {
      routerWidgetState =
          context.findRootAncestorStateOfType<GgRouterWidgetState>() ??
              routerWidgetState;
    } else {
      // Normally we would just look for the next GgRouterWidgeState in the
      // widget hierarchy.
      // But in the case of routes named "", we need to go one level higher,
      // i.e. we need to look for the next router that has a node assigned.
      GgRouteTreeNode? node;
      BuildContext? c = context;

      while (node == null && c != null) {
        final state = c.findAncestorStateOfType<GgRouterWidgetState>();
        node = (state?._isReady ?? false) ? state!.node : null;
        c = state?.context;
        routerWidgetState = state ?? routerWidgetState;
      }
    }

    assert(() {
      if (routerWidgetState == null) {
        throw FlutterError(noGgRouterDelegateFoundError);
      }
      return true;
    }());
    return routerWidgetState!;
  }

  // ...........................................................................
  bool get _isRoot => _rootChild != null;
  final Widget? _rootChild;
  final GgRouteTreeNode? _rootNode;
}

// #############################################################################
class GgRouterWidgetState extends State<GgRouterWidget> {
  // ...........................................................................
  late GgRouteTreeNode node;

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

  // ...........................................................................
  GgValue? param(String name) => node.ownOrParentParam(name);

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    final b = widget._isRoot ? _buildRoot : _buildNonRoot;
    return b(context);
  }

  // ...........................................................................
  Widget _buildRoot(BuildContext context) {
    node = widget._rootNode!;
    _isReady = true;
    return widget._rootChild!;
  }

  // ...........................................................................
  Widget _buildNonRoot(BuildContext context) {
    final parentNode = GgRouterWidget.of(context).node;

    _createChildNodes(parentNode);

    assert(widget.children.length > 0);

    // Create a stream builder rebuilding the tree on active child change.
    final result = StreamBuilder<GgRouteTreeNode?>(
      stream: parentNode.activeChildDidChange,
      builder: (context, snapShot) {
        _isReady = false;

        GgRouteTreeNode? nodeToBeShown = parentNode.activeChild;

        // ...............................................
        // Use previous route, if current route is invalid
        bool routeIsValid = nodeToBeShown == null ||
            widget.children.keys.contains(nodeToBeShown.name);

        if (!routeIsValid) {
          final invalidNode = nodeToBeShown;
          nodeToBeShown = parentNode.previousActiveChild;
          nodeToBeShown?.isActive = true;
          parentNode.removeChild(invalidNode);
          parentNode.setError(
            GgRouteTreeNodeError(
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
        if (nodeToBeShown == null && widget.children.keys.contains("")) {
          final defaultWidget = widget.children[""]!;
          return defaultWidget(context);
        }

        // ..............................................
        // If no active child is defined and no default route is defined,
        // take the first possible child.
        if (nodeToBeShown == null) {
          nodeToBeShown = parentNode.child(name: widget.children.keys.first);
        }

        // .............................
        // Activate the node to be shown
        nodeToBeShown.isActive = true;

        // .....................................
        // Show the widget belonging to the node
        final widgetToBeShown = widget.children[nodeToBeShown.name]!;

        node = nodeToBeShown;
        _isReady = true;

        return widgetToBeShown(context);
      },
    );

    return result;
  }

  // ...........................................................................
  _createChildNodes(GgRouteTreeNode parentNode) {
    widget.children.keys.forEach((routeName) {
      parentNode.child(name: routeName);
    });
  }

  // ...........................................................................
  bool _isReady = false;
}
