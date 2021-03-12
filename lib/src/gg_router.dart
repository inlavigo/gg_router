// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_value/gg_value.dart';
import 'gg_route_tree_node.dart';

// #############################################################################
/// Use [GgRouter] to connect your widget hierarchy with a nested route tree.
class GgRouter extends StatefulWidget {
  // ...........................................................................
  /// Constructor, which takes a map of child widgets. Depending on the currently
  /// selected routed one of the child widgets is shown.
  ///
  /// ```
  /// GgRouter({
  ///   '':       (context) => Text('The index screen'),
  ///   'green':  (context) => Container(color: Colors.green),
  ///   'yellow': (context) => Container(color: Colors.red),
  ///   'red':    (context) => Container(color: Colors.red),
  /// })
  /// ```
  const GgRouter(this.children)
      : _rootChild = null,
        _rootNode = null,
        super();

  // ...........................................................................
  /// This method is called by [GgRouterDelegate] to create the root instance.
  const GgRouter.root(
      {Key? key, required Widget child, required GgRouteTreeNode node})
      : _rootChild = child,
        _rootNode = node,
        children = const {},
        super(key: key);

  // ...........................................................................
  /// The child routes of this router.
  final Map<String, Widget Function(BuildContext)> children;

  // ...........................................................................
  @override
  GgRouterState createState() => GgRouterState();

  // ...........................................................................
  /// This error message is thrown when you forget to instaniate a
  /// [GgRouterDelegate] before instantiating a GgRouter.
  static const noGgRouterDelegateFoundError =
      'Did not find an instance of GgRouterDelegate.\n'
      'Please wrap your GgRouter into a MaterialApp.router(...) and '
      'assign an instance of GgRouterDelegate to "routerDelegate".\n'
      'For more details look into "gg_router/example/main.dart".';

  // ...........................................................................
  /// Returns the next [GgRouterState] instance in the widget tree.
  static GgRouterState of(
    BuildContext context, {
    bool rootRouter = false,
  }) {
    GgRouterState? routerWidgetState;
    if (context is StatefulElement && context.state is GgRouterState) {
      routerWidgetState = context.state as GgRouterState;
    }
    if (rootRouter) {
      routerWidgetState =
          context.findRootAncestorStateOfType<GgRouterState>() ??
              routerWidgetState;
    } else {
      // Normally we would just look for the next GgRouterWidgeState in the
      // widget hierarchy.
      // But in the case of routes named "", we need to go one level higher,
      // i.e. we need to look for the next router that has a node assigned.
      GgRouteTreeNode? node;
      BuildContext? c = context;

      while (node == null && c != null) {
        final state = c.findAncestorStateOfType<GgRouterState>();
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

  // ######################
  // Private
  // ######################

  // ...........................................................................
  bool get _isRoot => _rootChild != null;
  final Widget? _rootChild;
  final GgRouteTreeNode? _rootNode;
}

// #############################################################################
class GgRouterState extends State<GgRouter> {
  // ...........................................................................
  /// The [GgRouteTreeNode] assigned to a [GgRouter] instance.
  late GgRouteTreeNode node;

  // ...........................................................................
  /// Activates the path in the node hierarchy.
  /// - [path] can be absolute, e.g. `/a/b/c`
  /// - [path] can be relative, e.g. `b/c` or `./b/c`
  /// - [path] can address parent element, e.g. `../`
  /// - [path] can address root, e.g. `/`
  void navigateTo(String path) {
    node.navigateTo(path);
  }

  // ...........................................................................
  /// Returns the name of the route, this [GgRouter] instance is assigned.
  /// Returns null if the route doesn't have a name.
  String? get routeName {
    return node.name;
  }

  // ...........................................................................
  /// Returns the name of the active child route.
  /// Returns null if no child is active.
  String? get routeNameOfActiveChild {
    return node.activeChild?.name;
  }

  // ...........................................................................
  /// Returns the index of the active child.
  /// Returns null, if no child is active.
  /// You can use that index to highlight the right entry in a menu for example.
  int? get indexOfActiveChild {
    return node.activeChild?.widgetIndex;
  }

  // ...........................................................................
  /// Returns the path of this [GgRouter] instance.
  String get routePath {
    return node.path;
  }

  // ...........................................................................
  /// Use this stream to be informed when the active child changes.
  Stream<void> get onActiveChildChange {
    return node.activeChildDidChange;
  }

  // ...........................................................................
  /// Use this method to change the param with [name] or to listen to changes.
  GgValue? param(String name) => node.ownOrParentParam(name);

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    final b = widget._isRoot ? _buildRoot : _buildNonRoot;
    return b(context);
  }

  // ######################
  // Private
  // ######################

  // ...........................................................................
  Widget _buildRoot(BuildContext context) {
    node = widget._rootNode!;
    _isReady = true;
    return widget._rootChild!;
  }

  // ...........................................................................
  Widget _buildNonRoot(BuildContext context) {
    final parentNode = GgRouter.of(context).node;

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
          nodeToBeShown = parentNode.previouslyActiveChild;
          nodeToBeShown?.isActive = true;
          parentNode.removeChild(invalidNode);
          parentNode.setError(
            GgRouteTreeNodeError(
              id: 'GRC008448',
              message:
                  'Route "${parentNode.path}" has no child named "${invalidNode.name}".',
            ),
          );
        }

        // ........................
        // Update the child indexes
        int i = 0;
        widget.children.keys.forEach((key) {
          parentNode.child(key).widgetIndex = i;
          i++;
        });

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
          nodeToBeShown = parentNode.child(widget.children.keys.first);
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
      parentNode.child(routeName);
    });
  }

  // ...........................................................................
  bool _isReady = false;
}
