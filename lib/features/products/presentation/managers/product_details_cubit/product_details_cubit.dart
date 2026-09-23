import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_product_details_use_case.dart';

part 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({required this.getProductDetailsUseCase})
    : super(ProductDetailsInitial());

  final GetProductDetailsUseCase getProductDetailsUseCase;

  Future<void> getProductDetails(String code) async {
    emit(ProductDetailsLoading());
    final networkResponse = await getProductDetailsUseCase(code);
    switch (networkResponse) {
      case NetworkSuccess<FruitEntity>():
        emit(ProductDetailsSuccess(networkResponse.data!));
      case NetworkFailure<FruitEntity>():
        emit(ProductDetailsFailure(networkResponse.error));
    }
  }

  void updateProduct(FruitEntity updatedFruit) {
    emit(ProductDetailsSuccess(updatedFruit));
  }
}
