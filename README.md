![GitHub release (latest by date)](https://img.shields.io/github/v/release/partmaster/reduced_statesrebuilder)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/partmaster/reduced_statesrebuilder/dart.yml)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/partmaster/reduced_statesrebuilder)
![GitHub last commit](https://img.shields.io/github/last-commit/partmaster/reduced_statesrebuilder)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/partmaster/reduced_statesrebuilder)
# reduced_statesrebuilder

Implementation of the 'reduced' API for the 'statesrebuilder' state management framework with following features:

1. Implementation of the ```Store``` interface 
2. Extension on the ```BuildContext``` for convenient access to the  ```Store``` instance.
3. Register a state for management.
4. Trigger a rebuild on widgets selectively after a state change.

## Features

#### 1. Implementation of the ```Store``` interface 

```dart
class ReducedStore<S> extends Store<S> {
  ReducedStore(S intitialValue, [EventListener<S>? onEventDispatched])
      : value = RM.inject<S>(() => intitialValue),
        _onEventDispatched = onEventDispatched;

  final Injected<S> value;
  final EventListener<S>? _onEventDispatched;

  @override
  get state => value.state;

  @override
  process(event) {
    value.state = event(value.state);
    _onEventDispatched?.call(this, event, UniqueKey());
  }
}
```

#### 2. Extension on the ```BuildContext``` for convenient access to the  ```Store``` instance.

```dart
extension ExtensionStoreOnBuildContext on BuildContext {
  ReducedStore<S> store<S>() => InheritedValueWidget.of<ReducedStore<S>>(this);
}
```

#### 3. Register a state for management.

```dart
class ReducedProvider<S> extends StatelessWidget {
  const ReducedProvider({
    super.key,
    required this.initialState,
    this.onEventDispatched,
    required this.child,
  });

  final S initialState;
  final Widget child;
  final EventListener<S>? onEventDispatched;

  @override
  Widget build(BuildContext context) => StatefulInheritedValueWidget(
        converter: (rawValue) => ReducedStore(rawValue, onEventDispatched),
        rawValue: initialState,
        child: child,
      );
}
```

#### 4. Trigger a rebuild on widgets selectively after a state change.

```dart
class ReducedConsumer<S, P> extends ReactiveStatelessWidget {
  const ReducedConsumer({
    super.key,
    required this.mapper,
    required this.builder,
  });

  final StateToPropsMapper<S, P> mapper;
  final WidgetFromPropsBuilder<P> builder;

  @override
  Widget build(BuildContext context) => _build(context.store<S>());

  Widget _build(ReducedStore<S> store) => OnBuilder<S>(
        listenTo: store.value,
        shouldRebuild: (p0, p1) => _shouldRebuild(
          p0.data as S,
          p1.data as S,
          store,
          mapper,
        ),
        builder: () => builder(props: mapper(store.state, store)),
      );
}
```

```dart
P _stateToProps<S, P>(
  S state,
  EventProcessor<S> processor,
  StateToPropsMapper<S, P> mapper,
) =>
    mapper(state, processor);
```

```dart
bool _shouldRebuild<S, P>(
  S p0,
  S p1,
  EventProcessor<S> processor,
  StateToPropsMapper<S, P> mapper,
) =>
    _stateToProps(p0, processor, mapper) !=
    _stateToProps(p1, processor, mapper);
```

## Getting started

In the pubspec.yaml add dependencies on the package 'reduced' and on the package  'reduced_statesrebuilder'.

```
dependencies:
  reduced: 0.4.0
  reduced_statesrebuilder: 
    git:
      url: https://github.com/partmaster/reduced_statesrebuilder.git
      ref: v0.4.0
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
import 'package:reduced/callbacks.dart';

class CounterIncremented extends Event<int> {
  @override
  int call(int state) => state + 1;
}

class Props {
  const Props({required this.counterText, required this.onPressed});

  final String counterText;
  final VoidCallable onPressed;
}

class PropsMapper extends Props {
  PropsMapper(int state, EventProcessor<int> processor)
      : super(
          counterText: '$state',
          onPressed: EventCarrier(processor, CounterIncremented()),
        );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.props});

  final Props props;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('reduced_setstate example'),
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
  Widget build(BuildContext context) => ReducedProvider(
        initialState: 0,
        child: MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const ReducedConsumer(
            mapper: PropsMapper.new,
            builder: MyHomePage.new,
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
|[FlutterCommand](https://pub.dev/packages/flutter_command)|[reduced_fluttercommand](https://github.com/partmaster/reduced_fluttercommand)|
|[FlutterTriple](https://pub.dev/packages/flutter_triple)|[reduced_fluttertriple](https://github.com/partmaster/reduced_fluttertriple)|
|[GetIt](https://pub.dev/packages/get_it)|[reduced_getit](https://github.com/partmaster/reduced_getit)|
|[GetX](https://pub.dev/packages/get)|[reduced_getx](https://github.com/partmaster/reduced_getx)|
|[MobX](https://pub.dev/packages/mobx)|[reduced_mobx](https://github.com/partmaster/reduced_mobx)|
|[Provider](https://pub.dev/packages/provider)|[reduced_provider](https://github.com/partmaster/reduced_provider)|
|[Redux](https://pub.dev/packages/redux)|[reduced_redux](https://github.com/partmaster/reduced_redux)|
|[Riverpod](https://riverpod.dev/)|[reduced_riverpod](https://github.com/partmaster/reduced_riverpod)|
|[Solidart](https://pub.dev/packages/solidart)|[reduced_solidart](https://github.com/partmaster/reduced_solidart)|
|[StatesRebuilder](https://pub.dev/packages/states_rebuilder)|[reduced_statesrebuilder](https://github.com/partmaster/reduced_statesrebuilder)|
