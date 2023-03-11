import 'package:flutter_test/flutter_test.dart';
import 'package:reduced/reduced.dart';

import 'package:reduced_statesrebuilder/reduced_statesrebuilder.dart';

class CounterIncremented extends Event<int> {
  @override
  int call(int state) => state + 1;
}

void main() {
  test('Store state 0', () {
    final objectUnderTest = Store(0);
    expect(objectUnderTest.state, 0);
  });

  test('Store state 1', () {
    final objectUnderTest = Store(1);
    expect(objectUnderTest.state, 1);
  });

  test('Store dispatch', () async {
    final objectUnderTest = Store(0);
    objectUnderTest.dispatch(CounterIncremented());
    expect(objectUnderTest.state, 1);
  });
}
