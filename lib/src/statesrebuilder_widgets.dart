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
        converter: (rawValue) => ReducedStore(rawValue, onEventDispatched),
        rawValue: initialState,
        child: child,
      );
}

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

P _stateToProps<S, P>(
  S state,
  EventProcessor<S> processor,
  StateToPropsMapper<S, P> mapper,
) =>
    mapper(state, processor);

bool _shouldRebuild<S, P>(
  S p0,
  S p1,
  EventProcessor<S> processor,
  StateToPropsMapper<S, P> mapper,
) =>
    _stateToProps(p0, processor, mapper) !=
    _stateToProps(p1, processor, mapper);
