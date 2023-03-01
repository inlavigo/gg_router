// @license
// Copyright (c) 2019 - 2023 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_value/gg_value.dart';

/// Allows to overwrite closeButton and backButton of the current navigation page
///
/// The overrides are reset on route changes.
class GgNavigationPageOverridesProvider extends StatefulWidget {
  // ...........................................................................
  const GgNavigationPageOverridesProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  // ...........................................................................
  @override
  State<GgNavigationPageOverridesProvider> createState() =>
      GgNavigationPageOverrides();
}

// #############################################################################
class GgNavigationPageOverrides
    extends State<GgNavigationPageOverridesProvider> {
  // ...........................................................................
  final closeButton = GgValue<WidgetBuilder?>(seed: null);
  final backButton = GgValue<WidgetBuilder?>(seed: null);
  Stream<void> get onBackgroundTapped => _backgroundTapped.stream;

  // ...........................................................................
  static GgNavigationPageOverrides of(BuildContext context) {
    final result = context.findAncestorStateOfType<GgNavigationPageOverrides>();
    if (result == null) {
      throw ArgumentError(
        'Error while calling "NavigationPageOverrides.of(context)".\n'
        'Please wrap your widget into a "NavigationPageOverridesWidget"',
      );
    }
    return result;
  }

  // ...........................................................................
  @override
  void initState() {
    _initBackgroundTapped();
    _resetOverridesOnRouteChanges();
    super.initState();
  }

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    final node = GgRouter.of(context).node;

    if (node.stagedChildPath != _lastRoute) {}

    _lastRoute = node.stagedChildPath;

    return GestureDetector(
      onTap: () => _backgroundTapped.add(null),
      child: Container(
        color: Colors.transparent,
        child: widget.child,
      ),
    );
  }

  // ######################
  // Private
  // ######################

  String _lastRoute = '';
  final _backgroundTapped = StreamController<void>.broadcast();
  void _initBackgroundTapped() {
    _dispose.add(_backgroundTapped.close);
  }

  final List<Function()> _dispose = [];

  // ...........................................................................
  @override
  void dispose() {
    for (final d in _dispose.reversed) {
      d();
    }
    super.dispose();
  }

  // ...........................................................................
  void _resetOverridesOnRouteChanges() {
    final s = GgRouter.of(context).node.stagedChildDidChange.listen(
      (event) {
        _resetOverrides();
      },
    );

    _dispose.add(s.cancel);
  }

  // ...........................................................................
  void _resetOverrides() {
    closeButton.value = null;
    backButton.value = null;
  }

  // ...........................................................................
}
