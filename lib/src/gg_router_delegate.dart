// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gg_once_per_cycle/gg_once_per_cycle.dart';
import 'package:gg_router/gg_router.dart';

import 'gg_route_tree_node.dart';

/// This [RouterDelegate] applies changes of the route tree to the application's
/// URI and applies the application's URI to the route tree. Assign an instance
/// of this delegate to a [Router]'s or [MaterialApp]'s routerDelegate.
///
/// ```
/// MaterialApp.router(
///   title: "GgRouterExample",
///   routerDelegate: GgRouterDelegate(child: ...),
///   routeInformationParser: GgRouteInformationParser(),
/// );
/// ```
class GgRouterDelegate extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  // ...........................................................................
  /// The constructor.
  GgRouterDelegate({
    required this.child,
    this.saveState,
    this.restoreState,
    this.defaultRoute,
    GgRouteTreeNode? root,
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    _initRoot(root);
    _restoreState();
    _initSaveStateTrigger();
    _listenToChanges();
  }

  // ...........................................................................
  /// Call this function if the delegate is not needed anymore.
  @override
  void dispose() {
    _dispose.reversed.forEach((element) => element());
    super.dispose();
  }

  // ...........................................................................
  /// The navigator key needed by [PopNavigatorRouterDelegateMixin].
  final GlobalKey<NavigatorState> navigatorKey;

  // ...........................................................................
  /// The child containing the routes which will build the route node tree.
  Widget child;

  // ...........................................................................
  /// Returns the root router node
  GgRouteTreeNode get root => _root;

  // ...........................................................................
  /// Set [saveState] to make the last state of the app automatically be safed.
  void Function(String state)? saveState;

  // ...........................................................................
  /// Set [restoreState] to make the last state of the app being restored.
  Future<String?> Function()? restoreState;

  // ...........................................................................
  /// The default route loaded on beginning. The default route is ignored when
  /// a root node is specified in the constructor AND the root has already a
  /// staged child.
  final String? defaultRoute;

  // ...........................................................................
  /// Builds the widget tree.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _restoreIsDone.future,
      builder: (context, _) {
        if (!_restoreIsDone.isCompleted) {
          return Container(key: ValueKey('RouterDelegateLoadingScreen'));
        }

        return Semantics(
          container: true,
          explicitChildNodes: true,
          child: GgRouter.root(
            child: Overlay(
              initialEntries: [
                OverlayEntry(builder: (context) {
                  return child;
                }),
              ],
            ),
            node: _root,
          ),
        );
      },
    );
  }

  // ...........................................................................
  @override
  RouteInformation get currentConfiguration {
    Map<String, dynamic> queryParameters = {};
    _root.stagedParams.values.forEach((param) {
      queryParameters[param.name!] = param.value.toString();
    });

    final uri = Uri(
      pathSegments: _root.stagedChildPathSegments
          .where((element) => element != '_INDEX_'),
      queryParameters: queryParameters.length > 0 ? queryParameters : null,
    );

    return RouteInformation(
      location: uri.toString(),
    );
  }

  // ...........................................................................
  @override
  Future<void> setInitialRoutePath(RouteInformation configuration) async {
    // Wait until restore is ready
    await _restoreIsDone.future;

    // Check if URI needs navigation
    bool needsNavigate = configuration.location != null
        ? Uri.parse(configuration.location!).pathSegments.length > 0
        : false;

    // If yes, navigate
    if (needsNavigate) {
      super.setInitialRoutePath(configuration);
    }
  }

  // ...........................................................................
  @override
  Future<void> setNewRoutePath(RouteInformation route) {
    if (route.location != null) {
      late Uri uri;
      try {
        uri = Uri.parse(route.location!);
      } catch (e) {
        print('Error while parsing url ${route.location}');
        return SynchronousFuture(null);
      }

      _root.stagedChildPathSegments = uri.pathSegments;
      final Map<String, String> uriParams = {};

      if (uri.hasQuery) {
        final stagedParams = _root.stagedParams;
        uri.queryParameters.forEach((key, value) {
          if (stagedParams.containsKey(key)) {
            stagedParams[key]!.stringValue = value;
          } else {
            uriParams[key] = value;
          }
        });
      }

      _root.uriParams = uriParams;
    }

    return SynchronousFuture(null);
  }

  // ######################
  // Private
  // ######################

  // ...........................................................................
  final List<Function()> _dispose = [];
  late GgRouteTreeNode _root;
  _initRoot(GgRouteTreeNode? root) {
    _root = root ?? GgRouteTreeNode(name: '_ROOT_');

    if (_root.stagedChild == null && this.defaultRoute != null) {
      _root.navigateTo(this.defaultRoute!);
    }
  }

  // ...........................................................................
  _listenToChanges() {
    final s = _root.onChange.listen((event) {
      notifyListeners();
      _saveStateTrigger.trigger();
    });

    _dispose.add(s.cancel);
  }

  // ...........................................................................
  final _restoreIsDone = Completer();

  // ...........................................................................
  _restoreState() {
    if (restoreState == null) {
      _restoreIsDone.complete();
      return;
    }

    restoreState!.call().then((json) {
      if (json != null) {
        _root.json = json;
      }
      _restoreIsDone.complete();
    });
  }

  // ...........................................................................
  late GgOncePerCycle _saveStateTrigger;
  _initSaveStateTrigger() {
    _saveStateTrigger = GgOncePerCycle(task: () {
      final json = _root.json;
      saveState?.call(json);
    });
  }
}
