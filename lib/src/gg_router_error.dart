// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_router/gg_router.dart';

class GgRouterError extends Error {
  // ...........................................................................
  GgRouterError({
    required this.id,
    required this.message,
    this.node,
  });

  // ...........................................................................
  final String message;
  final String id;
  final GgRouterNode? node;

  // ...........................................................................
  GgRouterError withNode(GgRouterNode node) {
    return GgRouterError(id: id, message: message, node: node);
  }
}

// #############################################################################
final exampleGgRouterError = () => GgRouterError(
      id: 'GRC008446',
      message: 'RouterError',
    );
