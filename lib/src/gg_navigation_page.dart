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
  }) : super(key: key) {
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
  bool get isRoot => widget is GgNavigationPageRoot;

  // ...........................................................................
  _generateChildren(BuildContext context) {
    final result = Map<String, Widget Function(BuildContext)>();

    result['_INDEX_'] = (context) {
      final content = widget.pageContent(context);
      if (content is GgNavigationPage) {
        throw ArgumentError(
            GgNavigationPage.indexWidgetMustNotBeANavigationPage);
      }
      return GgPageWithNavBar(content: content);
    };

    if (widget.children != null) {
      result.addAll(widget.children!);
    }

    return result;
  }
}

// ######################
// GgNavigationPageRoot
// ######################

class GgNavigationPageRoot extends StatefulWidget {
  GgNavigationPageRoot({
    Key? key,
    required Widget Function(BuildContext) pageContent,
    Map<String, GgNavigationPage Function(BuildContext)>? children,
    Map<String, String> semanticLabels = const {},
    this.inAnimation,
    this.outAnimation,
    this.animationDuration = const Duration(milliseconds: 500),
  })  : navigationPage = GgNavigationPage(
            pageContent: pageContent,
            children: children,
            semanticLabels: semanticLabels),
        super(key: key);

  final GgNavigationPage navigationPage;

  @override
  GgNavigationPageRootState createState() => GgNavigationPageRootState();

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
  const GgPageWithNavBar({Key? key, required this.content}) : super(key: key);

  final Widget content;

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

    assert(rootState != null);
    assert(rootState?.context != null);
    final rootNode = GgRouter.of(rootState!.context).node;
    final ownNode = GgRouter.of(context).node;

    // Use context of rootState to get the parent node

    return Row(
      children: [
        Container(
          key: ValueKey('GgNavigationPageBackButton'),
          child: TextButton(
            onPressed: () {
              ownNode.navigateTo('../');
            },
            child: Text('Back'),
          ),
        ),
        Spacer(),
        Container(
          key: ValueKey('GgNavigationPageTitle'),
          child: Text(
            ownNode.semanticLabel,
          ),
        ),
        Spacer(),
        Container(
          key: ValueKey('GgNavigationPageCloseButton'),
          child: TextButton(
            onPressed: () {
              rootNode.navigateTo('../');
            },
            child: Text('Close'),
          ),
        ),
      ],
    );
  }
}
