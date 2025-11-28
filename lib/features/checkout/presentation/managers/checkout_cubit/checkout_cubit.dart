import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late AddressEntity address;
  int paymentOption = -1;
  bool saveAddress = false;

  void setProducts(List<CartItemEntity> products) => this.products = products;

  void setAddress(AddressEntity address) {
    this.address = address;
    if (saveAddress) {
      AddressModel addressModel = AddressModel.fromEntity(address);
      _localStorageService.saveAddress(addressModel.toJson());
    }
  }

  void getAddressFromLocalStorage() {
    final addressJson = _localStorageService.getAddress();
    if (addressJson.isNotEmpty) {
      final addressModel = AddressModel.fromJson(
        addressJson as Map<String, dynamic>,
      );
      address = addressModel.toEntity();
      emit(GetAddressFromLocalStorageSuccess());
    }
  }

  void setPaymentOption(int paymentOption) =>
      this.paymentOption = paymentOption;

  void setSaveAddress(bool saveAddress) => this.saveAddress = saveAddress;
}
