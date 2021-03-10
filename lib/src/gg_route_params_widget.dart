// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';
import './gg_route_param.dart';

class GgRouteParamsWidget extends StatelessWidget {
  // ...........................................................................
  GgRouteParamsWidget({
    Key? key,
    required this.child,
    required this.params,
  }) : super(
          key: key,
        );

  // ...........................................................................
  final Map<String, GgRouteParam> params;
  final Widget child;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    _checkParams(context);
    _writeParamsToNode(context);
    return child;
  }

  // ...........................................................................
  void _checkParams(BuildContext context) {
    // Check if any of the parent route param widgets already contains a
    // parameter with same name.
    context.visitAncestorElements((element) {
      GgRouteParamsWidget? parentWidget = element.widget is GgRouteParamsWidget
          ? element.widget as GgRouteParamsWidget
          : null;

      if (parentWidget != null) {
        final existingParams = parentWidget.params.keys;
        final ownParams = params.keys;
        ownParams.forEach((ownParam) {
          if (existingParams.contains(ownParam)) {
            throw ArgumentError('Cannot process route param "$ownParam". '
                'There is already a parent GgRouteParams object, containing a route param with the name "$ownParam". '
                'Make sure you are using unique param names accross a route and its parents.');
          }
        });
      }

      return true;
    });
  }

  // ...........................................................................
  void _writeParamsToNode(BuildContext context) {
    final router = GgRouterWidget.of(context);
    params.forEach((name, value) {
      router.node.findOrCreateParam(name: name, seed: value.seed);
    });
  }
}
