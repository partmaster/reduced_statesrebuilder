// statesrebuilder_store.dart

import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:reduced/reduced.dart';
import 'inherited_widgets.dart';

/// Implementation of the [ReducedStore] interface with injected state.
class Store<S> extends ReducedStore<S> {
  Store(S intitialValue) : value = RM.inject<S>(() => intitialValue);

  final Injected<S> value;

  @override
  get state => value.state;

  @override
  reduce(reducer) => value.state = reducer(value.state);
}

extension ExtensionStoreOnBuildContext on BuildContext {
  /// Convenience method for getting a [Store] instance.
  Store<S> store<S>() => InheritedValueWidget.of<Store<S>>(this);
}
