// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';
import 'package:gg_router/gg_router.dart';

class GgRouteChangeBuilder extends StatelessWidget {
  /// Creates a widget rebuilding its child on child route changes
  const GgRouteChangeBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    final router = GgRouter.of(context);

    return StreamBuilder(
        stream: router.node.onChange,
        builder: (context, _) {
          return builder(context);
        });
  }
}
