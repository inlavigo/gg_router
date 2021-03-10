// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';
import 'package:gg_value/gg_value.dart';
import 'package:flutter/foundation.dart';
import 'package:gg_once_per_cycle/gg_once_per_cycle.dart';
import 'dart:async' show Stream;

// #############################################################################
/// An error that is reported when a URI cannot be assigned to a route path
class GgRouteTreeNodeError extends Error {
  // ...........................................................................
  GgRouteTreeNodeError({
    required this.id,
    required this.message,
    this.node,
  });

  // ...........................................................................
  final String message;
  final String id;
  final GgRouteTreeNode? node;

  // ...........................................................................
  GgRouteTreeNodeError withNode(GgRouteTreeNode node) {
    return GgRouteTreeNodeError(id: id, message: message, node: node);
  }
}

// #############################################################################
/// Internal management of route parameters
class _Params {
  _Params() {
    _initParams();
    _initOnChange();
    _initOnChangeTrigger();
  }

  // ...........................................................................
  GgValue<T> findOrCreateParam<T>({
    required GgRouteTreeNode parent,
    required T seed,
    required String? uriParam,
    required String name,
    bool spam = false,
  }) {
    var result = _params[name];
    if (result == null) {
      result = GgValue<T>(
        seed: seed,
        name: name,
        spam: spam,
      );

      if (uriParam != null) {
        try {
          result.stringValue = uriParam;
        } catch (e) {
          print('Was not write uriParam $uriParam to param $name');
        }
      }

      _listenToChanges(result.stream);

      _params[name] = result;
    } else {
      _checkType<T>(result);
    }

    return result as GgValue<T>;
  }

  // ...........................................................................
  dispose() {
    _dispose.reversed.forEach((element) => element());
  }

  // ...........................................................................
  /// Returns own param
  GgValue<T>? param<T>(String name) {
    final result = _params[name];
    if (result != null) {
      _checkType<T>(result);
    }

    return _params[name] as GgValue<T>?;
  }

  // ...........................................................................
  bool hasParam(String name) => _params.keys.contains(name);

  // ...........................................................................
  Stream<void> get onChange => _onChange.stream;

  // ...........................................................................
  final List<Function()> _dispose = [];
  _initParams() {
    _dispose.add(() {
      _params.values.forEach(
        (element) {
          element.dispose();
        },
      );
      _params.clear();
    });
  }

  // ...........................................................................
  _checkType<T>(GgValue param) {
    if (!(param is GgValue<T>)) {
      throw ArgumentError(
        'Error while retrieving param with name "${param.name}". '
        'The existing param has type "${param.value.runtimeType.toString()}" and not "${T.toString()}".',
      );
    }
  }

  // ...........................................................................
  final _params = Map<String, GgValue>();

  // ...........................................................................
  final _onChange = StreamController<void>.broadcast();
  _initOnChange() {
    _dispose.add(() => _onChange.close());
  }

  // ...........................................................................
  _listenToChanges(Stream stream) {
    final s = stream.listen((_) => _onChangeTrigger.trigger());
    _onChangeTrigger.trigger();
    _dispose.add(s.cancel);
  }

  // ...........................................................................
  late GgOncePerCycle _onChangeTrigger;
  _initOnChangeTrigger() {
    _onChangeTrigger = GgOncePerCycle(task: () {
      if (!_onChange.isClosed && _onChange.hasListener) {
        _onChange.add(null);
      }
    });
  }
}

// #############################################################################
/// GgRouteTreeNode represents a node in a route tree.
class GgRouteTreeNode {
  // ########################
  // Constructor & Destructor
  // ########################

  /// The node's constructor.
  GgRouteTreeNode({
    required this.name,
    this.parent,
  }) {
    _initParent();
    _initParams();
    _initPath();
    _initChildren();
    _initIsActive();
    _initActiveChild();
    _initActiveDescendants();
    _initOwnOrChildParamChange();
    _initSubscriptions();
  }

  // ...........................................................................
  /// Call this function when the node is about to be disposed.
  dispose() => _dispose.reversed.forEach((d) => d());

  // ...........................................................................
  /// A string representation of the node outputting the path of the node.
  @override
  String toString() {
    return path;
  }

  // ############################
  // Name & Parent & Index & Root
  // ############################

  // ...........................................................................
  /// The name of the node. The name will appear as path segment in the URI.
  final String name;

  // ...........................................................................
  /// The parent node.
  final GgRouteTreeNode? parent;

  // ...........................................................................
  ///  The root parent of this node or the node itself, when it is a node.
  GgRouteTreeNode get root {
    var result = this;
    while (result.parent != null) {
      result = result.parent!;
    }

    return result;
  }

  // ...........................................................................
  /// Returns true, if this node is root.
  bool get isRoot => parent == null;

  // ...........................................................................
  /// Returns the index in the parent's children array.
  int get index => parent?._children.keys.toList().indexOf(name) ?? 0;

  // ######################
  // isActive
  // ######################

  // ...........................................................................
  /// Marks this node as active or inactive.
  ///
  /// - [isActive] = true: Also the parent nodes are set to active.
  /// - [isActive] = false: Also all child nodes are set to inactive.
  /// - At a time only one path in the tree can be cative.
  set isActive(bool isActive) {
    if (_isActive.value == isActive) {
      return;
    }

    _isActive.value = isActive;

    // Mark also ancestors to be active
    if (isActive) {
      _previousActiveChild?.isActive = true;
      parent?._childBecameActive(this);
    }
    // Mark also children to be inactive
    else {
      _previousActiveChild = _activeChild.value;
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
  /// Returns the node's children.
  Iterable<GgRouteTreeNode> get children => _children.values;

  // ...........................................................................
  /// Returns a child node with [name]. If none exists, one is created.
  GgRouteTreeNode child({required String name}) {
    var child = _children[name];
    if (child == null) {
      child = GgRouteTreeNode(name: name, parent: this);
      _children[name] = child;
    }
    return child;
  }

  // ...........................................................................
  /// Returns true if the node has a child with [name].
  bool hasChild({required String name}) {
    return _children.containsKey(name);
  }

  // ...........................................................................
  /// Removes the [child].
  void removeChild(GgRouteTreeNode child) {
    if (identical(_children[child.name], child)) {
      _unlistenNode(child);
      child.dispose();
    } else {
      throw ArgumentError(
          'The child to be remove is not a child of this node.');
    }
  }

  // ...........................................................................
  /// Returns descendant that matches the path. Creates the node when needed.
  /// - `.` addresses node itself
  /// - `..` addresses parent node
  /// - '_LAST_' - addresses child that was last active
  GgRouteTreeNode descendand({required List<String> path}) {
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
        GgRouteTreeNode? previousActiveChild =
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
  /// Returns the active child or null if no child is active.
  GgRouteTreeNode? get activeChild => _activeChild.value;

  // ...........................................................................
  /// Informs if the active child did change.
  Stream<GgRouteTreeNode?> get activeChildDidChange => _activeChild.stream;

  // ...........................................................................
  /// Returns the child that was previously active.
  GgRouteTreeNode? get previousActiveChild => _previousActiveChild;

  // ######################
  // Active Descendants
  // ######################

  // ...........................................................................
  /// Returns a list containing all active descendants.
  List<GgRouteTreeNode> get activeDescendants {
    GgRouteTreeNode? activeChild = _activeChild.value;

    final List<GgRouteTreeNode> result = [];
    while (activeChild != null) {
      result.add(activeChild);
      activeChild = activeChild.activeChild;
    }

    return result;
  }

  // ...........................................................................
  /// A stream that informs when the active descendants change.
  Stream<List<GgRouteTreeNode>> get activeDescendantsDidChange =>
      _activeDescendants.stream;

  // ######################
  // Params
  // ######################

  // ...........................................................................
  /// Finds or route param with [name].
  /// If no param exists, one is created and initialized with [seed].
  GgValue<T> findOrCreateParam<T>({required String name, required T seed}) {
    final es = uriParamForName(name);

    if (es != null) {
      _removeUriParamForParam(name);
    }

    var result = _params.findOrCreateParam<T>(
        parent: this, seed: seed, uriParam: es, name: name);

    return result;
  }

  // ...........................................................................
  /// Returns the parameter with [name] or [null] if no parameter with name exists.
  GgValue<T>? param<T>(String name) => _params.param(name);

  // ...........................................................................
  /// Returns the param from this node or its parents.
  GgValue<T>? ownOrParentParam<T>(String name) {
    GgValue<T>? result;
    GgRouteTreeNode? node = this;
    while (node != null && result == null) {
      result = node.param<T>(name);
      node = node.parent;
    }

    return result;
  }

  // ...........................................................................
  /// Returns all parameters of the active path.
  Map<String, GgValue> get activeParams {
    Map<String, GgValue> result = {};
    GgRouteTreeNode? node = this;
    while (node != null) {
      result.addAll(node._params._params);
      node = node.activeChild;
    }

    return result;
  }

  // ...........................................................................
  /// Returns true if param with [name] exists, otherwise [false] is returned.
  bool hasParam(String name) => _params.hasParam(name);

  // ...........................................................................
  /// A stream that informs when the node's parameters change.
  Stream<void> get onOwnParamChange => _params.onChange;

  // ...........................................................................
  /// A stream that informs when the node's own or its child parameters change.
  Stream<void> get onOwnOrChildParamChange => _ownOrChildParamChange.stream;

  // ######################
  // Path
  // ######################

  // ...........................................................................
  /// Returns the path of this node as a list of segments.
  late List<String> pathSegments;

  // ...........................................................................
  /// Returns the path of this node as a string.
  late String path;

  // ...........................................................................
  /// Returns the hash of the own path.
  late int pathHashCode;

  // ######################
  // Navigation
  // ######################

  // ...........................................................................
  /// Returns the path of active children as a list of path segments.
  List<String> get activeChildPathSegments =>
      activeDescendants.map((e) => e.name).toList();

  // ...........................................................................
  /// Creates and activates children according to the segments in [path]
  /// - `..` addresses parent node
  /// - `.` addresses node itself
  set activeChildPathSegments(List<String> path) {
    final node = descendand(path: path);
    node.isActive = true;

    node.activeChild?.isActive = false;

    if (path.isEmpty) {
      activeChild?.isActive = false;
    }
  }

  // ...........................................................................
  String get activeChildPath => activeChildPathSegments.join('/');

  // ...........................................................................
  /// Activates the path in the node hierarchy.
  /// - [path] can be absolute, e.g. `/a/b/c`
  /// - [path] can be relative, e.g. `b/c` or `./b/c`
  /// - [path] can address parent element, e.g. `../`
  /// - [path] can address root, e.g. `/`
  void navigateTo(String path) => _navigateTo(path);

  // ######################
  // Uri parameters
  // ######################

  /// Use [uriParams] to apply parameters taken from a URI to the active tree.
  /// These parameters are used to initialize node parameters.
  Map<String, String> uriParams = {};

  // ...........................................................................
  /// Returns the URI parameter for a given parameter [name].
  /// Returns [null], if no URI parameter exists for that name.
  String? uriParamForName(String name) {
    GgRouteTreeNode? node = this;
    String? seed;
    while (node != null && seed == null) {
      seed = node.uriParams[name];
      node = node.parent;
    }

    return seed;
  }

  // ######################
  // Error Handling
  // ######################

  // ...........................................................................
  /// Handle error or propagate it up the tree.
  void setError(GgRouteTreeNodeError error) {
    final err = error.node == null ? error.withNode(this) : error;
    _errorHandler?.call(err);
    if (_errorHandler == null) {
      if (parent != null) {
        parent?.setError(err);
      } else {
        throw Exception(
          'Please set an error handler using "node.errorHandler = ...", to capture routing errors.',
        );
      }
    }
  }

  // ...........................................................................
  /// Set an [errorHandler] which informs about errors. E.g., if a URI cannot be
  /// applied to the node tree, this error handler will be called.
  /// You can set an error handler only one time.
  set errorHandler(void Function(GgRouteTreeNodeError)? errorHandler) {
    if (errorHandler != null && _errorHandler != null) {
      throw ArgumentError(
          'This node already has an error handler. Please remove previous error handler.');
    }

    _errorHandler = errorHandler;
  }

  // ...........................................................................
  /// Returns the error handler.
  void Function(GgRouteTreeNodeError)? get errorHandler => _errorHandler;

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
    parent?._listenToNode(this);
  }

  // ...........................................................................
  _initPath() {
    pathSegments = parent == null
        ? []
        : [
            ...parent!.pathSegments,
            if (name.isNotEmpty) name,
          ];
    path = '/' + pathSegments.join('/');
    pathHashCode = path.hashCode;
  }

  // ########
  // children

  // ...........................................................................
  /// Returns a list with the node's children.
  final _children = Map<String, GgRouteTreeNode>();
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
  // params

  // ...........................................................................
  final _params = _Params();
  _initParams() {
    _dispose.add(() => _params.dispose());
  }

  // ...........................................................................
  final _ownOrChildParamChange = StreamController<void>.broadcast();
  late GgOncePerCycle _triggerOwnOrChildParamChange;

  _initOwnOrChildParamChange() {
    _dispose.add(() => _ownOrChildParamChange.close());

    _triggerOwnOrChildParamChange = GgOncePerCycle(task: () {
      if (!_ownOrChildParamChange.isClosed &&
          _ownOrChildParamChange.hasListener) {
        _ownOrChildParamChange.add(null);
      }
    });

    final s =
        onOwnParamChange.listen((_) => _triggerOwnOrChildParamChange.trigger());
    _dispose.add(() => s.cancel);
  }

  // ...........................................................................
  Map<GgRouteTreeNode, StreamSubscription> _subscriptions = {};
  _initSubscriptions() {
    _subscriptions.values.forEach((element) => element.cancel);
  }

  // ...........................................................................
  _listenToNode(GgRouteTreeNode node) {
    _subscriptions[node] = node.onOwnOrChildParamChange
        .listen((event) => _triggerOwnOrChildParamChange.trigger());
  }

  // ...........................................................................
  _unlistenNode(GgRouteTreeNode node) {
    _subscriptions[node]!.cancel();
    _subscriptions.remove(node);
  }

  // # URI Params

  // ...........................................................................
  String? _removeUriParamForParam(String name) {
    // Early seed is only used the first time
    GgRouteTreeNode? node = this;
    String? seed;
    while (node != null && seed == null) {
      if (node.uriParams.containsKey(name)) {
        node.uriParams.remove(name);
      }
      seed = node.uriParams[name];
      node = node.parent;
    }

    return seed;
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
  final _activeChild = GgValue<GgRouteTreeNode?>(seed: null);
  GgRouteTreeNode? _previousActiveChild;

  GgRouteTreeNode? get _currentOrPreviouslyActiveChild =>
      _activeChild.value ?? _previousActiveChild;

  _initActiveChild() {
    _dispose.add(() => _activeChild.dispose());
  }

  // ...........................................................................
  _childBecameActive(GgRouteTreeNode child) {
    if (_activeChild.value == child) {
      return;
    }

    _previousActiveChild = _activeChild.value ?? _previousActiveChild;

    isActive = true;
    _activeChild.value?.isActive = false;
    _activeChild.value = child;

    _updateActiveDescendants();
  }

  // ...........................................................................
  _childBecameInactive(GgRouteTreeNode child) {
    if (_activeChild.value != child) {
      return;
    }
    _previousActiveChild = _activeChild.value ?? _previousActiveChild;
    _activeChild.value = null;
    _updateActiveDescendants();
  }

  // #################
  // activeDescendants

  // ...........................................................................
  final _activeDescendants =
      GgValue<List<GgRouteTreeNode>>(seed: [], compare: listEquals);

  _initActiveDescendants() {
    _dispose.add(() => _activeDescendants.dispose());
  }

  _updateActiveDescendants() {
    _activeDescendants.value = activeDescendants;
    parent?._updateActiveDescendants();
  }

  // ################
  // navigate
  _navigateTo(String path) {
    final startElement = path.startsWith('/') ? root : this;
    final pathComponents = path.split('/');
    startElement.activeChildPathSegments = pathComponents;
  }

  // ##############
  // Error handling

  Function(GgRouteTreeNodeError)? _errorHandler;
}

// #############################################################################
/// Creates an lite route sample node.
final exampleRouteNode = ({
  String? name,
  GgRouteTreeNode? parent,
}) =>
    GgRouteTreeNode(
      name: name ?? '',
      parent: parent,
    );
