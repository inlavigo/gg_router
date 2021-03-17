// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';

import 'gg_router.dart';

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
  }) : super(key: key);

  // ...........................................................................
  /// The background widget.
  final Widget backgroundWidget;

  // ...........................................................................
  /// The list of routes which are shown infront of the [backgroundWidget].
  /// Only the route belonging to the visible child route is shown.
  final Map<String, Widget Function(BuildContext)> foregroundRoutes;

  @override
  _GgPopoverRouterState createState() => _GgPopoverRouterState();
}

// #############################################################################
class _GgPopoverRouterState extends State<GgPopoverRouter> {
  // ...........................................................................
  @override
  dispose() {
    _dispose.reversed.forEach((d) => d());
    super.dispose();
  }

  // ...........................................................................
  @override
  void initState() {
    _observeActiveChildChange();
    super.initState();
  }

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    if (_nodeToBeShown == null) {
      return widget.backgroundWidget;
    } else {
      return Stack(
        children: [
          widget.backgroundWidget,
          GgRouter(
            widget.foregroundRoutes,
            key: ValueKey(_nodeToBeShown!.pathHashCode),
          ),
        ],
      );
    }
  }

  // ######################
  // Private
  // ######################

  final List<Function()> _dispose = [];

  // ...........................................................................
  GgRouteTreeNode? _nodeToBeShown;

  // ...........................................................................
  _observeActiveChildChange() {
    final s = GgRouter.of(context).onVisibleChildChange.listen((event) {
      _update();
    });

    _dispose.add(s.cancel);
    _update();
  }

  // ...........................................................................
  _update() {
    final node = GgRouter.of(context).node;
    setState(() {
      _nodeToBeShown = node.activeChild;
    });
  }
}
