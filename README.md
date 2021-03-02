# GgRouter - Super Simple Routing and Navigation for Flutter

This package offers a super simple way to synchronize a Flutter app with the
browser URI. Additionally, a simple method is provided to navigate between
states of an app. Particularly you are able to ...

1. Define nested widget hierarchies.
2. Generate the browser URI out of the widget hierarchy.
3. Navigate relative from one widget to another.
4. Navigate absolutely to a given widget.
5. Navigate to parent or child elements.

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
