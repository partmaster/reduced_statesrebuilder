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
    required this.child,
  });

  final S initialState;
  final Widget child;

  @override
  Widget build(BuildContext context) => StatefulInheritedValueWidget(
        converter: (rawValue) => Store(rawValue),
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
          store.reduce,
          transformer,
        ),
        builder: () => builder(props: transformer(store)),
      );
}

P _stateToProps<S, P>(
  S state,
  Reduce<S> reduce,
  ReducedTransformer<S, P> transformer,
) =>
    transformer(ReducedStoreProxy(() => state, reduce, reduce));

bool _shouldRebuild<S, P>(
  S p0,
  S p1,
  Reduce<S> reduce,
  ReducedTransformer<S, P> transformer,
) =>
    _stateToProps(p0, reduce, transformer) !=
    _stateToProps(p1, reduce, transformer);