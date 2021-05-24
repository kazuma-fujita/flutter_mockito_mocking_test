import 'package:flutter_mockito_mocking_test/cat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cat_test.mocks.dart';

@GenerateMocks([Cat])
void main() {
  final cat = MockCat();

  test('Testing cat sound method.', () {
    // Stub a mock method before interacting.
    // Set the return value of the mock method.
    when(cat.sound()).thenReturn('Meow');
    // Make sure the mock method is not called.
    verifyNever(cat.sound());
    // Testing a stubbed mock method.
    expect(cat.sound(), 'Meow');
    // Make sure the mock method is called.
    verify(cat.sound());
    // You can call it again.
    expect(cat.sound(), 'Meow');
    // Let's change the stub.
    when(cat.sound()).thenReturn('Purr');
    expect(cat.sound(), 'Purr');
    // We can calculate a response at call time.
    final responses = ['Mew', 'Purr', 'Meow'];
    when(cat.sound()).thenAnswer((_) => responses.removeAt(0));
    expect(cat.sound(), 'Mew');
    expect(cat.sound(), 'Purr');
    expect(cat.sound(), 'Meow');
  });

  test('Testing cat lives getters.', () {
    // You can stub getters.
    when(cat.lives).thenReturn(9);
    // Testing a stubbed mock getters.
    expect(cat.lives, 9);
    // Make sure the mock getters is called.
    verify(cat.lives);
    // Let's change the stub.
    when(cat.lives).thenReturn(12);
    expect(cat.lives, 12);
  });

  test('Testing exceptions.', () {
    // You can stub a method to throw.
    when(cat.lives).thenThrow(RangeError('It\'s beyond a cat\'s live span.'));
    // Testing a stubbed mock getters.
    expect(() => cat.lives, throwsRangeError);
    // Make sure the mock getters is called.
    verify(cat.lives);
    // You can stub a method to throw.
    when(cat.sound()).thenThrow(Exception('This method has been deprecated.'));
    // Testing a stubbed mock method.
    expect(cat.sound, throwsException);
    // Make sure the mock getters is called.
    verify(cat.sound());
  });

  test('Testing future method.', () async {
    when(cat.yawn()).thenAnswer((_) async => 'Yawning...');
    expect(await cat.yawn(), 'Yawning...');
    verify(cat.yawn());
  });

  test('Testing argument matchers.', () {
    // Matches characters that begin with dry.
    when(cat.eatFood(argThat(startsWith('dry')))).thenReturn(true);
    expect(cat.eatFood('dry food'), isTrue);
    verify(cat.eatFood('dry food'));
    // Matches characters that end with fish.
    when(cat.eatFood(argThat(endsWith('fish')))).thenReturn(true);
    expect(cat.eatFood('big fish'), isTrue);
    verify(cat.eatFood('big fish'));
    // Or mix arguments with matchers
    when(cat.eatFood(argThat(endsWith('meat')), hungry: true)).thenReturn(true);
    expect(cat.eatFood('big meat', hungry: true), isTrue);
    // You can also verify using an argument matcher.
    verify(cat.eatFood(argThat(contains('big')), hungry: true));
    // You can use any argument to match any.
    when(cat.eatFood(any)).thenReturn(false);
    expect(cat.eatFood('many mice'), isFalse);
    verify(cat.eatFood('many mice'));
  });

  test('Testing named arguments.', () {
    // GOOD: argument matchers include their names.
    // anyNamed pattern
    when(cat.eatFood(any, hungry: anyNamed('hungry'))).thenReturn(true);
    expect(cat.eatFood('minnie mouse', hungry: true), isTrue);
    verify(cat.eatFood('minnie mouse', hungry: true));
    // argThat pattern
    when(cat.eatFood(any, hungry: argThat(isNotNull, named: 'hungry')))
        .thenReturn(false);
    expect(cat.eatFood('mickey mouse', hungry: false), isFalse);
    verify(cat.eatFood('mickey mouse', hungry: false));
    // captureAnyNamed pattern
    when(cat.eatFood(any, hungry: captureAnyNamed('hungry'))).thenReturn(true);
    expect(cat.eatFood('donald duck', hungry: true), isTrue);
    verify(cat.eatFood('donald duck', hungry: true));
    // captureThat pattern
    when(cat.eatFood(any, hungry: captureThat(isNotNull, named: 'hungry')))
        .thenReturn(false);
    expect(cat.eatFood('donald duck', hungry: false), isFalse);
    verify(cat.eatFood('donald duck', hungry: false));
  });

  test('Use verify or verifyNever.', () {
    // The cat sound method will be called twice.
    when(cat.sound()).thenReturn('Mew');
    cat.sound();
    cat.sound();
    // Exact number of invocations
    verify(cat.sound()).called(2);

    // The cat hunt method will be called twice.
    when(cat.hunt(any, any));
    cat.hunt('backyard', 'many mice');
    cat.hunt('backyard', 'many mice');
    // Or using matcher
    verify(cat.hunt(argThat(contains('yard')), argThat(endsWith('mice'))))
        .called(greaterThan(1));

    // Or never called
    verifyNever(cat.eatFood(any));
  });

  test('Testing verification in order.', () {
    when(cat.eatFood(any)).thenReturn(true);
    when(cat.sound()).thenReturn('Mew');
    cat.eatFood('milk');
    cat.sound();
    cat.eatFood('fish');
    verifyInOrder([cat.eatFood('milk'), cat.sound(), cat.eatFood('fish')]);
  });

  test('Capturing arguments for further assertions.', () {
    when(cat.eatFood(any)).thenReturn(true);
    cat.eatFood('fish');
    expect(verify(cat.eatFood(captureAny)).captured.single, 'fish');
    cat.eatFood('milk');
    cat.eatFood('fish');
    expect(verify(cat.eatFood(captureAny)).captured, ['milk', 'fish']);
    cat.eatFood('donald duck');
    cat.eatFood('mickey mouse');
    cat.eatFood('minnie mouse');
    expect(
        verify(cat.eatFood(captureThat(startsWith('donald')))).captured.single,
        'donald duck');
    expect(verify(cat.eatFood(captureThat(endsWith('mouse')))).captured,
        ['mickey mouse', 'minnie mouse']);
  });

  test('Waiting for an interaction.', () async {
    cat.chew();
    await untilCalled(cat.chew());
    verify(cat.chew());
  });

  test('Clearing collected interactions.', () {
    // Clearing collected interactions:
    when(cat.eatFood('fish')).thenReturn(true);
    cat.eatFood('fish');
    clearInteractions(cat);
    cat.eatFood('fish');
    verify(cat.eatFood('fish')).called(1);
  });

  test('Resetting mocks.', () {
    // Resetting stubs and collected interactions:
    when(cat.eatFood('fish')).thenReturn(true);
    cat.eatFood('fish');
    reset(cat);
    when(cat.eatFood(any)).thenReturn(false);
    expect(cat.eatFood('fish'), false);
    verify(cat.eatFood('fish')).called(1);
  });

  test('Testing setters method.', () {
    // You can verify setters.
    cat.lives = 9;
    verify(cat.lives = 9);
  });
}
