import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/home/domain/repo/home_repo.dart';

class GetAllProductsUseCase {
  GetAllProductsUseCase(this._homeRepo);

  final HomeRepo _homeRepo;

  Future<NetworkResponse<List<FruitEntity>>> call() async =>
      await _homeRepo.getAllProducts();
}
