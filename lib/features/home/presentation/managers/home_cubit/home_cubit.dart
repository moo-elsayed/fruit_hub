import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';
import 'package:fruit_hub/features/home/domain/use_cases/get_best_seller_products_use_case.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getBestSellerProductsUseCase, this._localStorageService)
    : super(HomeInitial());

  final GetBestSellerProductsUseCase _getBestSellerProductsUseCase;
  final LocalStorageService _localStorageService;

  Future<void> getBestSellerProducts() async {
    emit(GetBestSellerProductsLoading());
    var networkResponse = await _getBestSellerProductsUseCase.call();
    switch (networkResponse) {
      case NetworkSuccess<List<FruitEntity>>():
        emit(GetBestSellerProductsSuccess(networkResponse.data ?? []));
      case NetworkFailure<List<FruitEntity>>():
        emit(
          GetBestSellerProductsFailure(getErrorMessage(networkResponse).tr()),
        );
    }
  }

  String getUserName() => _localStorageService.getUsername();
}
