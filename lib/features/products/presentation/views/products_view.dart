import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_grid_view_section.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_header_bar.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().fetchFirstPage();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: AppStrings.ourProducts,
      showArrowBack: true,
      onTap: () => context.pop(),
    ),
    body: const Column(
      children: [
        ProductsHeaderBar(),
        Expanded(child: ProductsGridViewSection()),
      ],
    ),
  );
}
