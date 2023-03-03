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

class _ReactiveStatelessBuilder extends ReactiveStatelessWidget {
  const _ReactiveStatelessBuilder({required this.builder});

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
