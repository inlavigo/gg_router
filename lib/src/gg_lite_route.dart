// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'package:flutter/material.dart';
import 'package:gg_lite_route/gg_lite_route.dart';

// #############################################################################
class GgLiteRouteCore extends InheritedWidget {
  // ...........................................................................
  GgLiteRouteCore({
    Key? key,
    required this.name,
    required Widget child,
    required this.node,
  }) : super(key: key, child: child);

  // final Widget child;
  final String name;

  final GgLiteRouteNode node;

  // ...........................................................................
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  // ...........................................................................
  static GgLiteRouteCore? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GgLiteRouteCore>();
  }
}

// #############################################################################

class GgLiteRoute extends StatefulWidget {
  GgLiteRoute({Key? key, required this.child, required this.name})
      : super(key: key);

  final Widget child;
  final String name;

  @override
  _GgLiteRouteState createState() => _GgLiteRouteState();
}

// #############################################################################
class _GgLiteRouteState extends State<GgLiteRoute> {
  GgLiteRouteNode? node;

  @override
  Widget build(BuildContext context) {
    // Get parent lite route

    _initNode(context);

    final result = GgLiteRouteCore(
      name: widget.name,
      child: widget.child,
      node: node!,
    );
    return result;
  }

  // ...........................................................................
  _initNode(BuildContext context) {
    if (node == null) {
      final existingParentNode = GgLiteRouteCore.of(context)?.node;

      final parentNode = existingParentNode ?? GgLiteRouteNode(name: '_root');

      node = parentNode.child(name: widget.name);
    }
  }
}
