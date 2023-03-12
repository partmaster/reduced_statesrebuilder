// statesrebuilder_store.dart

import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:reduced/reduced.dart';
import 'inherited_widgets.dart';

typedef EventListener<S> = void Function(
  ReducedStore<S> store,
  Event<S> event,
);

/// Implementation of the [ReducedStore] interface with injected state.
class Store<S> extends ReducedStore<S> {
  Store(S intitialValue, [EventListener<S>? onEventDispatched])
      : value = RM.inject<S>(() => intitialValue),
        _onEventDispatched = onEventDispatched;

  final Injected<S> value;
  final EventListener<S>? _onEventDispatched;

  @override
  get state => value.state;

  @override
  dispatch(event) {
    value.state = event(value.state);
    _onEventDispatched?.call(this, event);
  }
}

extension ExtensionStoreOnBuildContext on BuildContext {
  /// Convenience method for getting a [Store] instance.
  Store<S> store<S>() => InheritedValueWidget.of<Store<S>>(this);
}
