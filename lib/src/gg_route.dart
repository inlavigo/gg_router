// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:gg_route/gg_route.dart';

// #############################################################################

class _GgRouteCore extends InheritedWidget {
  // ...........................................................................
  _GgRouteCore({
    Key? key,
    required this.name,
    required Widget child,
    required this.node,
  }) : super(key: key, child: child);

  // final Widget child;
  final String name;

  final GgRouteNode node;

  // ...........................................................................
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  // ...........................................................................
  static _GgRouteCore? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_GgRouteCore>();
  }
}

// #############################################################################

class GgRoute extends StatefulWidget {
  GgRoute({Key? key, required this.child, required this.name})
      : super(key: key);

  final Widget child;
  final String name;

  @override
  _GgRouteState createState() => _GgRouteState();
}

// #############################################################################
class _GgRouteState extends State<GgRoute> {
  GgRouteNode? node;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    // Get parent lite route

    _initNode(context);

    final core = _GgRouteCore(
      name: widget.name,
      child: widget.child,
      node: node!,
    );

    return core;
  }

  // ...........................................................................
  bool get isRoot => node!.parent == null;

  // ...........................................................................
  _initNode(BuildContext context) {
    if (node == null) {
      final existingParentNode = _GgRouteCore.of(context)?.node;

      final parentNode = existingParentNode ?? GgRouteNode(name: '_root');

      node = parentNode.child(name: widget.name);
    }
  }
}
