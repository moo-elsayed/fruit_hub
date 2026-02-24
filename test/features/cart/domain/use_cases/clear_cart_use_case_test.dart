import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/clear_cart_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late ClearCartUseCase sut;
  late MockCartRepo mockCartRepo;

  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = ClearCartUseCase(mockCartRepo);
  });

  group('ClearCartUseCase', () {
    test(
      'should call clearCart from repo with correct params when success response',
      () async {
        // Arrange
        when(
          () => mockCartRepo.clearCart(),
        ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
        // Act
        var result = await sut();
        // Assert
        expect(result, tSuccessResponseOfTypeVoid);
        verify(() => mockCartRepo.clearCart()).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );
    test(
      'should return failure when clearCart from repo returns failure response',
      () async {
        // Arrange
        when(
          () => mockCartRepo.clearCart(),
        ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        // Act
        var result = await sut();
        // Assert
        expect(result, tFailureResponseOfTypeVoid);
        expect(getErrorMessage(result), "permission-denied");
        verify(() => mockCartRepo.clearCart()).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );
  });
}
