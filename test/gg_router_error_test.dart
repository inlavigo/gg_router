// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_router/src/gg_router_error.dart';

main() {
  late GgRouterError ggRouterError;

  init() {
    ggRouterError = exampleGgRouterError();
  }

  group('GgRouterError', () {
    // #########################################################################
    group('Constructor', () {
      test('should be instantiated', () {
        init();
        expect(ggRouterError, isNotNull);
      });
    });

    // #########################################################################
    group('withNode', () {
      test('should copy the error and add the node to it', () {
        final node = GgRouteTreeNode(name: '');
        final copy = ggRouterError.withNode(node);
        expect(copy.node, node);
        expect(copy.id, ggRouterError.id);
        expect(copy.message, ggRouterError.message);
      });
    });
  });
}
