// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'package:flutter/material.dart';
import 'package:gg_route/gg_route.dart';
import 'package:gg_route/src/gg_route_core.dart';

// #############################################################################
class GgRoute extends StatelessWidget {
  const GgRoute({
    Key? key,
    required this.child,
    required this.name,
  }) : super(key: key);

  // ...........................................................................
  final Widget child;
  final String name;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    final node = _node(context);

    final core = GgRouteCore(
      child: child,
      node: node,
    );

    node.isActive = true;

    return core;
  }

  // ...........................................................................
  GgRouteNode _node(BuildContext context) {
    final parent = GgRouteCore.of(context)?.node;
    late GgRouteNode result;
    if (parent == null) {
      throw FormatException('Did not find an instance of GgRouterDelegate.\n'
          'Please wrap your GgRoute into a MaterialApp.router(...) and '
          'assign an instance of GgRouterDelegate to "routerDelegate".\n'
          'For more details look into "gg_router/example/main.dart".');
    } else {
      result = parent.child(name: name);
    }

    return result;
  }
}
