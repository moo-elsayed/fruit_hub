import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_logger.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/features/checkout/data/models/address_model.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/add_order_use_case.dart';
import '../../../../../core/entities/cart_item_entity.dart';
import '../../../../../core/helpers/network_response.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/payment_option_entity.dart';
import '../../../domain/entities/shipping_config_entity.dart';
import '../../../domain/use_cases/fetch_shipping_config_use_case.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(
    this._localStorageService,
    this._fetchShippingConfigUseCase,
    this._addOrderUseCase,
  ) : super(CheckoutInitial());

  final AppPreferencesManager _localStorageService;
  final FetchShippingConfigUseCase _fetchShippingConfigUseCase;
  final AddOrderUseCase _addOrderUseCase;
  late List<CartItemEntity> products;
  AddressEntity? address;
  PaymentOptionEntity? paymentOption;
  bool saveAddress = true;
  ShippingConfigEntity? shippingConfig;

  OrderEntity get orderEntity => OrderEntity(
    uid: _localStorageService.getUid(),
    orderId: _generateOrderId(),
    products: products,
    address: address!,
    paymentOption: paymentOption!,
  );

  Future<void> addOrder() async {
    emit(AddOrderLoading());
    final result = await _addOrderUseCase(orderEntity);
    switch (result) {
      case NetworkSuccess<void>():
        emit(AddOrderSuccess());
      case NetworkFailure<void>():
        emit(AddOrderFailure(getErrorMessage(result)));
    }
  }

  Future<void> fetchShippingConfig() async {
    final result = await _fetchShippingConfigUseCase();
    switch (result) {
      case NetworkSuccess<ShippingConfigEntity>():
        shippingConfig = result.data;
      case NetworkFailure<ShippingConfigEntity>():
        AppLogger.error(getErrorMessage(result).tr());
    }
  }

  void setProducts(List<CartItemEntity> products) => this.products = products;

  void setAddress(AddressEntity address) {
    this.address = address;
    if (saveAddress) {
      _saveAddressToLocalStorage(address);
    }
  }

  void getAddressFromLocalStorage() {
    final addressJson = _localStorageService.getAddress();
    if (addressJson.isNotEmpty) {
      try {
        var myMap = jsonDecode(addressJson);
        final addressModel = AddressModel.fromJson(myMap);
        address = addressModel.toEntity();
      } catch (e) {
        AppLogger.error(e.toString());
      }
    }
  }

  void setPaymentOption(PaymentOptionEntity paymentOption) =>
      this.paymentOption = paymentOption;

  void setSaveAddress(bool saveAddress) => this.saveAddress = saveAddress;

  double get subtotal => products.fold(
    0,
    (previousValue, element) => previousValue + element.totalPrice,
  );

  // -----------------------------------------------

  void _saveAddressToLocalStorage(AddressEntity address) {
    AddressModel addressModel = AddressModel.fromEntity(address);
    _localStorageService.saveAddress(addressModel.toJson());
  }

  int _generateOrderId() {
    int id = DateTime.now().microsecondsSinceEpoch % 1000000;
    if (id < 100000) {
      id += 100000;
    }
    return id;
  }
}
