import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/reviews_cubit/reviews_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/add_review_bottom_sheet.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/empty_reviews_widget.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/rating_summary_card.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/review_card.dart';
import 'package:gap/gap.dart';

class ReviewsView extends StatelessWidget {
  const ReviewsView({super.key, required this.fruit});

  final FruitEntity fruit;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReviewsCubit>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomAppBar(
        title: '${fruit.name} - ${AppStrings.reviews}',
        showArrowBack: true,
      ),
      body: BlocBuilder<ReviewsCubit, ReviewsState>(
        builder: (context, state) {
          final reviews = cubit.reviews;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(16.r),
                sliver: SliverToBoxAdapter(
                  child: RatingSummaryCard(
                    avgRating: cubit.avgRating,
                    ratingCount: cubit.ratingCount,
                    reviews: reviews,
                  ),
                ),
              ),
              if (reviews.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyReviewsWidget(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    bottom: 24.h,
                  ),
                  sliver: SliverList.separated(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) =>
                        ReviewCard(review: reviews[index]),
                    separatorBuilder: (context, index) => Gap(12.h),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ReviewsCubit, ReviewsState>(
        builder: (context, state) {
          if (cubit.isCheckingEligibility) {
            return const SizedBox.shrink();
          }

          if (cubit.hasAlreadyReviewed) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(top: BorderSide(color: context.colors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: context.colors.primary,
                    size: 18.sp,
                  ),
                  Gap(8.w),
                  Flexible(
                    child: Text(
                      AppStrings.alreadyReviewedProduct,
                      style: AppTextStyles.font13Medium.copyWith(
                        color: context.colors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          if (cubit.isVerifiedBuyer) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(top: BorderSide(color: context.colors.border)),
              ),
              child: CustomMaterialButton(
                maxWidth: true,
                onPressed: () =>
                    AddReviewBottomSheet.show(context, reviewsCubit: cubit),
                text: AppStrings.writeReview,
                icon: Icon(
                  Icons.rate_review_outlined,
                  color: Colors.white,
                  size: 20.sp,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
            );
          }

          // Not a verified buyer: display verified buyer policy message
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(top: BorderSide(color: context.colors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: context.colors.subText,
                  size: 18.sp,
                ),
                Gap(8.w),
                Flexible(
                  child: Text(
                    AppStrings.onlyBuyersCanReview,
                    style: AppTextStyles.font12Regular.copyWith(
                      color: context.colors.subText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
