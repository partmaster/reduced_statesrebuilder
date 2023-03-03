![GitHub release (latest by date)](https://img.shields.io/github/v/release/partmaster/reduced_statesrebuilder)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/partmaster/reduced_statesrebuilder/dart.yml)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/partmaster/reduced_statesrebuilder)
![GitHub last commit](https://img.shields.io/github/last-commit/partmaster/reduced_statesrebuilder)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/partmaster/reduced_statesrebuilder)
# reduced_statesrebuilder

Implementation of the 'reduced' API for the 'statesrebuilder' state management framework with following features:

1. Implementation of the ```Reducible``` interface 
2. Extension on the ```BuildContext``` for convenient access to the  ```Reducible``` instance.
3. Register a state for management.
4. Trigger a rebuild on widgets selectively after a state change.

## Features

#### 1. Implementation of the ```Reducible``` interface 

```dart
class Store<S> extends Reducible<S> {
  Store(S intitialValue) : value = RM.inject<S>(() => intitialValue);

  final Injected<S> value;

  @override
  get state => value.state;

  @override
  reduce(reducer) => value.state = reducer(value.state);
}
```

#### 2. Extension on the ```BuildContext``` for convenient access to the  ```Reducible``` instance.

```dart
extension ExtensionStoreOnBuildContext on BuildContext {
  Store<S> store<S>() => InheritedValueWidget.of<Store<S>>(this);
}
```

#### 3. Register a state for management.

```dart
Widget wrapWithProvider<S>({
  required S initialState,
  required Widget child,
}) =>
    StatefulInheritedValueWidget(
      converter: (rawValue) => Store(rawValue),
      rawValue: initialState,
      child: child,
    );
```

#### 4. Trigger a rebuild on widgets selectively after a state change.

```dart
extension WrapWithConsumer<S> on Store<S> {
  Widget wrapWithConsumer<P>({
    required ReducedTransformer<S, P> transformer,
    required ReducedWidgetBuilder<P> builder,
  }) =>
      _ReactiveStatelessBuilder(
        builder: (_) => OnBuilder<S>(
          listenTo: value,
          shouldRebuild: (p0, p1) => _shouldRebuild(
            p0.data as S,
            p1.data as S,
            reduce,
            transformer,
          ),
          builder: () => builder(props: transformer(this)),
        ),
      );
}
```

```dart
class _ReactiveStatelessBuilder extends ReactiveStatelessWidget {
  const _ReactiveStatelessBuilder({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => builder(context);
}
```

```dart
P _stateToProps<S, P>(
  S state,
  Reduce<S> reduce,
  ReducedTransformer<S, P> transformer,
) =>
    transformer(ReducibleProxy(() => state, reduce, reduce));
```

```dart
bool _shouldRebuild<S, P>(
  S p0,
  S p1,
  Reduce<S> reduce,
  ReducedTransformer<S, P> transformer,
) =>
    _stateToProps(p0, reduce, transformer) !=
    _stateToProps(p1, reduce, transformer);
```

## Getting started

In the pubspec.yaml add dependencies on the package 'reduced' and on the package  'reduced_statesrebuilder'.

```
dependencies:
  reduced: ^0.1.0
  reduced_statesrebuilder: ^0.1.0
```

Import package 'reduced' to implement the logic.

```dart
import 'package:reduced/reduced.dart';
```

Import package 'reduced_statesrebuilder' to use the logic.

```dart
import 'package:reduced_statesrebuilder/reduced_statesrebuilder.dart';
```

## Usage

Implementation of the counter demo app logic with the 'reduced' API without further dependencies on state management packages.

```dart
// logic.dart

import 'package:flutter/material.dart';
import 'package:reduced/reduced.dart';

class Incrementer extends Reducer<int> {
  @override
  int call(int state) => state + 1;
}

class Props {
  Props({required this.counterText, required this.onPressed});
  final String counterText;
  final Callable<void> onPressed;
}

class PropsTransformer {
  static Props transform(Reducible<int> reducible) => Props(
        counterText: '${reducible.state}',
        onPressed: CallableAdapter(reducible, Incrementer()),
      );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.props});

  final Props props;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('reduced_statesrebuilder example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(props.counterText),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: props.onPressed,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      );
}
```

Finished counter demo app using logic.dart and 'reduced_statesrebuilder' package:

```dart
// main.dart

import 'package:flutter/material.dart';
import 'package:reduced_statesrebuilder/reduced_statesrebuilder.dart';
import 'logic.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => wrapWithProvider(
        initialState: 0,
        child: MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue),
          home: Builder(
            builder: (context) =>
                context.store<int>().wrapWithConsumer(
                      transformer: PropsTransformer.transform,
                      builder: MyHomePage.new,
                    ),
          ),
        ),
      );
}
```

# Additional information

Implementations of the 'reduced' API are available for the following state management frameworks:

|framework|implementation package for 'reduced' API|
|---|---|
|[Binder](https://pub.dev/packages/binder)|[reduced_binder](https://github.com/partmaster/reduced_binder)|
|[Bloc](https://bloclibrary.dev/#/)|[reduced_bloc](https://github.com/partmaster/reduced_bloc)|
|[GetIt](https://pub.dev/packages/get_it)|[reduced_getit](https://github.com/partmaster/reduced_getit)|
|[GetX](https://pub.dev/packages/get)|[reduced_getx](https://github.com/partmaster/reduced_getx)|
|[Provider](https://pub.dev/packages/provider)|[reduced_provider](https://github.com/partmaster/reduced_provider)|
|[Redux](https://pub.dev/packages/redux)|[reduced_redux](https://github.com/partmaster/reduced_redux)|
|[Riverpod](https://riverpod.dev/)|[reduced_riverpod](https://github.com/partmaster/reduced_riverpod)|
|[Solidart](https://pub.dev/packages/solidart)|[reduced_solidart](https://github.com/partmaster/reduced_solidart)|
|[StatesRebuilder](https://pub.dev/packages/states_rebuilder)|[reduced_statesrebuilder](https://github.com/partmaster/reduced_statesrebuilder)|
