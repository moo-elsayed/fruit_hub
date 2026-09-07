import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet_handle.dart';
import 'package:fruit_hub/core/widgets/custom_keyboard_unfocus.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/reviews_cubit/reviews_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/add_review_rating_section.dart';
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

  void _submit() {
    final cachedUser = context.read<UserInfoCubit>().currentUser;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    final userName = cachedUser?.name.trim().isNotEmpty == true
        ? cachedUser!.name.trim()
        : (firebaseUser?.displayName?.trim().isNotEmpty == true
              ? firebaseUser!.displayName!.trim()
              : (firebaseUser?.email ?? 'User'));
    final userImage = firebaseUser?.photoURL;
    final userId = firebaseUser?.uid ?? cachedUser?.uid ?? '';

    context.read<ReviewsCubit>().submitReview(
      rating: _ratingNotifier.value.toDouble(),
      comment: _commentController.text,
      userName: userName,
      userImage: userImage,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) => CustomKeyboardUnfocus(
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                const CustomBottomSheetHandle(),
                Gap(12.h),
                Text(
                  AppStrings.writeReview,
                  style: AppTextStyles.font18Bold.copyWith(
                    color: context.colors.mainText,
                  ),
                ),
                Gap(16.h),
                AddReviewRatingSection(ratingNotifier: _ratingNotifier),
                Gap(20.h),
                TextFormFieldHelper(
                  controller: _commentController,
                  hint: AppStrings.writeYourReviewHere,
                  maxLines: 4,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  action: TextInputAction.newline,
                  fillColor: context.colors.background,
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
