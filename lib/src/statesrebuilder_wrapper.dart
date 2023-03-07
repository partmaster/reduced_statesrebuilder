// statesrebuilder_wrapper.dart

import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:reduced/reduced.dart';
import 'inherited_widgets.dart';
import 'statesrebuilder_reducible.dart';

Widget wrapWithProvider<S>({
  required S initialState,
  required Widget child,
}) =>
    StatefulInheritedValueWidget(
      converter: (rawValue) => Store(rawValue),
      rawValue: initialState,
      child: child,
    );

Widget wrapWithConsumer<S, P>({
  required ReducedTransformer<S, P> transformer,
  required ReducedWidgetBuilder<P> builder,
}) =>
    Builder(
      builder: (context) => internalWrapWithConsumer(
        store: context.store<S>(),
        transformer: transformer,
        builder: builder,
      ),
    );

@visibleForTesting
ReactiveStatelessBuilder internalWrapWithConsumer<S, P>({
  required Store<S> store,
  required ReducedTransformer<S, P> transformer,
  required ReducedWidgetBuilder<P> builder,
}) =>
    ReactiveStatelessBuilder(
      builder: (_) => OnBuilder<S>(
        listenTo: store.value,
        shouldRebuild: (p0, p1) => _shouldRebuild(
          p0.data as S,
          p1.data as S,
          store.reduce,
          transformer,
        ),
        builder: () => builder(props: transformer(store)),
      ),
    );

class ReactiveStatelessBuilder extends ReactiveStatelessWidget {
  const ReactiveStatelessBuilder({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => builder(context);
}

P _stateToProps<S, P>(
  S state,
  Reduce<S> reduce,
  ReducedTransformer<S, P> transformer,
) =>
    transformer(ReducibleProxy(() => state, reduce, reduce));

bool _shouldRebuild<S, P>(
  S p0,
  S p1,
  Reduce<S> reduce,
  ReducedTransformer<S, P> transformer,
) =>
    _stateToProps(p0, reduce, transformer) !=
    _stateToProps(p1, reduce, transformer);
