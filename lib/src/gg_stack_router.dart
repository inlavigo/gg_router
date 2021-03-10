// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';

import 'gg_router.dart';

/// Allows to define a bunch of routes on top of a base widget.
class GgStackRouter extends StatelessWidget {
  // ...........................................................................
  const GgStackRouter({
    Key? key,
    required this.baseWidget,
    required this.routesOnTop,
  }) : super(key: key);

  final Widget baseWidget;
  final Map<String, Widget Function(BuildContext)> routesOnTop;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: GgRouter.of(context).onActiveChildChange,
      builder: (context, snapshot) {
        final node = GgRouter.of(context).node;
        if (node.activeChild == null) {
          return baseWidget;
        } else {
          return Stack(
            children: [
              baseWidget,
              GgRouter(routesOnTop),
            ],
          );
        }
      },
    );
  }
}
