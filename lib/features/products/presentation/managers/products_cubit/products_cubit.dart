import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/domain/entities/paginated_products_entity.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_all_products_use_case.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit({required this.getAllProductsUseCase})
    : super(ProductsInitial());

  final GetAllProductsUseCase getAllProductsUseCase;

  ProductsFilterEntity currentFilter = const ProductsFilterEntity();
  dynamic _lastDoc;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<FruitEntity> _fruits = [];

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> fetchFirstPage({ProductsFilterEntity? filter}) async {
    if (filter != null) {
      currentFilter = filter;
    }
    _lastDoc = null;
    _hasMore = true;
    _fruits = [];
    emit(GetProductsLoading());

    final networkResponse = await getAllProductsUseCase.call(
      limit: 10,
      filter: currentFilter,
    );

    switch (networkResponse) {
      case NetworkSuccess<PaginatedProductsEntity>():
        _handleSuccess(networkResponse.data!, isFirstPage: true);
      case NetworkFailure<PaginatedProductsEntity>():
        emit(GetProductsFailure(networkResponse.error));
    }
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore || _isLoadingMore || state is! GetProductsSuccess) return;

    _isLoadingMore = true;
    emit((state as GetProductsSuccess).copyWith(isLoadingMore: true));

    final networkResponse = await getAllProductsUseCase.call(
      lastDoc: _lastDoc,
      limit: 10,
      filter: currentFilter,
    );

    _isLoadingMore = false;

    switch (networkResponse) {
      case NetworkSuccess<PaginatedProductsEntity>():
        _handleSuccess(networkResponse.data!);
      case NetworkFailure<PaginatedProductsEntity>():
        emit((state as GetProductsSuccess).copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async => fetchFirstPage();

  void applyFilter(ProductsFilterEntity filter) {
    currentFilter = filter;
    fetchFirstPage(filter: filter);
  }

  void setCategoryFilter(ProductCategoryFilter category) {
    if (currentFilter.categoryFilter == category) return;
    applyFilter(currentFilter.copyWith(categoryFilter: category));
  }

  void resetFilter() {
    currentFilter = const ProductsFilterEntity();
    fetchFirstPage(filter: currentFilter);
  }

  void updateProduct(FruitEntity updatedFruit) {
    final index = _fruits.indexWhere((f) => f.code == updatedFruit.code);
    if (index != -1) {
      _fruits[index] = updatedFruit;
      if (state is GetProductsSuccess) {
        emit(
          (state as GetProductsSuccess).copyWith(fruits: List.from(_fruits)),
        );
      }
    }
  }

  void _handleSuccess(
    PaginatedProductsEntity data, {
    bool isFirstPage = false,
  }) {
    if (isFirstPage) {
      _fruits = List.from(data.fruits);
    } else {
      _fruits.addAll(data.fruits);
    }
    _lastDoc = data.lastDoc;
    _hasMore = data.hasMore;
    emit(
      GetProductsSuccess(
        fruits: List.from(_fruits),
        hasMore: _hasMore,
        isLoadingMore: false,
        filter: currentFilter,
      ),
    );
  }
}
