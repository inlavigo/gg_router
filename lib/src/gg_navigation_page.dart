// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';
import 'package:gg_router/gg_router.dart';

/// Allows you to create a widget with a navigation bar at the top
/// and a content widget below.
class GgNavigationPage extends StatelessWidget {
  // ...........................................................................
  const GgNavigationPage({
    Key? key,
    required this.router,
  }) : super(key: key);

  // ...........................................................................
  /// The router for which the navigation page is created.
  /// The router must provide an _INDEX_ route.
  /// All child routes must be of type GgNavigationPage
  final GgRouter router;

  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    return _decorateRouter;
  }

  // ...........................................................................
  static const indexRouteIsMissingError =
      'The router must contain an _INDEX_ child'
      'which will be wrapped into a scaffold showing a navigation bar at the top '
      'and the _INDEX_ child below.';

  static const indexWidgetMustNotBeANavigationPage =
      'The _INDEX_ widget must not be of type GgNavigationPage.';

  static const otherChildrenMustBeANavigationPage =
      'All children of the router of a navigation page '
      'must be also of type GgNavigationPage';

  // ...........................................................................
  _checkIfIndexRouteExists() {
    if (router.children['_INDEX_'] == null) {
      throw ArgumentError(indexRouteIsMissingError);
    }
  }

  // ...........................................................................
  get _decorateRouter {
    final Map<String, Widget Function(BuildContext)> decoratedChildren = {};

    _checkIfIndexRouteExists();

    router.children.forEach((key, child) {
      if (key == '_INDEX_') {
        decoratedChildren[key] = _decorateIndexRoute(child);
      } else {
        decoratedChildren[key] = _decorateOtherRoute(child);
      }
    });

    final result = GgRouter.from(router, children: decoratedChildren);
    return result;
  }

  // ...........................................................................
  _decorateIndexRoute(Widget Function(BuildContext) child) {
    return (BuildContext context) {
      final widget = child(context);

      // Make sure index widget is not a navigation page
      if (widget is GgNavigationPage) {
        throw ArgumentError(indexWidgetMustNotBeANavigationPage);
      }

      // Decorate index widget with an navigation bar
      // Todo: Do the decoration
      return GgPageWithNavBar(
        content: widget,
      );
    };
  }

  // ...........................................................................
  _decorateOtherRoute(Widget Function(BuildContext) child) {
    return (BuildContext context) {
      final widget = child(context);

      // Make sure index widget is not a navigation page
      if (!(widget is GgNavigationPage)) {
        throw ArgumentError(otherChildrenMustBeANavigationPage);
      }

      // Otherwise let widget unchanged
      return widget;
    };
  }
}

// #############################################################################
class GgPageWithNavBar extends StatelessWidget {
  const GgPageWithNavBar({Key? key, required this.content}) : super(key: key);

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: null,
    );
  }
}
