import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/search/domain/use_cases/search_fruits_use_case.dart';
import 'package:fruit_hub/features/search/presentation/widgets/search_view_body.dart';
import '../managers/search_cubit/search_cubit.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "search".tr(),
        showArrowBack: true,
        onTap: () => context.pop(),
      ),
      body: BlocProvider(
        create: (context) => SearchCubit(getIt.get<SearchFruitsUseCase>()),
        child: const SearchViewBody(),
      ),
    );
  }
}
