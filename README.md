# Simple and powerful routing and navigation for flutter

`GgRouter` offers an intuitive way to synchronize a Flutter app with the browser
URI. Additionally, a simple method is provided to navigate between states of an
app.

## GgRouter Features

1. Define nested routes directly within your widget hierarchy.
2. Generate the browser URI out of the widget hierarchy.
3. Navigate relatively or absolutely to children, parents, and siblings.
4. Restore the previous state when navigating back to a previous route.
5. Handle invalid routes.
6. Combine navigation and router code.
7. Define an index page for each route.

## Define routes

### Basic routes

Use `GgRouterWidget` to add routes to your application structure:

~~~dart
@override
Widget build(BuildContext context){
  GgRouter({
    'sports':         _sports,
    'transportation': _transportation,
    'places':         _places
  })
}
~~~

### Nested routes

Each of the three widgets `_sports`, `_transportation` and `_places` can define
its own sub routes:

~~~dart
Widget _sports(BuildContext context){
  return Container(
    child: {
      GgRouter({
        'basketball': _basketBall,
        'football': _footBall,
        'handball': _handBall,

      });
    }
  );
}
~~~

### Index route

The example above allows now routes like `/sports/basketball`. But what happens
if one opens the route `/sports`? By default `GgRouter` navigates to the first
route, i.e. the `basketball` route. To specify a widget that is shown when
`/sports` is called, just add a empty named route:

~~~dart
Widget _sports(BuildContext context){
  return Container(
    child: {
      GgRouter({
        '': _index, // The index route, shown one navigates to "/sports".
        'basketball': _basketBall,
        'football': _footBall,
        'handball': _handBall,

      });
    }
  );
}
~~~

## Navigation

Use `GgRouter.of(context).navigateTo(path)` to get the current context's router.
By specifying an absolute or relative `path` you can now navigate to other
places.

### Absolute navigation

Use `navigateTo('/sports/football')` to navigate to the football page, no matter
where you currently are in your application.

### Relative navigation

Imagine you are in the context of the `/sports` route. Use
`navigateTo('./basketball')` to switch to the handball page. You can also jump
to deeply nested children by calling something like
`navigateTo('./basketball/dialog')`.

### Navigate to a parent route

Imagine you are in the context of the `/sports/basketball` route. Use
`navigateTo('../')` to navigate to the parent route. In the example we use that
method to close the dialog.

## Restore route state

After jumping from "Transportation" to "Sports" the previously opened sports
page appears. This is achieved by using the keyword `_LAST_`. When one clicks on
"Sports", `navigateTo('/sports/_LAST_')` is executed.

## Error handling

If one opens a URI in the browser that is not defined using `GgRouter(...)`, the
route last active is kept. But you might want to handle that error and show an
error message. To do so, assign an error handler to `GgRouter.of(context).errorHandler`.

## Demo

<img src="img/gg_router.gif" style="max-width: 480px;">

## Step 1: Define the widget and route hierarchy

- Use the `GgRouter` widget to define a widget hierarchy.
- Each route has a name and a widget.
- Use the name `''` to specify a default route.
- The names will be shown as segments in the browser URL.

~~~dart
class GgRouterExample extends StatelessWidget {
  const GgRouterExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      GgRouter({
        '.': Container(color: Colors.black),
        'yellow': Container(color: Colors.yellow),
        'green': Container(color: Colors.green),
        'red': Container(color: Colors.red,
          child:
            GgRouter({
              '': Text(''),
              'hello': Text('hello'),
              'world': Text('world'),
            }),
        ),
      }),
  }
~~~

## Step 2: Add navigation buttons

- Use `GgRouter` widgets side by side with navigation buttons.
- Use `context.navigateTo('...')`, to show the desired widgets.
- The method `navigateTo` takes absolute and relative pathes

~~~dart
class GgRouterExample extends StatelessWidget {
  // ...

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Navigation buttons
        TextButton(
          onPressed: () => context.navigateTo('/yellow'),
          child: Text('Yellow'),
        ),
        TextButton(
          onPressed: () => context.navigateTo('/green'),
          child: Text('Green'),
        ),
        TextButton(
          onPressed: () => context.navigateTo('/red'),
          child: Text('Red'),
        )

        // Routes
        GgRouter({
          // ...
        }),
      ]
    );
  }
~~~

## Step 3: Navigate relative to parent or siblings

- `context.navigateTo(...)` takes also `../` and `./` paths.
- Use this to navigate to parent or sibling widgets.
- Important: Don't forget to wrap your navigation buttons into a `Builder`.
  Otherwise `context.navigateTo(...)` will have the wrong reference.

~~~dart
class GgRouterExample extends StatelessWidget {
  // ...

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Routes
        GgRouter({
          // ...
          'red': Container(color: red),
            child:
              Column(children: [

                // Important: Builder is needed to provide the right context
                // for the context.navigateTo(...) method.
                Builder(builder: (context){
                  Row(children: [
                    TextButton(
                      onPressed: () => context.navigateTo('./hello'),
                      child: Text('./hello'),
                    ),

                    TextButton(
                      onPressed: () => context.navigateTo('./world'),
                      child: Text('./world'),
                    ),

                    TextButton(
                      onPressed: () => context.navigateTo('../yellow'),
                      child: Text('../yellow'),
                    ),
                  ]),
                }),
                GgRouter({
                  '': _text(''),
                  'hello': _text('hello'),
                  'world': _text('world'),
                }),
              ])
          ),
        }),
      ]
    );
  }
~~~

## Step 4: Configure your MaterialApp to work with GgRouter

- Create an instance of `GgRouterDelegate` and `GgRouteInformationParser`.
- Create an instance of `MaterialApp.router(...)` and provide it with the
  created delegate and parser.

~~~dart
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _routerDelegate = GgRouterDelegate(
      child: Scaffold(
    body: GgRouterExample(),
  ));

  final _routeInformationParser = GgRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GgRouterExample',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
~~~

## Putting altogether

The complete example can be found in `example/lib/main.dart` in the package
folder.
