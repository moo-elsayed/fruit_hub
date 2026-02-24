import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_all_products_use_case.dart';

import '../../../../../core/entities/fruit_entity.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._getAllProductsUseCase) : super(ProductsInitial());
  final GetAllProductsUseCase _getAllProductsUseCase;

  List<FruitEntity> _originalFruits = [];
  List<FruitEntity> fruits = [];
  int selectedSortOption = -1;
  List<String> sortOptions = [
    "price_lowest_to_highest".tr(),
    "price_highest_to_lowest".tr(),
    "alphabetical".tr(),
  ];

  Future<void> getAllProducts() async {
    emit(GetAllProductsLoading());
    var networkResponse = await _getAllProductsUseCase.call();
    switch (networkResponse) {
      case NetworkSuccess<List<FruitEntity>>():
        _originalFruits = networkResponse.data ?? [];
        fruits = List.from(_originalFruits);
        emit(GetAllProductsSuccess(_originalFruits));
      case NetworkFailure<List<FruitEntity>>():
        emit(GetAllProductsFailure(getErrorMessage(networkResponse).tr()));
    }
  }

  void sortProducts(int selectedSortOption) {
    this.selectedSortOption = selectedSortOption;
    List<FruitEntity> sortedList = List.from(fruits);
    switch (selectedSortOption) {
      case 0:
        sortedList.sort((a, b) => a.price.compareTo(b.price));
      case 1:
        sortedList.sort((a, b) => b.price.compareTo(a.price));
      case 2:
        sortedList.sort((a, b) => a.name.compareTo(b.name));
      default:
        break;
    }
    fruits = sortedList;
    emit(GetAllProductsSuccess(sortedList));
  }

  void resetSorting() {
    selectedSortOption = -1;
    emit(GetAllProductsSuccess(List.from(_originalFruits)));
  }
}
