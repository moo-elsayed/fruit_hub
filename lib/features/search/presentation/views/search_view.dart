import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/search/presentation/widgets/search_view_body.dart';
import '../managers/search_cubit/search_cubit.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: AppStrings.search,
      showArrowBack: true,
      onTap: () => context.pop(),
    ),
    body: BlocProvider(
      create: (context) => getIt.get<SearchCubit>(),
      child: const SearchViewBody(),
    ),
  );
}
