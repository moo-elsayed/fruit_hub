import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';

class BestSellerView extends StatelessWidget {
  const BestSellerView({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "best_seller".tr(),
        showArrowBack: true,
        showNotification: true,
        onTap: () => context.pop(),
      ),
      body: FruitsGridView(scrollController: scrollController),
    );
  }
}
