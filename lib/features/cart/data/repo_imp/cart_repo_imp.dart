import 'package:fruit_hub/features/cart/data/data_sources/cart_remote_data_source.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import '../../../../core/helpers/network_response.dart';

class CartRepoImp implements CartRepo {
  CartRepoImp(this._cartRemoteDataSource);

  final CartRemoteDataSource _cartRemoteDataSource;

  @override
  Future<NetworkResponse<void>> addItemToCart(CartItemEntity item) async =>
      await _cartRemoteDataSource.addItemToCart(item);

  @override
  Future<NetworkResponse<void>> removeItemFromCart(String productId) async =>
      await _cartRemoteDataSource.removeItemFromCart(productId);
}
