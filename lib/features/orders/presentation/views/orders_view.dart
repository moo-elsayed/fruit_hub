import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';

import '../managers/orders_cubit/orders_cubit.dart';
import '../widgets/orders_view_body.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<OrdersCubit>(
    create: (context) => getIt<OrdersCubit>()..streamOrders(),
    child: Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.myOrders,
        showArrowBack: true,
        onTap: () => context.pop(),
      ),
      body: const OrdersViewBody(),
    ),
  );
}
