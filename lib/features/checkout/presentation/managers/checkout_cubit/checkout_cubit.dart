import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_logger.dart';
import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';
import 'package:fruit_hub/features/checkout/data/models/address_model.dart';
import '../../../../../core/entities/cart_item_entity.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/payment_option_entity.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._localStorageService) : super(CheckoutInitial());

  final LocalStorageService _localStorageService;
  late List<CartItemEntity> products;
  AddressEntity? address;
  PaymentOptionEntity? paymentOption;
  bool saveAddress = true;

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
}
