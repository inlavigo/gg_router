// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import './gg_route_param.dart';

class GgRouteParams extends InheritedWidget {
  // ...........................................................................
  GgRouteParams({
    Key? key,
    required this.prefix,
    required Widget Function(BuildContext) builder,
    required this.params,
  }) : super(
          key: key,
          child: Builder(
            builder: (context) {
              // Todo: Write params into node

              return builder(context);
            },
          ),
        );

  // ...........................................................................
  final String prefix;
  final Map<String, GgRouteParam> params;

  // ...........................................................................
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
