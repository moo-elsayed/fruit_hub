import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_keyboard_unfocus.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/reviews_cubit/reviews_cubit.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';

class AddReviewBottomSheet extends StatefulWidget {
  const AddReviewBottomSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required ReviewsCubit reviewsCubit,
  }) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: reviewsCubit,
      child: const AddReviewBottomSheet(),
    ),
  );

  @override
  State<AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<AddReviewBottomSheet> {
  final ValueNotifier<int> _ratingNotifier = ValueNotifier<int>(5);
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _ratingNotifier.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _getRatingLabel(int stars) => switch (stars) {
    5 => AppStrings.excellent,
    4 => AppStrings.veryGood,
    3 => AppStrings.good,
    2 => AppStrings.fair,
    _ => AppStrings.poor,
  };

  void _submit() {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email ?? 'User';
    final userImage = user?.photoURL;

    context.read<ReviewsCubit>().submitReview(
      rating: _ratingNotifier.value.toDouble(),
      comment: _commentController.text,
      userName: userName,
      userImage: userImage,
    );
  }

  @override
  Widget build(BuildContext context) => CustomKeyboardUnfocus(
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: BlocConsumer<ReviewsCubit, ReviewsState>(
          listener: (context, state) {
            if (state is AddReviewSuccess) {
              AppToast.show(
                context: context,
                title: AppStrings.reviewAddedSuccessfully,
                type: ToastificationType.success,
              );
              context.pop();
            } else if (state is AddReviewFailure) {
              AppToast.show(
                context: context,
                title: state.errorMessage,
                type: ToastificationType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AddReviewLoading;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag Handle
                Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Gap(16.h),
                Text(
                  AppStrings.writeReview,
                  style: AppTextStyles.font18Bold.copyWith(
                    color: context.colors.mainText,
                  ),
                ),
                Gap(16.h),
                // Interactive Stars
                ValueListenableBuilder<int>(
                  valueListenable: _ratingNotifier,
                  builder: (context, currentStars, _) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starNumber = index + 1;
                          final isSelected = starNumber <= currentStars;

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _ratingNotifier.value = starNumber,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: Icon(
                                isSelected
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 36.sp,
                                color: isSelected
                                    ? context.colors.starYellow
                                    : context.colors.border,
                              ),
                            ),
                          );
                        }),
                      ),
                      Gap(8.h),
                      Text(
                        _getRatingLabel(currentStars),
                        style: AppTextStyles.font14Bold.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(20.h),
                // Comment TextField
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  minLines: 3,
                  style: AppTextStyles.font14Regular.copyWith(
                    color: context.colors.mainText,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.writeYourReviewHere,
                    hintStyle: AppTextStyles.font13Regular.copyWith(
                      color: context.colors.subText,
                    ),
                    filled: true,
                    fillColor: context.colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: context.colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: context.colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: context.colors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                Gap(24.h),
                // Submit Button
                CustomMaterialButton(
                  maxWidth: true,
                  isLoading: isLoading,
                  onPressed: _submit,
                  text: AppStrings.submitReview,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                Gap(8.h),
              ],
            );
          },
        ),
      ),
    ),
  );
}
