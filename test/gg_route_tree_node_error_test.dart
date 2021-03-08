// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_router/src/gg_route_tree_node_error.dart';

main() {
  late GgRouteTreeNodeError ggRouteTreeNodeError;

  init() {
    ggRouteTreeNodeError = exampleGgRouteTreeNodeError();
  }

  group('GgRouteTreeNodeError', () {
    // #########################################################################
    group('Constructor', () {
      test('should be instantiated', () {
        init();
        expect(ggRouteTreeNodeError, isNotNull);
      });
    });

    // #########################################################################
    group('withNode', () {
      test('should copy the error and add the node to it', () {
        final node = GgRouteTreeNode(name: '');
        final copy = ggRouteTreeNodeError.withNode(node);
        expect(copy.node, node);
        expect(copy.id, ggRouteTreeNodeError.id);
        expect(copy.message, ggRouteTreeNodeError.message);
      });
    });
  });
}
