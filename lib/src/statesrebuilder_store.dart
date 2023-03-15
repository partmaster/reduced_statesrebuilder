// statesrebuilder_store.dart

import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:reduced/reduced.dart';
import 'inherited_widgets.dart';

/// Implementation of the [Store] interface with injected state.
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

extension ExtensionStoreOnBuildContext on BuildContext {
  /// Convenience method for getting a [ReducedStore] instance.
  ReducedStore<S> store<S>() => InheritedValueWidget.of<ReducedStore<S>>(this);
}
