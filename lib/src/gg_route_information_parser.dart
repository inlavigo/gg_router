// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// .............................................................................
class GgRouteInformationParser
    extends RouteInformationParser<RouteInformation> {
  // ...........................................................................
  @override
  Future<RouteInformation> parseRouteInformation(
      RouteInformation routeInformation) {
    return SynchronousFuture(routeInformation);
  }

  // ...........................................................................
  @override
  RouteInformation restoreRouteInformation(RouteInformation configuration) {
    return configuration;
  }
}
