// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter_test/flutter_test.dart';
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
  });
}
