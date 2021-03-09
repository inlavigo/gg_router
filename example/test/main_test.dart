// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:gg_easy_widget_test/gg_easy_widget_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_router_example/main.dart';

main() {
  group('GgRouterExample', () {
    // .........................................................................
    late GgEasyWidgetTest<GgRouterExample, dynamic> ggRouterExample;
    final key = GlobalKey(debugLabel: 'GgRouterExample');

    late GgRouterDelegate routerDelegate;
    late String currentUri;

    GgEasyWidgetTest? sportsPage;
    GgEasyWidgetTest? transportationPage;
    GgEasyWidgetTest? placesPage;

    late GgEasyWidgetTest appBar;
    late GgEasyWidgetTest sportsButton;
    late GgEasyWidgetTest transportationButton;
    late GgEasyWidgetTest placesButton;

    late GgEasyWidgetTest bottomBarButton0;
    late GgEasyWidgetTest bottomBarButton1;
    late GgEasyWidgetTest bottomBarButton2;

    // .........................................................................
    GgEasyWidgetTest? page(String key, WidgetTester tester) {
      final finder = find.byKey(ValueKey(key));
      final elements = finder.evaluate();
      if (elements.length > 0) {
        return GgEasyWidgetTest(finder, tester);
      }
    }

    // .........................................................................
    updatePages(WidgetTester tester) {
      sportsPage = page('sportsPage', tester);
      transportationPage = page('transportationPage', tester);
      placesPage = page('placesPage', tester);
      currentUri = routerDelegate.currentConfiguration.location!;
    }

    // .........................................................................
    updateHeaderBar(WidgetTester tester) {
      appBar = GgEasyWidgetTest(find.byType(AppBar), tester);
      sportsButton = GgEasyWidgetTest(
        find.byKey(ValueKey('sports')),
        tester,
      );
      transportationButton = GgEasyWidgetTest(
        find.byKey(ValueKey('transportation')),
        tester,
      );
      placesButton = GgEasyWidgetTest(
        find.byKey(ValueKey('places')),
        tester,
      );
    }

    // .........................................................................
    updateRouterDelegate(WidgetTester tester) {
      routerDelegate = (tester.widget(find.byType(MaterialApp)) as MaterialApp)
          .routerDelegate as GgRouterDelegate;
    }

    // .........................................................................
    updateBottomBarButtons(WidgetTester tester) {
      final bottomNavigationBar = find.byType(BottomNavigationBar);

      final icons = find.descendant(
        of: bottomNavigationBar,
        matching: find.byType(Icon),
      );
      expect(icons.evaluate().length, 3);

      bottomBarButton0 = GgEasyWidgetTest(icons.at(0), tester);
      bottomBarButton1 = GgEasyWidgetTest(icons.at(1), tester);
      bottomBarButton2 = GgEasyWidgetTest(icons.at(2), tester);
    }

    // .........................................................................
    update(WidgetTester tester) {
      updatePages(tester);
      updateHeaderBar(tester);
      updateBottomBarButtons(tester);
    }

    // .........................................................................
    pressBottomButton(int index, WidgetTester tester) async {
      final button = index == 0
          ? bottomBarButton0
          : index == 1
              ? bottomBarButton1
              : bottomBarButton2;

      final gesture = await tester.startGesture(button.absoluteFrame.center);
      await gesture.up();
      await tester.pumpAndSettle();
      update(tester);
    }

    // .........................................................................
    setUp(WidgetTester tester) async {
      final widget = GgRouterExample(key: key);
      await tester.pumpWidget(widget);
      final ggRouterExampleFinder = find.byWidget(widget);
      ggRouterExample = GgEasyWidgetTest(ggRouterExampleFinder, tester);
      updateRouterDelegate(tester);
      update(tester);
    }

    // .........................................................................
    tearDown(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    // .........................................................................
    testWidgets('should only show the active route page',
        (WidgetTester tester) async {
      // ................................
      // Check the inital size of the app
      await setUp(tester);
      expect(ggRouterExample.width, 800);
      expect(ggRouterExample.height, 600);

      // ..........................................
      // Initially only sports page should be shown
      expect(sportsPage, isNotNull);
      expect(transportationPage, isNull);
      expect(placesPage, isNull);
      expect(currentUri.startsWith('sports/'), true);

      // ..................................
      // Click on transportations menu item
      // => Transportations page should only be shown
      await transportationButton.press();
      update(tester);
      expect(sportsPage, isNull);
      expect(transportationPage, isNotNull);
      expect(placesPage, isNull);
      expect(currentUri.startsWith('transportation/'), true);

      // .........................
      // Click on places menu item
      // => Transportations page should only be shown
      await placesButton.press();
      update(tester);
      expect(sportsPage, isNull);
      expect(transportationPage, isNull);
      expect(placesPage, isNotNull);
      expect(currentUri.startsWith('places/'), true);

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('sports show a bottom navigation bar with tree items',
        (WidgetTester tester) async {
      await setUp(tester);

      // ..........................
      // Click on the first button
      // => Basketball page should open
      await pressBottomButton(0, tester);
      expect(currentUri, startsWith('sports/basketball'));

      // ..........................
      // Click on the second button
      // => Basketball page should open
      await pressBottomButton(1, tester);
      expect(currentUri, startsWith('sports/football'));

      // ..........................
      // Click on the third button
      // => Handball page should open
      await pressBottomButton(2, tester);
      expect(currentUri, startsWith('sports/handball'));

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets(
        'transportation should show a bottom navigation bar with tree items',
        (WidgetTester tester) async {
      await setUp(tester);

      // .............................
      // Switch to transportation page
      await transportationButton.press();

      // ..........................
      // Click on the first button
      // => Basketball page should open
      await pressBottomButton(0, tester);
      expect(currentUri, startsWith('transportation/bus'));

      // ..........................
      // Click on the second button
      // => Basketball page should open
      await pressBottomButton(1, tester);
      expect(currentUri, startsWith('transportation/bike'));

      // ..........................
      // Click on the third button
      // => Handball page should open
      await pressBottomButton(2, tester);
      expect(currentUri, startsWith('transportation/car'));

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('places should show a bottom navigation bar with tree items',
        (WidgetTester tester) async {
      await setUp(tester);

      // .............................
      // Switch to transportation page
      await placesButton.press();

      // ..........................
      // Click on the first button
      // => Basketball page should open
      await pressBottomButton(0, tester);
      expect(currentUri, startsWith('places/airport'));

      // ..........................
      // Click on the second button
      // => Basketball page should open
      await pressBottomButton(1, tester);
      expect(currentUri, startsWith('places/park'));

      // ..........................
      // Click on the third button
      // => Handball page should open
      await pressBottomButton(2, tester);
      expect(currentUri, startsWith('places/hospital'));

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets(
        'when switching from transporations page back to sports page, '
        'the last opened sports sub-page should be opeend',
        (WidgetTester tester) async {
      await setUp(tester);

      // .............................
      // Open the football sports page
      await pressBottomButton(1, tester);
      expect(currentUri, startsWith('sports/football'));

      // .............................
      // Open the transportations page
      await transportationButton.press();
      update(tester);
      expect(currentUri, startsWith('transportation'));

      // .............................
      // Switch back to sports page
      // => last opened page should be active again
      await sportsButton.press();
      update(tester);
      expect(currentUri, startsWith('sports/football'));

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets(
        'when clicking on basket ball page, a dialog should open.'
        'The dialog should show a check box. '
        'Checking the checkbox should change the visit param in the URI. '
        'Changing the visit param in the URI should change the checkbox. '
        'Clicking the close button should switch back.',
        (WidgetTester tester) async {
      await setUp(tester);
      expect(currentUri, startsWith('sports/basketball'));

      // ....................................................
      // Click on the basket ball in the center of the screen
      final gesture =
          await tester.startGesture(ggRouterExample.absoluteFrame.center);
      await gesture.up();
      update(tester);

      // ................................
      // A dialog should have been opened
      expect(currentUri, startsWith('sports/basketball/dialog'));
      await tester.pumpAndSettle();

      // ..........................
      // There should be a checkbox
      // The checkbox should not be checked
      var checkBox = GgEasyWidgetTest(find.byType(CheckboxListTile), tester);
      var checkBoxWidget = checkBox.widget as CheckboxListTile;
      expect(checkBoxWidget.value, false);
      update(tester);
      expect(currentUri, 'sports/basketball/dialog?visit=false');

      // ........................
      // Let's click the checkbox
      // => The checkbox should be checked now
      await checkBox.press();
      update(tester);
      checkBox = GgEasyWidgetTest(find.byType(CheckboxListTile), tester);
      checkBoxWidget = checkBox.widget as CheckboxListTile;
      expect(checkBoxWidget.value, true);
      expect(currentUri, 'sports/basketball/dialog?visit=true');

      // ..............
      // Change the URI
      // => checkbox should change also
      routerDelegate.setNewRoutePath(
        RouteInformation(location: 'sports/basketball/dialog?visit=false'),
      );
      await tester.pumpAndSettle();
      update(tester);
      checkBox = GgEasyWidgetTest(find.byType(CheckboxListTile), tester);
      checkBoxWidget = checkBox.widget as CheckboxListTile;
      expect(checkBoxWidget.value, false);

      // ..............................
      // Finally let's close the dialog
      // => dialog is removed from the URI
      final dialogCloseButton = GgEasyWidgetTest(
        find.byKey(ValueKey('dialogCloseButton')),
        tester,
      );
      await dialogCloseButton.press();
      await tester.pumpAndSettle();
      update(tester);
      expect(currentUri, 'sports/basketball?visit=false');

      await tearDown(tester);
    });

    // .........................................................................
    testWidgets('opening a unknown URL should show an error in the snack bar',
        (WidgetTester tester) async {
      await setUp(tester);

      routerDelegate
          .setNewRoutePath(RouteInformation(location: 'sports/superhero'));
      await tester.pumpAndSettle();
      final snackBar =
          GgEasyWidgetTest(find.byType(SnackBar), tester).widget as SnackBar;
      expect((snackBar.content as Text).data,
          'Route "/sports" has no child named "superhero".');

      await tester.pumpAndSettle(Duration(seconds: 5));

      await tearDown(tester);
    });
  });
}
