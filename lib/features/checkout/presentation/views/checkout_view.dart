import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/checkout_steps.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_material_button.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  int currentIndex = 0;
  late PageController _pageController;

  List<String> get buttonTexts => [
    "next".tr(),
    "next".tr(),
    "confirm_and_continue".tr(),
    "confirm_order".tr(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "shipping".tr(),
        showArrowBack: true,
        onTap: () => context.pop(),
      ),
      body: Column(
        children: [
          Gap(16.h),
          CheckoutSteps(currentIndex: currentIndex),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: buttonTexts.length,
              onPageChanged: (value) => setState(() => currentIndex = value),
              itemBuilder: (context, index) {
                return Container();
              },
            ),
          ),
          CustomMaterialButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            text: buttonTexts[currentIndex],
            textStyle: AppTextStyles.font16WhiteBold,
          ),
        ],
      ),
    );
  }
}
