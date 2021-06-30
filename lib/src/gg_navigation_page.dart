// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gg_router/gg_router.dart';

/// Allows you to create a widget with a navigation bar at the top
/// and a content widget below.
class GgNavigationPage extends StatefulWidget {
  // ...........................................................................
  GgNavigationPage({
    Key? key,
    required this.pageContent,
    this.children,
    this.semanticLabels = const {},
  })  : _isRoot = false,
        super(key: key) {
    _checkChildren(children);
  }

  // ...........................................................................
  GgNavigationPage._withRoot(
      {Key? key,
      required this.pageContent,
      this.children,
      this.semanticLabels = const {}})
      : _isRoot = true,
        super(key: key) {
    _checkChildren(children);
  }

  /// A function building the page content
  final Widget Function(BuildContext) pageContent;

  /// The children of the page. Must bee pages also
  final Map<String, GgNavigationPage Function(BuildContext)>? children;

  /// The semantic labels for each route
  final Map<String, String> semanticLabels;

  // ...........................................................................
  static _checkChildren(
      Map<String, GgNavigationPage Function(BuildContext)>? children) {
    if (children != null && children.containsKey('_INDEX')) {
      throw ArgumentError(indexWidgetMustNotBeANavigationPage);
    }
  }

  // ...........................................................................
  @override
  State<GgNavigationPage> createState() => _GgNavigationPageState();

  static const indexWidgetMustNotBeANavigationPage =
      'The _INDEX_ widget must not be of type GgNavigationPage.';

  // ...........................................................................
  static const otherChildrenMustBeANavigationPage =
      'All children of the router of a navigation page '
      'must be also of type GgNavigationPage';

  // ...........................................................................
  static const noNavigationPageRootFound =
      'No ancestor of type GgNavigationPageRoot found. Please make sure to '
      'wrap your GgNavigationPage instance into a GgNavigationPageRoot instance';

  // ...........................................................................
  // Is written by GgNavigationPageRoot
  final bool _isRoot;
}

// #############################################################################
// .............................................................................
class _GgNavigationPageState extends State<GgNavigationPage> {
  // ...........................................................................
  @override
  Widget build(BuildContext context) {
    final root = _root(context);

    return GgRouter(
      _generateChildren(context),
      semanticLabels: widget.semanticLabels,
      key: GlobalKey(),
      animationDuration: root.animationDuration,
      inAnimation: root.inAnimation,
      outAnimation: root.outAnimation,
    );
  }

  final key = GlobalKey(debugLabel: '_GgNavigationPageState');

  // ...........................................................................
  GgNavigationPageRoot _root(BuildContext context) {
    final GgNavigationPageRoot? root = (widget is GgNavigationPageRoot)
        ? widget as GgNavigationPageRoot
        : GgNavigationPageRoot.of(context);

    if (root == null) {
      throw ArgumentError(GgNavigationPage.noNavigationPageRootFound);
    }

    return root;
  }

  // ...........................................................................
  bool get isRoot => widget._isRoot;

  // ...........................................................................
  _generateChildren(BuildContext context) {
    final result = Map<String, Widget Function(BuildContext)>();

    result['_INDEX_'] = (context) {
      final content = widget.pageContent(context);
      if (content is GgNavigationPage) {
        throw ArgumentError(
            GgNavigationPage.indexWidgetMustNotBeANavigationPage);
      }
      return GgPageWithNavBar(
        content: content,
        showBackButton: !isRoot,
      );
    };

    if (widget.children != null) {
      result.addAll(widget.children!);
    }

    return result;
  }
}

// #############################################################################

class GgNavigationPageRoot extends StatefulWidget {
  GgNavigationPageRoot({
    Key? key,
    required Widget Function(BuildContext) pageContent,
    Map<String, GgNavigationPage Function(BuildContext)>? children,
    Map<String, String> semanticLabels = const {},
    this.inAnimation,
    this.outAnimation,
    this.animationDuration = const Duration(milliseconds: 500),
    this.navigationBarBackgroundColor = Colors.transparent,
    this.navigationBarPadding = 0,
    this.navigationBarBackButton,
    this.navigationBarCloseButton,
    this.navigationBarTitle,
  })  : navigationPage = GgNavigationPage._withRoot(
            pageContent: pageContent,
            children: children,
            semanticLabels: semanticLabels),
        super(key: key);

  final GgNavigationPage navigationPage;

  @override
  GgNavigationPageRootState createState() => GgNavigationPageRootState();

  // ...........................................................................
  // The background color of the navigation bar
  final Color navigationBarBackgroundColor;

  // The padding of the navigation bar
  final double navigationBarPadding;

  // Use this callback to customize the close button appearance
  final Widget Function(BuildContext)? navigationBarCloseButton;

  // Use this callback to customize the back button appearance
  final Widget Function(BuildContext)? navigationBarBackButton;

  // Use this callback to customize the title appearance
  final Widget Function(BuildContext)? navigationBarTitle;

  // ...........................................................................
  /// The duration for route transitions.
  final Duration animationDuration;

  /// This animation is applied to the widget appearing on route transitions.
  final GgAnimationBuilder? inAnimation;

  /// this animation is applied to the widget disappearing on route transitions.
  final GgAnimationBuilder? outAnimation;

  // ...........................................................................
  static GgNavigationPageRoot? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<GgNavigationPageRoot>();
  }
}

class GgNavigationPageRootState extends State<GgNavigationPageRoot> {
  @override
  Widget build(BuildContext context) => widget.navigationPage;
}

// #############################################################################
class GgPageWithNavBar extends StatelessWidget {
  const GgPageWithNavBar({
    Key? key,
    required this.content,
    this.showBackButton = true,
  }) : super(key: key);

  final Widget content;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        content,
        _navigationBar(context),
      ],
    );
  }

  // ...........................................................................
  Widget _navigationBar(BuildContext context) {
    // Get root navigation page state
    final rootState =
        context.findAncestorStateOfType<GgNavigationPageRootState>();

    final rootPage = GgNavigationPageRoot.of(context)!;

    assert(rootState != null);
    assert(rootState?.context != null);
    final rootNode = GgRouter.of(rootState!.context).node;
    final ownNode = GgRouter.of(context).node;

    // Use context of rootState to get the parent node

    return Container(
      color: rootPage.navigationBarBackgroundColor,
      child: Padding(
        padding: EdgeInsets.all(rootPage.navigationBarPadding),
        child: Row(
          children: [
            if (showBackButton)
              MouseRegion(
                key: ValueKey('GgNavigationPageBackButton'),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTapUp: (_) => ownNode.navigateTo('../'),
                  child: rootPage.navigationBarBackButton?.call(context) ??
                      Text('Back'),
                ),
              ),
            Spacer(),
            Container(
              key: ValueKey('GgNavigationPageTitle'),
              child: rootPage.navigationBarTitle?.call(context) ??
                  Text(
                    ownNode.semanticLabel,
                  ),
            ),
            Spacer(),
            MouseRegion(
              key: ValueKey('GgNavigationPageCloseButton'),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapUp: (_) => rootNode.navigateTo('../'),
                child: rootPage.navigationBarCloseButton?.call(context) ??
                    Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
