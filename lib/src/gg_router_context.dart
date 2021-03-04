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
  GgRouterContext({required BuildContext context}) {
    _node = GgRouter.node(context: context);
  }

  // ...........................................................................
  GgRouterNode get node => _node;

  // ...........................................................................
  void navigateTo(String path) {
    node.navigateTo(path);
  }

  // ...........................................................................
  String? get routeName {
    return node.name;
  }

  // ...........................................................................
  String? get routeNameOfActiveChild {
    return node.activeChild?.name;
  }

  // ...........................................................................
  int? get indexOfActiveChild {
    return node.activeChild?.index;
  }

  // ...........................................................................
  String get routePath {
    return node.pathString;
  }

  // ...........................................................................
  Stream<void> get onActiveChildChange {
    return node.activeChildDidChange;
  }

  // ######################
  // Private
  // ######################
  late GgRouterNode _node;
}

// #############################################################################
extension GgContextRouteExtension on BuildContext {
  GgRouterContext get router => GgRouterContext(context: this);
}
