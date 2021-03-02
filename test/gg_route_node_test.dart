import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_route/gg_route.dart';

main() {
  late GgRouteNode root;
  late GgRouteNode childA0;
  late GgRouteNode childA1;
  late GgRouteNode childB;
  late GgRouteNode childC;

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

  group('GgRouteNode', () {
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
        expect(
            () => GgRouteNode(name: 'root', parent: null), throwsArgumentError);
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
      test('Returns true if node is root node, otherwise false', () {
        init();
        expect(root.isRoot, true);
        expect(childC.isRoot, false);
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
    group('activeChildDidChange', () {
      group('should return a steam', () {
        test(
            'which delivers the child which became active'
            ' or null if child became inactive', () {
          fakeAsync((fake) {
            init();

            // Listen to activeChildDidChange
            GgRouteNode? activeChild;
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
    group('activeDescendandsDidChange', () {
      test('should return a stream which informs about the active descendands',
          () {
        fakeAsync((fake) {
          init();

          // Listen to active descendands
          List<GgRouteNode>? activeDescendands;
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

        final root1 = GgRouteNode(name: root.name);
        expect(root.pathHashCode, root1.pathHashCode);

        final childA11 = GgRouteNode(name: childA1.name, parent: root1);
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
  });
}
