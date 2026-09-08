import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';

import '../managers/track_order_cubit/track_order_cubit.dart';
import '../widgets/track_order_view_body.dart';

class TrackOrderView extends StatelessWidget {
  const TrackOrderView({super.key, this.order, this.orderId});

  final OrderEntity? order;
  final String? orderId;

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.pushNamedAndRemoveUntil(
        Routes.mainView,
        predicate: (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) => BlocProvider<TrackOrderCubit>(
    create: (context) => getIt<TrackOrderCubit>(param1: order, param2: orderId),
    child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: AppStrings.trackOrder,
          showArrowBack: true,
          onTap: () => _handleBack(context),
        ),
        body: const TrackOrderViewBody(),
      ),
    ),
  );
}
