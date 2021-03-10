// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';

import 'gg_router_widget.dart';

/// Allows to define a bunch of routes witch are displayed infront of a
/// base widget.
class GgRouterOverlayWidget extends StatelessWidget {
  // ...........................................................................
  const GgRouterOverlayWidget({
    Key? key,
    required this.base,
    required this.overlays,
  }) : super(key: key);

  final Widget base;
  final Map<String, Widget Function(BuildContext)> overlays;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: GgRouterWidget.of(context).onActiveChildChange,
      builder: (context, snapshot) {
        final node = GgRouterWidget.of(context).node;
        if (node.activeChild == null) {
          return base;
        } else {
          return Stack(
            children: [
              base,
              GgRouterWidget(overlays),
            ],
          );
        }
      },
    );
  }
}
