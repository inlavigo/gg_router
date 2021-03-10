// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';

class OtherClass {}

main() {
  late GgRouteTreeNode root;
  late GgRouteTreeNode childA0;
  late GgRouteTreeNode childA1;
  late GgRouteTreeNode childB;
  late GgRouteTreeNode childC;

  init() {
    root = exampleRouteNode(name: '');
    childA0 = exampleRouteNode(name: 'child-a0', parent: root);
    childA1 = exampleRouteNode(name: 'child-a1', parent: root);
    childB = exampleRouteNode(name: 'child-b', parent: childA0);
    childC = exampleRouteNode(name: 'child-c', parent: childB);
  }

  dispose() {
    root.dispose();
  }

  group('Param', () {
    // #########################################################################
    group('constructor', () {
      test('should create a parameter', () {
        init();
      });
    });
  });

  group('GgRouteTreeNode', () {
    // #########################################################################
    group('dispose()', () {
      test(
          'should remove all children from the node. '
          'Should remove the node from its parents list of children. '
          'Should reset the active child property of its parent.', () {
        init();
        final parent = childB.parent!;
        childB.isActive = true;
        expect(childB.children.length, 1);
        expect(parent.children.length, 1);
        expect(parent.activeChild, childB);
        childB.dispose();
        expect(parent.children.length, 0);
        expect(childB.children.length, 0);
        expect(parent.activeChild, null);
      });
    });

    // #########################################################################
    group('name', () {
      test('should return the name of the node', () {
        init();
        expect(root.name, '');
        expect(childA0.name, 'child-a0');
        expect(childB.name, 'child-b');
        expect(childC.name, 'child-c');
        dispose();
      });

      test('should throw an exception if name of an root note is not ""', () {
        init();
        expect(() => GgRouteTreeNode(name: 'root', parent: null),
            throwsArgumentError);
      });
    });

    // #########################################################################
    group('toString', () {
      test('should return the path of the node', () {
        expect(childC.toString(), childC.pathString);
      });
    });

    // #########################################################################
    group('parent', () {
      test('should return null for root and parent for child nodes', () {
        init();
        expect(root.parent, null);
        expect(childA0.parent, root);
        expect(childB.parent, childA0);
        expect(childC.parent, childB);
      });
    });

    // #########################################################################
    group('root', () {
      test('should return the root node in the hierachy', () {
        init();
        expect(root.root, root);
        expect(childA0.root, root);
        expect(childB.root, root);
        expect(childC.root, root);
      });
    });

    // #########################################################################
    group('isRoot', () {
      test('returns true if node is root node, otherwise false', () {
        init();
        expect(root.isRoot, true);
        expect(childC.isRoot, false);
      });
    });

    // #########################################################################
    group('index', () {
      test('returns which child of its parent this node is', () {
        init();
        expect(root.index, 0);
        expect(childA0.index, 0);
        expect(childA1.index, 1);
        expect(root.child(name: 'a').index, 2);
      });
    });

    // #########################################################################
    group('isActive', () {
      test('should be false by default', () {
        init();
        expect(root.isActive, false);
        expect(childA0.isActive, false);
        expect(childB.isActive, false);
        expect(childC.isActive, false);
      });

      test(
          'If isActive set to true, also all parent nodes should become active',
          () {
        init();
        childB.isActive = true;
        expect(root.isActive, true);
        expect(childB.isActive, true);
        expect(childC.isActive, false);
      });

      test(
          'If isActive set to true, the existing active child becomes inactive',
          () {
        init();

        // Initally childA0 is active
        childA0.isActive = true;
        expect(root.isActive, true);
        expect(childA0.isActive, true);

        // Now we set childA1 to active
        childA1.isActive = true;

        // childA0 should not be active anymore
        expect(childA0.isActive, false);
        expect(childA1.isActive, true);
      });

      test('If isActive is set to false, als all child nodes become inactive',
          () {
        init();

        // Currently the complete path is active
        childC.isActive = true;
        expect(root.isActive, true);
        expect(childA0.isActive, true);
        expect(childB.isActive, true);
        expect(childC.isActive, true);

        // Now we set childA to inActive
        childA0.isActive = false;

        // The parent is still active
        expect(root.isActive, true);

        // childA and its children are inactive
        expect(childA0.isActive, false);
        expect(childB.isActive, false);
        expect(childC.isActive, false);
      });

      test(
          'If isActive is set to false and then to true, thre previous active child becomes active also',
          () {
        init();

        // Currently the complete path is active
        childC.isActive = true;
        expect(root.isActive, true);
        expect(childC.isActive, true);

        // Now we set childB to inActive
        childB.isActive = false;

        // Child c is inactive also
        expect(childC.isActive, false);

        // Now we set childB active again
        childB.isActive = true;

        // Child c should become active also
        expect(childC.isActive, true);
      });
    });

    // #########################################################################
    group('onIsActive', () {
      test('should inform when isActive state changes', () {
        init();
        fakeAsync((fake) {
          bool? isActive;
          final s = childB.onIsActive.listen((event) => isActive = event);
          fake.flushMicrotasks();
          expect(isActive, isNull);

          childC.isActive = true;
          fake.flushMicrotasks();
          expect(isActive, isTrue);

          childA0.isActive = false;
          fake.flushMicrotasks();
          expect(isActive, isFalse);

          s.cancel();
        });
      });
    });

    // #########################################################################
    group('children', () {
      test('should return a list of all children', () {
        init();
        expect(root.children.toList(), [childA0, childA1]);
        expect(childA0.children.toList(), [childB]);
        expect(childB.children.toList(), [childC]);
        expect(childC.children.toList(), []);
      });
    });

    // #########################################################################
    group('child(name)', () {
      test('Should return an existing child, when possible', () {
        init();
        expect(root.child(name: 'child-a0'), same(childA0));
        expect(childA0.child(name: 'child-b'), same(childB));
      });

      test('Should create and return a new child, when not existing', () {
        init();
        final childA1 = root.child(name: 'child-a1');
        expect(childA1.name, 'child-a1');
        expect(childA1.parent, root);
        expect(root.children.length, 2);
      });
    });

    // #########################################################################
    group('hasChild(name)', () {
      test('should return when child with name exists, otherwise false', () {
        init();
        expect(root.hasChild(name: 'child-a0'), true);
        expect(root.hasChild(name: 'child-aX'), false);
      });
    });

    // #########################################################################
    group('removeChild(child)', () {
      test('removes the child from the list of childs. Disposes the child', () {
        init();
        expect(root.hasChild(name: childA0.name), isTrue);
        root.removeChild(childA0);
        expect(root.hasChild(name: childA0.name), isFalse);
      });

      test('throws an exception, if the child is not a child of node', () {
        init();
        expect(() => root.removeChild(childC), throwsArgumentError);
      });
    });

    // #########################################################################
    group('descendand(path)', () {
      test('should the descendand maching the path', () {
        init();
        final result =
            root.descendand(path: ['child-a0', 'child-b', 'child-c']);
        expect(result, childC);
      });

      test('should create the descendand if not existing', () {
        init();
        final result = root.descendand(path: ['x', 'y']);
        expect(result.name, 'y');
        expect(result.parent!.name, 'x');
        expect(result.parent!.parent!.name, '');
      });

      test('should return the element itself, if path is empty', () {
        init();
        final result = root.descendand(path: []);
        expect(result, root);
      });

      test('should return the parent element, if path segment is ".."', () {
        init();
        expect(childC.descendand(path: ['..', '..']), childA0);
        expect(
          childC.descendand(path: ['..', '..', '..', 'child-a1']),
          childA1,
        );
      });

      test('should return the element itself, if path segment is "."', () {
        init();
        expect(childC.descendand(path: ['.']), childC);
        expect(childC.descendand(path: ['.', '..']), childB);
      });

      test('should throw an exception if parent is not existing', () {
        init();
        expect(() => root.descendand(path: ['..']), throwsArgumentError);
      });

      test('should ignore empty path segments', () {
        init();
        expect(root.descendand(path: ['', '', 'child-a1']), childA1);
      });

      test(
          'path == "_LAST_" returns the previously active child, when available',
          () {
        init();
        // Set childA0 active -> last active child is childA0
        childA0.isActive = true;
        expect(root.descendand(path: ['_LAST_']), childA0);

        // Set childA0 inactive -> last active child is still childA0
        childA0.isActive = false;
        expect(root.descendand(path: ['_LAST_']), childA0);

        // Set childA1 active
        childA1.isActive = true;
        expect(root.descendand(path: ['_LAST_']), childA1);

        // Set childA1 inactive -> last active child is still childA1
        childA1.isActive = false;
        expect(root.descendand(path: ['_LAST_']), childA1);

        // ................................................................
        // Set childC active -> last active child of root should be childAC
        childC.isActive = true;
        expect(root.descendand(path: ['_LAST_']), childC);

        // Now lets switch to childA1 branch -> childC should not be active anymore
        childA1.isActive = true;
        expect(childC.isActive, false);

        // Now lets navigate to childA0/_LAST_ -> childC should be active again
        root.navigateTo('child-a0/_LAST_');
        expect(childC.isActive, true);
      });
    });

    // #########################################################################
    group('activeChild', () {
      test('should return null, if no child is active', () {
        init();
        expect(root.activeChild, null);
      });

      test('should return the active child, if one is active', () {
        init();
        childA0.isActive = true;
        expect(root.activeChild, childA0);
      });
    });

    // #########################################################################
    group('previousActiveChild', () {
      test('should return the child that was active before', () {
        init();
        expect(root.activeChild, null);
        expect(root.previousActiveChild, null);
        childA0.isActive = true;
        expect(root.previousActiveChild, null);
        expect(root.activeChild, childA0);
        childA1.isActive = true;
        expect(root.previousActiveChild, childA0);
        expect(root.activeChild, childA1);
        childA1.isActive = false;
        expect(root.previousActiveChild, childA1);
        expect(root.activeChild, null);
      });
    });

    // #########################################################################
    group('activeChildDidChange', () {
      group('should return a steam', () {
        test(
            'which delivers the child which became active'
            ' or null if child became inactive', () {
          fakeAsync((fake) {
            init();

            // Listen to activeChildDidChange
            GgRouteTreeNode? activeChild;
            final s = root.activeChildDidChange.listen((c) => activeChild = c);

            // Initially no child is active
            fake.flushMicrotasks();
            expect(activeChild, null);

            // Now let's make childA0 active
            childA0.isActive = true;
            fake.flushMicrotasks();
            expect(activeChild, childA0);

            // Now let's make childA1 active
            childA1.isActive = true;
            fake.flushMicrotasks();
            expect(activeChild, childA1);

            // Now let's make childA1 inactive.
            childA1.isActive = false;
            fake.flushMicrotasks();
            expect(activeChild, null);

            s.cancel();
          });
        });
      });
    });

    // #########################################################################
    group('activeDescendands', () {
      test('should return a list with all active descendands', () {
        fakeAsync((fake) {
          init();
          // Initially no child is active
          expect(root.activeDescendands, []);

          // Now let's set childB to active
          childB.isActive = true;
          fake.flushMicrotasks();

          // The complete path from root to childB should be active
          expect(root.activeDescendands.map((e) => e.name).toList(),
              ['child-a0', 'child-b']);
        });
      });
    });

    // #########################################################################
    group('findOrCreateParam(name, seed), param(name), hasParam(name)', () {
      test('Should create a new property, if no property with name exists', () {
        init();

        // ....................................
        // Let's create a param 'a' with seed 5
        root.findOrCreateParam(name: 'a', seed: 5);

        // ................................................................
        // Let's create the same param 'a' again, but with a different type.
        // This should give an exception.
        expect(
          () => root.findOrCreateParam(name: 'a', seed: 'Hello'),
          throwsA(
            predicate(
              (ArgumentError e) {
                expect(e.message,
                    'Error while retrieving param with name "a". The existing param has type "int" and not "String".');
                return true;
              },
            ),
          ),
        );

        // ......................
        // The param should exist
        expect(root.hasParam('a'), true);
        expect(root.param('a')!.value, 5);

        // ..................................................
        // Let's try to retrieve the param with a wrong type.
        // This should give an exception.
        expect(
          () => root.param<String>('a'),
          throwsA(
            predicate(
              (ArgumentError e) {
                expect(e.message,
                    'Error while retrieving param with name "a". The existing param has type "int" and not "String".');
                return true;
              },
            ),
          ),
        );

        // ..................................................
        // Dispose the root. This should also dispose delete all params
        root.dispose();
        expect(root.hasParam('a'), false);
      });
    });

    // #########################################################################
    group('ownOrParentParam', () {
      test(
          'should return the param with name from the node itself or its parents',
          () {
        init();
        childA0.findOrCreateParam(name: 'param', seed: 5);
        expect(childC.ownOrParentParam('param')!.value, 5);
      });
    });

    // #########################################################################
    group('activeParams', () {
      test('should return a map with all params of the active path', () {
        init();

        // Lets define some vars
        final a0Name = 'a0';
        final a0Value = 1;

        final a1Name = 'a1';
        final a1Value = 2;

        final cName = 'c';
        final cValue = 3;

        // Initally no params should be active
        expect(root.activeParams, {});

        // Let's create two params, one for childA0 and childA1 and childC
        childA0.findOrCreateParam(name: a0Name, seed: a0Value);
        childA1.findOrCreateParam(name: a1Name, seed: a1Value);
        childC.findOrCreateParam(name: cName, seed: cValue);

        // root.activeParams should sill be empty, because
        // none of the children is active
        expect(root.activeParams, {});

        // Let's activate childC
        childC.isActive = true;

        // Now active params should contain 3 and 1.
        expect(root.activeParams.length, 2);
        expect(root.activeParams[a0Name]?.value, a0Value);
        expect(root.activeParams[cName]?.value, cValue);

        // Let's activate child a1
        childA1.isActive = true;
        expect(root.activeParams.length, 1);
        expect(root.activeParams[a1Name]?.value, a1Value);
      });
    });

    // #########################################################################
    group('onOwnParamChange', () {
      test('Should trigger if any of own params has changed', () {
        fakeAsync((fake) {
          init();

          // Initally the listener should not be called.
          int calls0 = 0;
          int calls1 = 0;
          final resetCalls = () {
            calls0 = 0;
            calls1 = 0;
          };
          final s0 = root.onOwnParamChange.listen((event) => calls0++);
          final s1 = root.onOwnParamChange.listen((event) => calls1++);
          fake.flushMicrotasks();
          expect(calls0, 0);
          expect(calls1, 0);

          // Now let's add a param. onOwnParamChange should trigger.
          root.findOrCreateParam(name: 'a', seed: 5);
          root.findOrCreateParam(name: 'b', seed: 6);

          fake.flushMicrotasks();
          expect(calls0, 1);
          expect(calls1, 1);
          resetCalls();

          // Now let's change the params. onOwnParamChange should trigger one time.
          root.param('a')!.value++;
          root.param('a')!.value++;
          root.param('b')!.value++;
          root.param('b')!.value++;
          fake.flushMicrotasks();
          expect(calls0, 1);
          expect(calls1, 1);
          resetCalls();

          s0.cancel();
          s1.cancel();
          dispose();
        });
      });
    });

    // #########################################################################
    group('onOwnOrChildParamChange', () {
      test('should trigger every time an own param or an child param changes',
          () {
        fakeAsync((fake) {
          init();

          int calls0 = 0;
          int calls1 = 0;
          final resetCalls = () {
            calls0 = 0;
            calls1 = 0;
          };

          // Initally the listener should not be called.
          final s0 = root.onOwnOrChildParamChange.listen((event) => calls0++);
          final s1 = root.onOwnOrChildParamChange.listen((event) => calls1++);
          fake.flushMicrotasks();
          expect(calls0, 0);
          expect(calls1, 0);
          resetCalls();

          // Now lets create a param on one of the children
          childC.findOrCreateParam(name: 'x', seed: 5);
          childC.findOrCreateParam(name: 'y', seed: 'Hello');
          fake.flushMicrotasks();
          expect(calls0, 1);
          expect(calls1, 1);
          resetCalls();

          // Let's change the param on one of the children
          childC.param('x')!.value++;
          childC.param('y')!.value = 'movie';
          fake.flushMicrotasks();
          expect(calls0, 1);
          expect(calls1, 1);
          resetCalls();

          // Let's add another child, and check if changes on the new child's
          // params are communicated.
          final newChild = childC.child(name: 'new-child');
          newChild.findOrCreateParam(name: 'k', seed: 5);
          fake.flushMicrotasks();
          expect(calls0, 1);
          expect(calls1, 1);
          resetCalls();
          expect(calls0, 0);
          expect(calls1, 0);
          newChild.param('k')!.value++;
          fake.flushMicrotasks();
          expect(calls0, 1);
          expect(calls1, 1);

          s0.cancel();
          s1.cancel();
        });
      });
    });

    // #########################################################################
    group('activeDescendandsDidChange', () {
      test('should return a stream which informs about the active descendands',
          () {
        fakeAsync((fake) {
          init();

          // Listen to active descendands
          List<GgRouteTreeNode>? activeDescendands;
          var updateCounter = 0;
          final s = root.activeDescendandsDidChange.listen((event) {
            activeDescendands = event;
            updateCounter++;
          });

          // Initially no updates should be delivered
          fake.flushMicrotasks();
          expect(updateCounter, 0);
          expect(activeDescendands, null);

          // Now lets set childC active
          childC.isActive = true;

          // The complete path from root to childC should become active
          fake.flushMicrotasks();
          expect(updateCounter, 1);
          expect(activeDescendands?.map((e) => e.name).toList(),
              ['child-a0', 'child-b', 'child-c']);

          // Now let's set root inactive
          updateCounter = 0;
          root.isActive = false;

          // All nodes are set to inactive
          fake.flushMicrotasks();
          expect(updateCounter, 1);
          expect(activeDescendands, []);

          s.cancel();
        });
      });
    });

    // #########################################################################
    group('get path', () {
      test(
          'should return a list of path segments starting with the root and '
          'ending with the nodes name itself.', () {
        init();
        expect(root.path, []);
        expect(childA0.path, ['child-a0']);
        expect(childB.path, ['child-a0', 'child-b']);
        expect(childC.path, ['child-a0', 'child-b', 'child-c']);
      });
    });

    // #########################################################################
    group('get pathString', () {
      test(
          'should return a list of path segments starting with the root and '
          'ending with the nodes name itself.', () {
        init();
        expect(root.pathString, '/');
        expect(childA0.pathString, '/child-a0');
        expect(childB.pathString, '/child-a0/child-b');
        expect(childC.pathString, '/child-a0/child-b/child-c');
      });
    });

    // #########################################################################
    group('get pathHashCode', () {
      test(
          'should return a hash which is same for all nodes having the same path ',
          () {
        init();
        expect(root.pathHashCode, root.pathHashCode);
        expect(root.pathHashCode, isNot(childA0.pathHashCode));

        final root1 = GgRouteTreeNode(name: root.name);
        expect(root.pathHashCode, root1.pathHashCode);

        final childA11 = GgRouteTreeNode(name: childA1.name, parent: root1);
        expect(childA11.pathHashCode, childA1.pathHashCode);
      });
    });

    // #########################################################################
    group('get activeChildPath', () {
      test('should return a list of path segments of active child nodes', () {
        init();
        childC.isActive = true;
        expect(root.activeChildPath, ['child-a0', 'child-b', 'child-c']);
        expect(childA0.activeChildPath, ['child-b', 'child-c']);
        expect(childB.activeChildPath, ['child-c']);
        expect(childC.activeChildPath, []);
      });
    });

    // #########################################################################
    group('set activeChildPath', () {
      test('should activate the segments according to the assigned path', () {
        init();

        // Initially no node is active
        expect(root.isActive, false);
        expect(childA0.isActive, false);
        expect(childA1.isActive, false);
        expect(childB.isActive, false);
        expect(childC.isActive, false);

        // Activate all nodes in the path
        root.activeChildPath = ['child-a0', 'child-b', 'child-c'];

        expect(root.isActive, true);
        expect(root.activeChild, childA0);

        expect(childA0.isActive, true);
        expect(childA0.activeChild, childB);

        expect(childA1.isActive, false);

        expect(childB.isActive, true);
        expect(childB.activeChild, childC);

        expect(childC.isActive, true);
        expect(childC.activeChild, null);

        // Deactivate all children
        root.activeChildPath = [];
        expect(root.isActive, true);
        expect(childA0.isActive, false);
        expect(childA1.isActive, false);
        expect(childB.isActive, false);
        expect(childC.isActive, false);
      });

      test('should create new child nodes, if not existing', () {
        init();
        root.activeChildPath = ['x', 'y', 'z'];
        final x = root.child(name: 'x');
        final y = x.child(name: 'y');
        final z = y.child(name: 'z');

        expect(root.isActive, true);
        expect(x.isActive, true);
        expect(y.isActive, true);
        expect(z.isActive, true);
      });

      test('should disable children that are not selected', () {
        init();
        childC.isActive = true;
        expect(root.activeChildPath.join('/'), 'child-a0/child-b/child-c');
        root.activeChildPath = ['child-a0', 'child-b'];
        expect(root.activeChildPath.join('/'), 'child-a0/child-b');
      });

      test('should handle ".." as parent segment', () {
        init();
        childC.activeChildPath = ['..', '..', '..', 'child-a1'];
        expect(root.activeChildPath.join('/'), 'child-a1');
      });

      test('should handle "." the element itself', () {
        init();
        childC.activeChildPath = ['.', '..', 'child-b'];
      });
    });

    // #########################################################################
    group('navigateTo(path)', () {
      test('Should activate the given relative path', () {
        init();
        root.navigateTo('child-a0/child-b/child-c');
        expect(root.activeChildPathString, 'child-a0/child-b/child-c');
      });

      test('Should activate the given absolute path', () {
        init();
        childC.navigateTo('/child-a1');
        expect(root.activeChildPathString, 'child-a1');
      });

      test('Should interpret ".." as parent element', () {
        init();
        childC.navigateTo('../../');
        expect(root.activeChildPathString, 'child-a0');
      });

      test('Should interpret "." as the element itself', () {
        init();
        childB.navigateTo('./child-c');
        expect(root.activeChildPathString, 'child-a0/child-b/child-c');
      });
    });

    // #########################################################################
    group('uriParams, uriParamForName, removeUriParamForParam', () {
      test(
          'should allow to specify default values that are used to initialize route params',
          () {
        init();

        // Let's set an early seed at the root
        root.uriParams = {'a': '10', 'b': '20invalid'};

        // The seed should be avalable on all nodes of the tree
        expect(
            childC.uriParamForName(
              'a',
            ),
            '10');

        expect(
            childB.uriParamForName(
              'a',
            ),
            '10');

        expect(
            root.uriParamForName(
              'a',
            ),
            '10');

        expect(
            childC.uriParamForName(
              'b',
            ),
            '20invalid');

        // Now lets create a paramter a
        childB.findOrCreateParam(name: 'a', seed: 11);

        // The parameter should be initialized with uriParams
        expect(childB.param('a')?.value, 10);

        // Early seed should only be used the first time.
        // Thus it should be deleted now.
        expect(root.uriParamForName('a'), null);

        // Now lets create a paramter b
        // Early seed should be ignored because it has a invalid value (20inavlid).
        childB.findOrCreateParam(name: 'b', seed: 22);
        expect(childB.param('b')?.value, 22);
      });
    });

    // #########################################################################
    group('Error Handling', () {
      test('should allow to set and handle errors', () {
        init();

        // ......................................
        // Let's set an error handler on the root
        GgRouteTreeNodeError? lastErrorReceivedOnRoot;
        final errorHandler = (error) => lastErrorReceivedOnRoot = error;
        root.errorHandler = errorHandler;
        expect(root.errorHandler, errorHandler);

        // ............................
        // Let's set an error on childC
        final error = GgRouteTreeNodeError(
          id: 'GRC008447',
          message: 'Error message',
          node: childC,
        );
        childC.setError(error);

        // ........................................
        // It should arrive at roo'ts error handler
        expect(lastErrorReceivedOnRoot, isNotNull);
        expect(lastErrorReceivedOnRoot, error);

        // ....................................
        // Let's add an error handler to childB
        // childB should handle the error.
        // The error should not arrive at root's error handler anymore.
        lastErrorReceivedOnRoot = null;
        GgRouteTreeNodeError? lastErrorReceivedOnChildB;
        childB.errorHandler = (error) => lastErrorReceivedOnChildB = error;
        childC.setError(error);
        expect(lastErrorReceivedOnRoot, isNull);
        expect(lastErrorReceivedOnChildB, error);

        // Let's try to add an error handler twice.
        // This should cause an exception.
        expect(() => childB.errorHandler = (error) => {}, throwsArgumentError);

        // .........................................................
        // Let's remove the error handler from root and set an error
        // This should cause an exception.
        root.errorHandler = null;
        expect(() => root.setError(error), throwsException);
      });
    });
  });
}
