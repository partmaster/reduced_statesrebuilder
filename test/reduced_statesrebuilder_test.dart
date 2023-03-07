import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reduced/reduced.dart';

import 'package:reduced_statesrebuilder/reduced_statesrebuilder.dart';
import 'package:reduced_statesrebuilder/src/inherited_widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Incrementer extends Reducer<int> {
  @override
  int call(int state) {
    return state + 1;
  }
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

  test('Store reduce', () async {
    final objectUnderTest = Store(0);
    objectUnderTest.reduce(Incrementer());
    expect(objectUnderTest.state, 1);
  });
}
