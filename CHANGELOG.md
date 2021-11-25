# Change Log

## 2.0.0+dev.8 - July 14th, 2021

* Background color of `NavigationBar` can be null to allow clicks going widgets beghind
* Added `parseJson(...)`

## 2.0.0+dev.5 - July 7th, 2021

* Added `typedef GgNavigationPageBuilder`
* Simplified widget structure

## 2.0.0+dev.1 - June 30th, 2021

* Use  `GgShowInForeground` to define which widgets should be shown in the
  foreground: a) the widget animated in or b) the widget animated out.
* Added `GgNavigationPage` to create deeply nested navigation pages similar
  to `CupertinoPageScaffold` and `CupertinoNavigationBar`.

* Breaking changes:
  * Animation callbacks are provided with the size of the enclosing widget

## 1.2.0 - June 29th, 2021

* Introduced `GgRouteChangeBuilder`
* Allow to set semantics label for a given route
* Allow to specify semantic labels for a given route path
* Store semantic label into JSON

## 1.1.0 - March 24th, 2021

* Fixed issues with disposing the route tree
* Renamed `GgRouteTreeNode:child` into `GgRouteTreeNode:findOrCreateChild`
* Reintroduced `GgRouteTreeNode:child`
* Refined handling when a root and a default path is submitted to
  GgRouterDelegate.
* `GgRouterDelegate` can take a pre-configured root node, which helps the route
  tree be managed outside the widget hierarchy.
* `GgRouteTreeNode.newRoot` was introduced to create root nodes.

## 1.0.1 - March 20th, 2021

* Fixed a bug braking semantic labels

## 1.0.0 - March 19th, 2021

* Added the option to define wild card routes using '*' as route name.

## 1.0.0-beta.5 - March 18th, 2021

* Animations
  * Route transitions can be animated now.
  * Create a separate in and out animation
  * Create different animations for different routes

* `GgPopoverRoute`
  * was renamed in `GgPopoverRoute`
  * Interface was changed slightly

* Index routes
  * Index routes must not be named with empty name.
  * They must get the name `_INDEX_.

* Renamed several identifiers.

## 1.0.0-beta.4 - March 13th, 2021

* Save and restore route tree

## 1.0.0-beta.3 - March 11th, 2021

* Added an index route example

## 1.0.0-beta.2 - March 10th, 2021

* Fixed the unit tests for the example.

## 1.0.0-beta.1 - March 10th, 2021

* The first public version of GgRouter.
