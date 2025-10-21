import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import '../../../../../core/helpers/network_response.dart';
import '../../../domain/use_cases/search_fruits_use_case.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchFruitsUseCase) : super(SearchInitial());

  final SearchFruitsUseCase _searchFruitsUseCase;

  Future<void> searchProducts(String query) async {
    emit(SearchLoading());
    final result = await _searchFruitsUseCase.call(query);
    switch (result) {
      case NetworkSuccess<List<FruitEntity>>():
        emit(SearchSuccess(result.data ?? []));
      case NetworkFailure<List<FruitEntity>>():
        emit(SearchFailure(getErrorMessage(result)));
    }
  }
}
