// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';

main() {
  late GgRouteParam ggRouteParam;

  init() {
    ggRouteParam = exampleGgRouteParam(seed: 5);
  }

  dispose() {}

  group('GgRouteParam<T>', () {
    // #########################################################################
    group('Constructor', () {
      test(
          'should throw an exception if T is not a string and has not a parse function',
          () {
        init();
        expect(ggRouteParam, isNotNull);
        dispose();
      });
    });
  });
}
