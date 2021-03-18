// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';

import 'gg_router.dart';

/// A callback GgRouter uses to animate appearing and disappearing widgets.
/// - [context] The current build context.
/// - [animation] The ongoing animation.
/// - [child] The child to appear or disappear.
/// - [nodeIn] The node currently appearing.
/// - [nodeOut] The node currently disappearing.
typedef GgPopoverAnimationBuilder = Widget Function(
  BuildContext context,
  Animation animation,
  Widget child,
  GgRouteTreeNode? node,
);

// #############################################################################
/// Use [GgPopoverRouter] to show a selected route infront of an backgroundWidget.
class GgPopoverRouter extends StatefulWidget {
  // ...........................................................................

  /// Constructor.
  /// - [key] The widget's key.
  /// - [backgroundWidget] The background widget.
  /// - [foregroundRoutes] A list of routes which are shown infront of
  ///   [backgroundWidget]. Only the route is shown which matches the currently
  ///   visible path segment.
  GgPopoverRouter({
    required Key key,
    required this.backgroundWidget,
    required this.foregroundRoutes,
    this.inAnimation,
    this.outAnimation,
    this.animationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  // ...........................................................................
  /// The background widget.
  final Widget backgroundWidget;

  // ...........................................................................
  /// The list of routes which are shown infront of the [backgroundWidget].
  /// Only the route belonging to the visible child route is shown.
  final Map<String, Widget Function(BuildContext)> foregroundRoutes;

  /// This animation is applied to the appearing popover
  final GgPopoverAnimationBuilder? inAnimation;

  /// this animation is applied to the disappearing popover
  final GgPopoverAnimationBuilder? outAnimation;

  /// The duration for route transitions.
  final Duration animationDuration;

  @override
  _GgPopoverRouterState createState() => _GgPopoverRouterState();
}

// #############################################################################
class _GgPopoverRouterState extends State<GgPopoverRouter>
    with TickerProviderStateMixin {
  // ...........................................................................
  @override
  dispose() {
    _dispose.reversed.forEach((d) => d());
    super.dispose();
  }

  // ...........................................................................
  @override
  void initState() {
    _initAnimation();
    _observeActiveChildChange();
    super.initState();
  }

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    if (_popOver == null) {
      return widget.backgroundWidget;
    } else {
      final child = Stack(
        children: [
          widget.backgroundWidget,
          _popOver!,
        ],
      );

      return child;
    }
  }

  // ######################
  // Private
  // ######################

  final List<Function()> _dispose = [];

  // ...........................................................................
  _observeActiveChildChange() {
    final s = GgRouter.of(context).onStagedChildChange.listen((event) {
      _update();
    });

    _dispose.add(s.cancel);
    _update();
  }

  // ...........................................................................
  Widget? _popOver;
  Widget? _popOverContent;

  // ...........................................................................
  _update() {
    final node = GgRouter.of(context).node;

    // ....................................
    // If no content is shown, hide popover
    if (node.stagedChild == null &&
        node.childToBeFadedIn == null &&
        node.childToBeFadedOut == null &&
        _popOver == null) {
      setState(() {
        _popOver = null;
      });
      return;
    }

    // ...........................................................
    // If no animation is needed show the popover content directly
    bool fadeIn = node.childToBeFadedIn != null && widget.inAnimation != null;
    final fadeOut = node.stagedChild == null &&
        _popOverContent != null &&
        widget.outAnimation != null;

    // ..........................
    // Calculate popover content
    _popOverContent = node.stagedChild != null
        ? GgRouter(
            widget.foregroundRoutes,
            key: ValueKey(node.stagedChild?.pathHashCode ?? 'GgPopoverRouter'),
          )
        : fadeOut
            ? _popOverContent
            : null;

    bool noAnimationNeeded = !fadeIn && !fadeOut;

    if (noAnimationNeeded) {
      setState(() {
        _popOver = _popOverContent;
      });
      return;
    }

    // .................
    // Prepare animation
    if (!_animation.isAnimating) {
      // ...............
      // Start animation
      _animation.forward();

      // ...........................
      // Wrap content into animation
      final animationCallback =
          (fadeIn ? widget.inAnimation : widget.outAnimation)!;

      _popOver = AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return animationCallback(context, _animation, _popOverContent!, node);
        },
      );

      // ................................
      // Reset needs fade after animation
      _animationStatusListener = (status) {
        if (status == AnimationStatus.completed) {
          node.childToBeFadedIn?.needsFade = false;
          node.childToBeFadedOut?.needsFade = false;
          if (fadeOut) {
            _popOver = null;
            _popOverContent = null;
          }
          _animation.removeStatusListener(_animationStatusListener);

          setState(() {
            _animation.reset();
            _popOver = _popOverContent;
          });
        }
      };
      _animation.addStatusListener(_animationStatusListener);

      // Trigger build
      setState(() {});
    }
  }

  // ...........................................................................
  late AnimationController _animation;
  late Function(AnimationStatus) _animationStatusListener;

  // ...........................................................................
  _initAnimation() {
    _animation =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _dispose.add(() => _animation.dispose());
  }
}
