// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';

// .............................................................................
class GgRouteInformationParser extends RouteInformationParser<Uri> {
  // ...........................................................................
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async {
    if (routeInformation.location == null) {
      return Uri();
    }
    final uri = Uri.parse(routeInformation.location!);
    return uri;
  }

  // ...........................................................................
  @override
  RouteInformation restoreRouteInformation(Uri configuration) {
    return RouteInformation(location: '/a/b');
  }
}
