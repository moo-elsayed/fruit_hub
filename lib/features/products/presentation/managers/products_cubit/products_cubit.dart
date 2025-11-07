import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_all_products_use_case.dart';
import 'package:meta/meta.dart';

import '../../../../../core/entities/fruit_entity.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._getAllProductsUseCase) : super(ProductsInitial());
  final GetAllProductsUseCase _getAllProductsUseCase;

  Future<void> getAllProducts() async {
    emit(GetAllProductsLoading());
    var networkResponse = await _getAllProductsUseCase.call();
    switch (networkResponse) {
      case NetworkSuccess<List<FruitEntity>>():
        emit(GetAllProductsSuccess(networkResponse.data ?? []));
      case NetworkFailure<List<FruitEntity>>():
        emit(GetAllProductsFailure(getErrorMessage(networkResponse).tr()));
    }
  }
}
