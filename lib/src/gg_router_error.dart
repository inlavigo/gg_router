// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

class GgRouterError extends Error {
  GgRouterError({required this.id, required this.message});

  final String message;
  final String id;
}

// #############################################################################
final exampleGgRouterError = () => GgRouterError(
      id: 'GRC008446',
      message: 'RouterError',
    );
