import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/utils/full_screen_image_gallery_input_item.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/image_picker_field.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/email_verification_status_badge.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_avatar_widget.dart';
import 'package:toastification/toastification.dart';

class EditProfileHeaderCard extends StatelessWidget {
  const EditProfileHeaderCard({super.key, required this.imageController});

  final TextEditingController imageController;

  void _onAvatarTap(BuildContext context) {
    final imagePath = imageController.text.trim();
    if (imagePath.isNotEmpty) {
      context.pushNamed(
        Routes.fullScreenImageGalleryView,
        arguments: FullScreenImageGalleryInputItem(
          initialIndex: 0,
          imagesPaths: [imagePath],
        ),
      );
    } else {
      _showImagePicker(context);
    }
  }

  void _showImagePicker(BuildContext context) {
    final hasImage = imageController.text.trim().isNotEmpty;
    ImagePickerField.showPicker(
      context: context,
      controller: imageController,
      showRemoveOption: hasImage,
      onRemove: () => AppToast.show(
        context: context,
        title: AppStrings.photoRemovedTapSaveToApply,
        type: ToastificationType.info,
      ),
      onImagePicked: () => AppToast.show(
        context: context,
        title: AppStrings.photoUpdatedTapSaveToApply,
        type: ToastificationType.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVerified =
        context.read<UserInfoCubit>().currentUser?.isVerified ?? false;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12.h,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => _onAvatarTap(context),
                  behavior: HitTestBehavior.opaque,
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: imageController,
                    builder: (context, value, _) {
                      final hasImage = value.text.trim().isNotEmpty;
                      final avatar = UserAvatarWidget(
                        imagePath: value.text,
                        size: 96,
                      );
                      if (hasImage) {
                        return Hero(tag: value.text.trim(), child: avatar);
                      }
                      return avatar;
                    },
                  ),
                ),
                PositionedDirectional(
                  bottom: 2.h,
                  end: 2.w,
                  child: GestureDetector(
                    onTap: () => _showImagePicker(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.surface,
                          width: 2.5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: AppPalette.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            EmailVerificationStatusBadge(isVerified: isVerified),
          ],
        ),
      ),
    );
  }
}
