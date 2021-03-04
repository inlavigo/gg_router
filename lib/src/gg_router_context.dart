// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';

import './gg_route_node.dart';
import './gg_router.dart';

// #############################################################################
class GgRouterContext {
  const GgRouterContext({required this.context});

  // ...........................................................................
  final BuildContext context;

  // ...........................................................................
  GgRouterNode get node => GgRouter.node(context: context);

  // ...........................................................................
  void navigateTo(String path) {
    final node = GgRouter.node(context: context);
    node.navigateTo(path);
  }

  // ...........................................................................
  String? get routeName {
    final node = GgRouter.node(context: context);
    return node.name;
  }

  // ...........................................................................
  String? get routeNameOfActiveChild {
    final node = GgRouter.node(context: context);
    return node.activeChild?.name;
  }

  // ...........................................................................
  String get routePath {
    final node = GgRouter.node(context: context);
    return node.pathString;
  }

  // ...........................................................................
  Stream<void> get onActiveChildChange {
    final node = GgRouter.node(context: context);
    return node.activeChildDidChange;
  }
}

// #############################################################################
extension GgContextRouteExtension on BuildContext {
  GgRouterContext get router => GgRouterContext(context: this);
}
