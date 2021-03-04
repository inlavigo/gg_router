// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';
import 'package:gg_value/gg_value.dart';
import 'package:flutter/foundation.dart';

/// RouteNode represents a node in a route tree.
class GgRouterNode {
  // ########################
  // Constructor & Destructor
  // ########################

  GgRouterNode({
    required this.name,
    this.parent,
  }) {
    _initParent();
    _initPath();
    _initChildren();
    _initIsActive();
    _initActiveChild();
    _initActiveDescendands();
  }

  // ...........................................................................
  /// Call this function when the node is about to be disposed.
  dispose() => _dispose.reversed.forEach((d) => d());

  // ...........................................................................
  @override
  String toString() {
    return pathString;
  }

  // ############################
  // Name & Parent & Index & Root
  // ############################

  // ...........................................................................
  /// The name of the node. The name will appear as path segment in the URI.
  final String name;

  // ...........................................................................
  /// The parent node.
  final GgRouterNode? parent;

  // ...........................................................................
  GgRouterNode get root {
    var result = this;
    while (result.parent != null) {
      result = result.parent!;
    }

    return result;
  }

  // ...........................................................................
  bool get isRoot => parent == null;

  // ...........................................................................
  /// Returns the index in the paren'ts children array.
  int get index => parent?._children.keys.toList().indexOf(name) ?? 0;

  // ######################
  // isActive
  // ######################

  // ...........................................................................
  /// Marks this node as active or inactive.
  ///
  /// - [isActive] = true: Also the parent nodes are set to active.
  /// - [isActive] = false: Also all child nodes are set to inactive.
  set isActive(bool isActive) {
    if (_isActive.value == isActive) {
      return;
    }

    _isActive.value = isActive;

    // Mark also ancestors to be active
    if (isActive) {
      parent?._childBecameActive(this);
    }
    // Mark also children to be inactive
    else {
      _children.values.forEach((child) => child.isActive = false);
      parent?._childBecameInactive(this);
    }
  }

  // ...........................................................................
  /// Returns true if this node is active.
  bool get isActive => _isActive.value;

  // ...........................................................................
  /// Returns a stream informing when isActive changes.
  Stream<bool> get onIsActive => _isActive.stream;

  // ######################
  // Children
  // ######################

  // ...........................................................................
  Iterable<GgRouterNode> get children => _children.values;

  // ...........................................................................
  /// Returns a child node with [name]. If none exists, one is created.
  GgRouterNode child({required String name}) {
    var child = _children[name];
    if (child == null) {
      child = GgRouterNode(name: name, parent: this);
      _children[name] = child;
    }
    return child;
  }

  // ...........................................................................
  /// Returns true, if node has child with name
  bool hasChild({required String name}) {
    return _children.containsKey(name);
  }

  // ...........................................................................
  /// Removes the child
  void removeChild(GgRouterNode child) {
    final a = _children[child.name];
    final b = child;

    if (identical(_children[child.name], child)) {
      child.dispose();
    } else {
      throw ArgumentError(
          'The child to be remove is not a child of this node.');
    }
  }

  // ...........................................................................
  /// Returns descendand that matches the path. Creates the node when needed.
  /// - `.` addresses node itself
  /// - `..` addresses parent node
  /// - '_LAST_' - addresses child that was last active
  GgRouterNode descendand({required List<String> path}) {
    var result = this;
    path.forEach((element) {
      if (element == '.' || element == '') {
        result = result;
      } else if (element == '..') {
        if (result.parent == null) {
          throw ArgumentError('Invalid path "${path.join('/')}"');
        }
        result = result.parent!;
      } else if (element == '_LAST_') {
        GgRouterNode? previousActiveChild =
            result._currentOrPreviouslyActiveChild;

        if (path.last == element) {
          while (previousActiveChild?._currentOrPreviouslyActiveChild != null) {
            previousActiveChild =
                previousActiveChild!._currentOrPreviouslyActiveChild;
          }
        }

        result = previousActiveChild ?? result;
      } else {
        result = result.child(name: element);
      }
    });

    return result;
  }

  // ######################
  // Active child
  // ######################

  // ...........................................................................
  /// Returns the active child or null, if no child is active.
  GgRouterNode? get activeChild => _activeChild.value;

  // ...........................................................................
  /// Informs if the active child did change.
  Stream<GgRouterNode?> get activeChildDidChange => _activeChild.stream;

  // ...........................................................................
  GgRouterNode? get previousActiveChild => _previousActiveChild;

  // ######################
  // Active Descendands
  // ######################

  // ...........................................................................
  /// Returns a list containing all active descendands.
  List<GgRouterNode> get activeDescendands {
    GgRouterNode? activeChild = _activeChild.value;

    final List<GgRouterNode> result = [];
    while (activeChild != null) {
      result.add(activeChild);
      activeChild = activeChild.activeChild;
    }

    return result;
  }

  // ...........................................................................
  /// A stream informing when the active descendands change.
  Stream<List<GgRouterNode>> get activeDescendandsDidChange =>
      _activeDescendands.stream;

  // ######################
  // Path
  // ######################

  // ...........................................................................
  /// Returns the own path until root
  late List<String> path;

  // ...........................................................................
  late String pathString;

  // ...........................................................................
  /// Returns the hash of the own path
  late int pathHashCode;

  // ######################
  // Navigation
  // ######################

  // ...........................................................................
  /// Returns the path of active children.
  List<String> get activeChildPath =>
      activeDescendands.map((e) => e.name).toList();

  // ...........................................................................
  /// Creates and activates children according to the segments in [path]
  /// - `..` addresses parent node
  /// - `.` addresses node itself
  set activeChildPath(List<String> path) {
    final node = descendand(path: path);
    node.isActive = true;

    node.activeChild?.isActive = false;

    if (path.isEmpty) {
      activeChild?.isActive = false;
    }
  }

  // ...........................................................................
  String get activeChildPathString => activeChildPath.join('/');

  // ...........................................................................
  /// Activates the path in the node hierarchy.
  /// - [path] can be absolute, e.g. `/a/b/c`
  /// - [path] can be relative, e.g. `b/c` or `./b/c`
  /// - [path] can address parent element, e.g. `../`
  /// - [path] can address root, e.g. `/`
  void navigateTo(String path) => _navigateTo(path);

  // ######################
  // Private
  // ######################

  final List<Function()> _dispose = [];

  // ########
  // parent
  _initParent() {
    if (parent == null) {
      if (name != '') {
        throw ArgumentError(
          'This node is a root node because parent is null. '
          'Root notes must have an empty name, .e. ""',
        );
      }
    }
    parent?._children[name] = this;
  }

  // ...........................................................................
  _initPath() {
    path = parent == null
        ? []
        : [
            ...parent!.path,
            if (name.isNotEmpty) name,
          ];
    pathString = '/' + path.join('/');
    pathHashCode = pathString.hashCode;
  }

  // ########
  // children

  // ...........................................................................
  /// Returns a list with the node's children.
  final _children = Map<String, GgRouterNode>();
  _initChildren() {
    _dispose.add(() {
      List.from(_children.values).forEach((child) {
        child.dispose();
      });
      parent?._removeChild(this);
    });
  }

  // ...........................................................................
  _removeChild(child) {
    _children.remove(child.name);
  }

  // ########
  // isActive

  // ...........................................................................
  final _isActive = GgValue(seed: false);

  // ...........................................................................
  _initIsActive() {
    _dispose.add(() {
      if (isActive) {
        isActive = false;
      }
    });
    _dispose.add(() => _isActive.dispose());
  }

  // ###########
  // activeChild
  // ...........................................................................
  final _activeChild = GgValue<GgRouterNode?>(seed: null);
  GgRouterNode? _previousActiveChild;

  GgRouterNode? get _currentOrPreviouslyActiveChild =>
      _activeChild.value ?? _previousActiveChild;

  _initActiveChild() {
    _dispose.add(() => _activeChild.dispose());
  }

  // ...........................................................................
  _childBecameActive(GgRouterNode child) {
    if (_activeChild.value == child) {
      return;
    }

    _previousActiveChild = _activeChild.value ?? _previousActiveChild;

    isActive = true;
    _activeChild.value?.isActive = false;
    _activeChild.value = child;

    _updateActiveDescendands();
  }

  // ...........................................................................
  _childBecameInactive(GgRouterNode child) {
    if (_activeChild.value != child) {
      return;
    }
    _previousActiveChild = _activeChild.value ?? _previousActiveChild;
    _activeChild.value = null;
    _updateActiveDescendands();
  }

  // #################
  // activeDescendands

  // ...........................................................................
  final _activeDescendands =
      GgValue<List<GgRouterNode>>(seed: [], compare: listEquals);

  _initActiveDescendands() {
    _dispose.add(() => _activeDescendands.dispose());
  }

  _updateActiveDescendands() {
    _activeDescendands.value = activeDescendands;
    parent?._updateActiveDescendands();
  }

  // ################
  // navigate
  _navigateTo(String path) {
    final startElement = path.startsWith('/') ? root : this;
    final pathComponents = path.split('/');
    startElement.activeChildPath = pathComponents;
  }
}

// #############################################################################
/// Creates an lite route sample node.
final exampleRouteNode = ({
  String? name,
  GgRouterNode? parent,
}) =>
    GgRouterNode(
      name: name ?? 'node',
      parent: parent,
    );
