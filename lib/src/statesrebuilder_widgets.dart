// statesrebuilder_widgets.dart

import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:reduced/reduced.dart';

import 'inherited_widgets.dart';
import 'statesrebuilder_store.dart';

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
        converter: (rawValue) => Store(rawValue, onEventDispatched),
        rawValue: initialState,
        child: child,
      );
}

class ReducedConsumer<S, P> extends ReactiveStatelessWidget {
  const ReducedConsumer({
    super.key,
    required this.transformer,
    required this.builder,
  });

  final ReducedTransformer<S, P> transformer;
  final ReducedWidgetBuilder<P> builder;

  @override
  Widget build(BuildContext context) => _build(context.store<S>());

  Widget _build(Store<S> store) => OnBuilder<S>(
        listenTo: store.value,
        shouldRebuild: (p0, p1) => _shouldRebuild(
          p0.data as S,
          p1.data as S,
          store.dispatch,
          transformer,
        ),
        builder: () => builder(props: transformer(store)),
      );
}

P _stateToProps<S, P>(
  S state,
  Dispatcher<S> dispatcher,
  ReducedTransformer<S, P> transformer,
) =>
    transformer(ReducedStoreProxy(() => state, dispatcher, dispatcher));

bool _shouldRebuild<S, P>(
  S p0,
  S p1,
  Dispatcher<S> dispatcher,
  ReducedTransformer<S, P> transformer,
) =>
    _stateToProps(p0, dispatcher, transformer) !=
    _stateToProps(p1, dispatcher, transformer);
