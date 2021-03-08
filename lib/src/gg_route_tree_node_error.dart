// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_router/gg_router.dart';

class GgRouteTreeNodeError extends Error {
  // ...........................................................................
  GgRouteTreeNodeError({
    required this.id,
    required this.message,
    this.node,
  });

  // ...........................................................................
  final String message;
  final String id;
  final GgRouteTreeNode? node;

  // ...........................................................................
  GgRouteTreeNodeError withNode(GgRouteTreeNode node) {
    return GgRouteTreeNodeError(id: id, message: message, node: node);
  }
}

// #############################################################################
final exampleGgRouteTreeNodeError = () => GgRouteTreeNodeError(
      id: 'GRC008446',
      message: 'RouterError',
    );
