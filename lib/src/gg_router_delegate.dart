// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';

class GgRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  // ...........................................................................
  GgRouterDelegate({required this.child})
      : navigatorKey = GlobalKey<NavigatorState>();

  // ...........................................................................
  final GlobalKey<NavigatorState> navigatorKey;
  Widget child;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return child;
  }

  // ...........................................................................
  @override
  Uri get currentConfiguration {
    print('currentConfiguration');
    return Uri();
  }

  // ...........................................................................
  @override
  Future<void> setNewRoutePath(Uri path) async {
    print('setNewRoutePath $path');
  }
}
