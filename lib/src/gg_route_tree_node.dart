// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';
import 'dart:convert';
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

  // ...........................................................................
  @override
  toString() => 'Error $id: $message';
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
    required dynamic? uriParam,
    required String name,
    bool spam = false,
    T Function(String)? parse,
    String Function(T)? stringify,
  }) {
    var result = _params[name];
    if (result == null) {
      result = GgValue<T>(
        seed: seed,
        name: name,
        spam: spam,
        stringify: stringify,
        parse: parse,
      );

      if (uriParam != null) {
        try {
          if (uriParam is String) {
            result.stringValue = uriParam;
          } else {
            result.value = uriParam;
          }
        } catch (e) {
          print('Was not able to write uriParam $uriParam to param $name');
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
  /// Returns true when a param with [name] is available.
  bool hasParam(String name) => _params.keys.contains(name);

  // ...........................................................................
  /// A stream that informs if any of the parameter changes
  Stream<void> get onOwnOrChildChange => _onOwnOrChildChange.stream;

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
  final _onOwnOrChildChange = StreamController<void>.broadcast();
  _initOnChange() {
    _dispose.add(() => _onOwnOrChildChange.close());
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
      if (!_onOwnOrChildChange.isClosed && _onOwnOrChildChange.hasListener) {
        _onOwnOrChildChange.add(null);
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
    _checkConsistency();
    _initOnChange();
    _initParent();
    _initParams();
    _initPath();
    _initChildren();
    _initIsStaged();
    _initStagedChild();
    _initStagedDescendants();
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

  /// ..........................................................................
  /// Returns true if name only contains letters, numbers, minus and underscore
  static bool isValidName(String name) {
    return _nameRegEx.allMatches(name).length > 0;
  }

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
  int? widgetIndex;
  // ############################
  // onChange
  // ############################

  Stream<void> get onChange => _onChange.stream;

  // ######################
  // isStaged
  // ######################

  // ...........................................................................
  /// Returns true if this node is staged.
  bool get isStaged => _isStaged.value;

  /// ...........................................................................
  /// Sets back staging for the node and it's children
  void resetStaging({bool recursive = false}) {
    _setIsStaged(false);
    if (recursive) {
      children.forEach((child) => child.resetStaging(recursive: recursive));
    }
  }

  // ######################
  // Children
  // ######################

  // ...........................................................................
  /// Returns the node's children.
  Iterable<GgRouteTreeNode> get children => _children.values;

  // ...........................................................................
  /// Returns a child node with [name]. If none exists, one is created.
  GgRouteTreeNode child(String name) {
    if (isIndexChild) {
      throw ArgumentError(
          'The route "$path" is an index routes and must not have children.');
    }

    var child = _children[name];
    if (child == null) {
      child = GgRouteTreeNode(name: name, parent: this);
      _children[name] = child;
      _reportChange();
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
      _reportChange();
    } else {
      throw ArgumentError(
          'The child to be remove is not a child of this node.');
    }
  }

  // ...........................................................................
  bool get isIndexChild => name == '_INDEX_';

  // ...........................................................................
  /// Returns descendant that matches the path. Creates the node when needed.
  /// - `.` addresses node itself
  /// - `..` addresses parent node
  /// - '_LAST_' - addresses child that was last staged
  GgRouteTreeNode descendants({required List<String> path}) {
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
        GgRouteTreeNode? stagedChild = result.stagedChild;

        while (stagedChild != null) {
          result = stagedChild;
          stagedChild = stagedChild.stagedChild;
        }
      } else {
        result = result.child(element);
      }
    });

    return result;
  }

  // ...........................................................................
  List<GgRouteTreeNode> get ancestors {
    List<GgRouteTreeNode> result = [];
    GgRouteTreeNode? node = this;
    while (node != null) {
      result.add(node);
      node = node.parent;
    }
    return result;
  }

  // ######################
  // Staged child
  // ######################

  // ...........................................................................
  /// Returns the staged child or null if no child is staged.
  GgRouteTreeNode? get stagedChild => _stagedChild.value;

  // ...........................................................................
  /// Informs if the staged child did change.
  Stream<GgRouteTreeNode?> get stagedChildDidChange => _stagedChild.stream;

  // ######################
  // Visible Route
  // ######################

  // ...........................................................................
  /// Returns a list containing all staged descendants.
  List<GgRouteTreeNode> get visibleRoute {
    GgRouteTreeNode? stagedChild = _stagedChild.value;

    final List<GgRouteTreeNode> result = [];
    while (stagedChild != null) {
      result.add(stagedChild);
      stagedChild = stagedChild.stagedChild;
    }

    return result;
  }

  // ######################
  // Fade in and out
  // ######################

  // ...........................................................................
  /// Returns true if this node needs to be faded in when staged
  /// or faded out when not staged. The value is reset by GgRouterWidget
  /// after the node has been faded in or out.
  bool needsFade = false;

  // ...........................................................................
  /// Returns the child that needs to be faded in
  GgRouteTreeNode? get childToBeFadedIn {
    GgRouteTreeNode? result;
    children.forEach((child) {
      if (child.needsFade && child.isStaged) {
        result = child;
      }
    });

    return result;
  }

  // ...........................................................................
  /// Returns the child that needs to be faded out
  GgRouteTreeNode? get childToBeFadedOut {
    GgRouteTreeNode? result;
    children.forEach((child) {
      if (child.needsFade && !child.isStaged) {
        result = child;
      }
    });

    return result;
  }

  // ...........................................................................
  /// Returns a stream informing when isStaged changes.
  Stream<bool> get onIsStaged => _isStaged.stream;

  // ######################
  // Params
  // ######################

  // ...........................................................................
  /// Finds or route param with [name].
  /// If no param exists, one is created and initialized with [seed].
  /// - [stringify] is used to convert the value of the parameter to string.
  /// - [parse] is used parse a string into the value
  GgValue<T> findOrCreateParam<T>({
    required String name,
    required T seed,
    T Function(String)? parse,
    String Function(T)? stringify,
  }) {
    final es = uriParamForName(name);

    if (hasChild(name: name)) {
      throw GgRouteTreeNodeError(
          id: 'GRC008478',
          message: 'Error: Cannot create param with name "$name". '
              'There is already a child node with the same name.');
    }

    if (es != null) {
      _removeUriParamForParam(name);
    }

    var result = _params.findOrCreateParam<T>(
      parent: this,
      seed: seed,
      uriParam: es,
      name: name,
      parse: parse,
      stringify: stringify,
    );

    return result;
  }

  // ...........................................................................
  /// Returns the parameter with [name] or null if no parameter with name exists.
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
  /// Returns all parameters of the staged path.
  Map<String, GgValue> get stagedParams {
    Map<String, GgValue> result = {};
    GgRouteTreeNode? node = this;
    while (node != null) {
      result.addAll(node._params._params);
      node = node.stagedChild;
    }

    return result;
  }

  // ...........................................................................
  /// Returns true if param with [name] exists, otherwise false is returned.
  bool hasParam(String name) => _params.hasParam(name);

  // ...........................................................................
  /// A stream that informs when the node's parameters change.
  Stream<void> get onOwnParamChange => _params.onOwnOrChildChange;

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
  /// Returns the path of staged children as a list of path segments.
  List<String> get stagedChildPathSegments =>
      visibleRoute.map((e) => e.name).toList();

  // ...........................................................................
  /// Creates and activates children according to the segments in [path]
  /// - `..` addresses parent node
  /// - `.` addresses node itself
  set stagedChildPathSegments(List<String> path) {
    final node = descendants(path: path);

    final nodesFromRoot = node.ancestors.reversed;

    bool nodeIsFaded = false;

    // For each element from root to node
    nodesFromRoot.forEach((node) {
      final needsFade = !nodeIsFaded && (node.isStaged == false);

      // Get new and old faded node
      final newNode = node;
      final oldNode = node.parent?._stagedChild.value;

      // If staging has not changed, contine
      if (newNode == oldNode) {
        return;
      }

      // Set needsFade flag if this node is the first changed node
      if (needsFade) {
        newNode.needsFade = true;
        oldNode?.needsFade = true;
        nodeIsFaded = true;
      }

      // Stage the node
      newNode._setIsStaged(true);

      // Unstage the previous node
      oldNode?._setIsStaged(false);
    });

    // Reset staging for the node's children
    node.stagedChild?.resetStaging(recursive: false);
  }

  // ...........................................................................
  String get stagedChildPath => stagedChildPathSegments.join('/');

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

  /// Use [uriParams] to apply parameters taken from a URI to the staged tree.
  /// These parameters are used to initialize node parameters.
  Map<String, dynamic> uriParams = {};

  // ...........................................................................
  /// Returns the URI parameter for a given parameter [name].
  /// Returns null, if no URI parameter exists for that name.
  dynamic? uriParamForName(String name) {
    GgRouteTreeNode? node = this;
    dynamic? seed;
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
          '$err \n'
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
  // JSON handling
  // ######################

  // ...........................................................................
  /// This key is used to store the staged child name to JSON
  static const stagedChildJsonKey = '__stagedChild';

  // ...........................................................................
  /// Reads the JSON string and creates routes and  parameters. Parameters that
  /// are not still existing in the route tree are safed in the right nodes for
  /// later use.
  set json(String json) {
    late Object object;
    try {
      object = jsonDecode(json);
    } catch (e) {
      throw GgRouteTreeNodeError(
          id: 'GRC008475', message: 'Error while decoding JSON: $e');
    }

    _parseJson(object);
  }

  // ...........................................................................
  /// Converts the route tree into a JSON string
  String get json {
    final json = _generateJson();
    return jsonEncode(json);
  }

  // ######################
  // Private
  // ######################

  final List<Function()> _dispose = [];

  static final _nameRegEx = RegExp(
    r"^[\w\d_-]+$",
    caseSensitive: false,
    multiLine: false,
  );

  // ########
  // Checks
  _checkConsistency() {
    if (isRoot && name != '_ROOT_') {
      throw GgRouteTreeNodeError(
          id: 'GRC008501', message: 'Root nodes must have name "_ROOT_".');
    }

    if (name == '_ROOT_' && parent != null) {
      throw GgRouteTreeNodeError(
          id: 'GRC008503',
          message:
              'Nodes with name "_ROOT_" are root nodes and must not have a parent.');
    }

    if (!isValidName(name)) {
      throw GgRouteTreeNodeError(
          id: 'GRC008502',
          message:
              'The name "$name" is not a valid node name. Node names must only contain letters, numbers, underscore or minus.');
    }
  }

  // ########
  // parent
  _initParent() {
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

    // Inform about parameter changes
    final s = _params.onOwnOrChildChange.listen((event) => _reportChange());
    _dispose.add(s.cancel);
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
  // onChange

  // ...........................................................................
  final _onChange = StreamController.broadcast();
  late GgOncePerCycle _onChangeTrigger;

  // ...........................................................................
  _initOnChange() {
    _dispose.add(_onChange.close);
    _onChangeTrigger = GgOncePerCycle(task: () {
      if (_onChange.hasListener) {
        _onChange.add(null);
        parent?._reportChange();
      }
    });
  }

  // ...........................................................................
  _reportChange() {
    _onChangeTrigger.trigger();
    parent?._reportChange();
  }

  // ########
  // isStaged

  // ...........................................................................
  final _isStaged = GgValue(seed: false);

  // ...........................................................................
  _initIsStaged() {
    _dispose.add(() {
      if (isStaged) {
        _setIsStaged(false);
      }
    });
    _dispose.add(() => _isStaged.dispose());
  }

  // ...........................................................................
  _setIsStaged(bool b) {
    _isStaged.value = b;

    if (b && parent?._stagedChild.value != this) {
      parent?._stagedChild.value = this;
    } else if (!b && parent?._stagedChild.value == this) {
      parent?._stagedChild.value = null;
    }

    _reportChange();
  }

  // ###########
  // stagedChild
  // ...........................................................................
  final _stagedChild = GgValue<GgRouteTreeNode?>(seed: null);

  _initStagedChild() {
    _dispose.add(() {
      _stagedChild.dispose();

      if (parent?._stagedChild.value == this) {
        parent?._stagedChild.value = null;
      }
    });

    final s = _stagedChild.stream.listen((_) => _reportChange());
    _dispose.add(s.cancel);
  }

  // #################
  // stagedDescendants

  // ...........................................................................
  final _stagedDescendants = GgValue<List<GgRouteTreeNode>>(
    seed: [],
    compare: listEquals,
    spam: false,
  );

  _initStagedDescendants() {
    _dispose.add(() => _stagedDescendants.dispose());
  }

  // ################
  // navigate
  _navigateTo(String path) {
    final startElement = path.startsWith('/') ? root : this;
    final pathComponents = path.split('/');
    startElement.stagedChildPathSegments = pathComponents;
  }

  // ##############
  // Error handling

  Function(GgRouteTreeNodeError)? _errorHandler;

  // ##############
  // JSON handling

  // ...........................................................................
  void _parseJson(Object json) {
    if (json is Map) {
      final map = json as Map<String, dynamic>;
      map.forEach((key, value) {
        // ......................................
        // Read children.
        // If the value is a map, create a child.
        if (value is Map) {
          child(key)._parseJson(value);
        } else {
          // .................
          // Read staged child
          if (key == stagedChildJsonKey) {
            final childNode = child(value);
            childNode._setIsStaged(true);
            _stagedChild.value = childNode;
          }

          // ...........
          // Read params
          // If an param exists, parse the value into the param
          try {
            if (hasParam(key)) {
              if (value is num || value is bool) {
                param(key)!.value = value;
              } else {
                param(key)!.stringValue = value;
              }
            } else {
              uriParams[key] = value;
            }
          } catch (e) {
            throw GgRouteTreeNodeError(
                id: 'GRC008477',
                message:
                    'Error while parsing value "$value" for attribute with name "$key" on path "$path": $e');
          }
        }
      });
    } else {
      throw GgRouteTreeNodeError(
        id: 'GRC008476',
        message:
            'Error while reading JSON path "$path". Expected object of type Map, but got ${json.runtimeType}.',
        node: this,
      );
    }
  }

  // ...........................................................................
  Object _generateJson() {
    final result = Map();

    // Write staged child
    if (_stagedChild.value != null) {
      result[stagedChildJsonKey] = _stagedChild.value!.name;
    }

    // Write parameters
    _params._params.forEach((name, value) {
      result[name] = value.jsonDecodedValue;
    });

    // Write children
    _children.forEach((name, child) {
      result[name] = child._generateJson();
    });
    return result;
  }
}

// #############################################################################
/// Creates an lite route sample node.
final exampleRouteNode = ({
  String? name,
  GgRouteTreeNode? parent,
}) =>
    GgRouteTreeNode(
      name: name ?? '_ROOT_',
      parent: parent,
    );
