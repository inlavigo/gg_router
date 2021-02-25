// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this repository.

import 'package:flutter/material.dart';

// #############################################################################
class GgLiteRoute extends StatefulWidget {
  // ...........................................................................
  GgLiteRoute({
    Key? key,
    required this.name,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final String name;

  // ...........................................................................
  @override
  _GgLiteRouteState createState() => _GgLiteRouteState();
}

// #############################################################################
class _GgLiteRouteState extends State<GgLiteRoute> {
  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
