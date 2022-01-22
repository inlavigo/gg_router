// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';

class GgNavigationBar extends StatelessWidget {
  const GgNavigationBar({
    Key? key,
    this.closeRoute = '/',
    this.backRoute = '../_INDEX_',
    this.title,
    this.showCloseButton = true,
    this.showBackButton = true,
  }) : super(key: key);
  final String closeRoute;
  final String backRoute;
  final bool showCloseButton;
  final bool showBackButton;
  final String? title;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context).appBarTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBackButton) Text('Back'),
        _spacer,
        if (showCloseButton) Text('Close'),
      ],
    );
  }

  // ...........................................................................
  Widget get _spacer {
    return Expanded(child: IgnorePointer(child: Container()));
  }
}
