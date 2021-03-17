// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_value/gg_value.dart';
import 'gg_route_tree_node.dart';

/// A callback GgRouter uses to animate appearing and disappearing widgets.
/// - [context] The current build context.
/// - [animation] The ongoing animation.
/// - [child] The child to appear or disappear.
/// - [nodeIn] The node currently appearing.
/// - [nodeOut] The node currently disappearing.
typedef GgAnimationBuilder = Widget Function(
  BuildContext context,
  Animation animation,
  Widget child,
  GgRouteTreeNode nodeIn,
  GgRouteTreeNode nodeOut,
);

// #############################################################################
class GgRouterCore extends StatelessWidget {
  const GgRouterCore({Key? key, required this.child, required this.node})
      : super(key: key);
  // ...........................................................................
  final Widget child;
  final GgRouteTreeNode node;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return child;
  }

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
  /// Returns the name of the visible child route.
  /// Returns null if no child is visible.
  String? get routeNameOfVisibleChild {
    return node.visibleChild?.name;
  }

  // ...........................................................................
  /// Returns the index of the visible child.
  /// Returns null, if no child is visible.
  /// You can use that index to highlight the right entry in a menu for example.
  int? get indexOfVisibleChild {
    return node.visibleChild?.widgetIndex;
  }

  // ...........................................................................
  /// Returns the path of this [GgRouter] instance.
  String get routePath {
    return node.path;
  }

  // ...........................................................................
  /// Use this stream to be informed when the visible child changes.
  Stream<void> get onVisibleChildChange {
    return node.visibleChildDidChange;
  }

  // ...........................................................................
  /// Use this method to change the param with [name] or to listen to changes.
  GgValue? param(String name) => node.ownOrParentParam(name);
}

// #############################################################################
/// Use [GgRouter] to connect your widget hierarchy with a nested route tree.
class GgRouter extends StatefulWidget {
  // ...........................................................................
  /// Constructor, which takes a map of child routes. Depending on the currently
  /// selected routed one of the child routes is shown.
  ///
  /// To animate widgets when switching a route, specify an [inAnimation] and
  /// an [outAnimation]. The first is applied to the widget appearing on
  /// the screen. The second is applied to the one disappearing.
  /// ```
  /// GgRouter({
  ///   '_INDEX_': (context) => Text('The index screen'),
  ///   'green':   (context) => Container(color: Colors.green),
  ///   'yellow':  (context) => Container(color: Colors.red),
  ///   'red':     (context) => Container(color: Colors.red),
  /// })
  /// ```
  GgRouter(
    this.children, {
    required Key key,
    this.inAnimation,
    this.outAnimation,
    this.animationDuration = const Duration(milliseconds: 500),
  })  : _rootChild = null,
        _rootNode = null,
        super(key: key) {
    _checkChildren();
    _checkAnimations();
  }

  // ...........................................................................
  /// This method is called by [GgRouterDelegate] to create the root instance.
  const GgRouter.root(
      {Key? key, required Widget child, required GgRouteTreeNode node})
      : _rootChild = child,
        _rootNode = node,
        children = const {},
        inAnimation = null,
        outAnimation = null,
        animationDuration = const Duration(milliseconds: 500),
        super(key: key);

  // ...........................................................................
  /// The duration for route transitions.
  final Duration animationDuration;

  // ...........................................................................
  /// The child routes of this router.
  final Map<String, Widget Function(BuildContext)> children;

  /// This animation is applied to the widget appearing on route transitions.
  final GgAnimationBuilder? inAnimation;

  /// this animation is applied to the widget disappearing on route transitions.
  final GgAnimationBuilder? outAnimation;

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
  static GgRouterCore of(
    BuildContext context, {
    bool rootRouter = false,
  }) {
    GgRouterCore? core = context.findAncestorWidgetOfExactType<GgRouterCore>();

    if (rootRouter) {
      final rootRouterState =
          context.findRootAncestorStateOfType<GgRouterState>()!;
      core = rootRouterState.rootRouterCore;
    }

    assert(() {
      if (core == null) {
        throw FlutterError(noGgRouterDelegateFoundError);
      }
      return true;
    }());
    return core!;
  }

  // ######################
  // Private
  // ######################

  // ...........................................................................
  bool get _isRoot => _rootChild != null;
  final Widget? _rootChild;
  final GgRouteTreeNode? _rootNode;

  _checkAnimations() {
    final inAnimationIsDefined = inAnimation != null;
    final outAnimationIsDefined = outAnimation != null;
    if (inAnimationIsDefined != outAnimationIsDefined) {
      throw ArgumentError('');
    }
  }

  // ...........................................................................
  _checkChildren() {
    children.keys.forEach((name) {
      if (!GgRouteTreeNode.isValidName(name)) {
        throw ArgumentError('The name "$name" is not a valid route name.');
      }
    });
  }
}

// #############################################################################
class GgRouterState extends State<GgRouter> with TickerProviderStateMixin {
  // ...........................................................................
  @override
  dispose() {
    _dispose.reversed.forEach((d) => d());
    super.dispose();
  }

  // ...........................................................................
  @override
  initState() {
    _initAnimation();
    _observeVisibleNode();
    _initRootRouterCore();
    super.initState();
  }

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
  final List<Function()> _dispose = [];

  // ...........................................................................
  GgRouteTreeNode? _previousVisibleNode;
  GgRouteTreeNode? _visibleNode;

  // ...........................................................................
  _observeVisibleNode() {
    // .........................................................................
    // If widget is a root widget, the root node will always be the visible node.
    if (widget._isRoot) {
      _previousVisibleNode = null;
      _visibleNode = widget._rootNode;
      return;
    }

    // ...............................
    // Get the responsible parent node
    final parentNode = GgRouter.of(context).node;

    // ...............................
    // For each child route, create a node
    _createChildNodes(parentNode);

    // ........................
    // Observe the visible child
    final s = parentNode.visibleChildDidChange.listen((_) {
      _updateVisibleChild();
    });

    _updateVisibleChild(isFirstTime: true);

    _dispose.add(s.cancel);
  }

  // ...........................................................................
  _updateVisibleChild({bool isFirstTime = false}) {
    final parentNode = GgRouter.of(context).node;

    // If parentNode is not visible, we still show the previously visible child
    if (!parentNode.isVisible) {
      setState(() {
        _visibleNode = parentNode.previouslyVisibleChild;
      });
      return;
    }

    // Let's get the visible child
    GgRouteTreeNode? newVisibleNode = parentNode.visibleChild;

    // ....................................................................
    // Delete the node from the tree if no widget for the node is existing
    bool routeIsValid = newVisibleNode == null ||
        widget.children.keys.contains(newVisibleNode.name);

    if (!routeIsValid) {
      final invalidNode = newVisibleNode;
      newVisibleNode = parentNode.previouslyVisibleChild;
      newVisibleNode?.isVisible = true;
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
      final child = parentNode.child(key);
      child.widgetIndex = i;
      i++;
    });

    // ...................................................
    // If no visible child is defined, take the index route
    if (newVisibleNode == null) {
      newVisibleNode = widget.children.containsKey('_INDEX_')
          ? parentNode.child('_INDEX_')
          : null;
    }

    // ............................................................
    // If no visible child is defined and no index route is defined,
    // take the first possible child.
    if (newVisibleNode == null) {
      newVisibleNode = parentNode.child(widget.children.keys.first);
    }

    // ......................................................
    // Activate the new visible node, but only the first time
    // At later times the right nodes need to be addressed by
    // navigate operations
    if (isFirstTime) {
      newVisibleNode.isVisible = true;
    }

    // .............................
    // Activate the node to be shown
    setState(() {
      _previousVisibleNode = _visibleNode;
      _visibleNode = newVisibleNode;
    });
  }

  // ...........................................................................
  GgRouterCore? rootRouterCore;

  // ...........................................................................
  _initRootRouterCore() {
    if (widget._isRoot) {
      rootRouterCore =
          GgRouterCore(child: widget._rootChild!, node: widget._rootNode!);
    }
  }

  // ...........................................................................
  Widget _buildRoot(BuildContext context) {
    widget._rootNode!.isVisible = true;
    return rootRouterCore!;
  }

  // ...........................................................................
  Widget _buildNonRoot(BuildContext context) {
    // .....................................
    // Show the widget belonging to the node
    final appearingWidget =
        _visibleNode != null ? widget.children[_visibleNode!.name] : null;

    final disappearingWidget = _previousVisibleNode != null
        ? widget.children[_previousVisibleNode!.name]
        : null;

    // ...............................
    // Estimate if animation is needed
    bool animationIsNeeded = disappearingWidget != null &&
        appearingWidget != null &&
        disappearingWidget != appearingWidget &&
        widget.inAnimation != null &&
        widget.outAnimation != null &&
        !_animation.isAnimating &&
        !_animation.isCompleted;

    // .........................................
    // If animation is needed, perform animation
    if (animationIsNeeded) {
      return _animate(
        appearingWidget,
        disappearingWidget,
        _visibleNode!,
        _previousVisibleNode!,
      );
    }

    // ....................................................
    // If no animation is needed, only show the visible node
    else {
      if (_animation.isCompleted) {
        _animation.reset();
      }

      return _visibleNode != null
          ? GgRouterCore(
              child: Builder(
                builder: (context) {
                  return appearingWidget?.call(context) ?? Container();
                },
              ),
              node: _visibleNode!)
          : Container();
    }
  }

  // ...........................................................................
  _animate(
    Widget Function(BuildContext) appearingWidget,
    Widget Function(BuildContext) disappearingWidget,
    GgRouteTreeNode appearingNode,
    GgRouteTreeNode disappearingNode,
  ) {
    _animation.reset();
    _animation.forward();

    final inWidget = () => widget.inAnimation!.call(
          context,
          _animation,
          GgRouterCore(
            child: Builder(builder: (context) => appearingWidget(context)),
            node: appearingNode,
          ),
          disappearingNode,
          appearingNode,
        );

    final outWidget = () => widget.outAnimation!.call(
          context,
          _animation,
          GgRouterCore(
            child: Builder(builder: (context) => disappearingWidget(context)),
            node: disappearingNode,
          ),
          disappearingNode,
          appearingNode,
        );

    return AnimatedBuilder(
        animation: _animation,
        builder: (context, widget) {
          return Stack(children: [
            outWidget(),
            inWidget(),
          ]);
        });
  }

  // ...........................................................................
  _initAnimation() {
    _animation =
        AnimationController(vsync: this, duration: widget.animationDuration);

    final listner = (status) {
      setState(() {});
    };
    _animation.addStatusListener(listner);
    _dispose.add(() => _animation.removeStatusListener(listner));
  }

  // ...........................................................................
  _createChildNodes(GgRouteTreeNode parentNode) {
    widget.children.keys.forEach((routeName) {
      parentNode.child(routeName);
    });
  }

  late AnimationController _animation;
}
