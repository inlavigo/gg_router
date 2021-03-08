// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

class GgRouteParam<T> {
  GgRouteParam({required this.seed});

  // ...........................................................................
  final T seed;
}

// #############################################################################
final exampleGgRouteParam = <T>({T? seed}) => GgRouteParam(seed: seed ?? 5);
