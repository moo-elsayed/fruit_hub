import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/profile/presentation/items/profile_card_item.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/profile_card_tile.dart';

export 'package:fruit_hub/features/profile/presentation/items/profile_card_item.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.items});

  final List<ProfileCardItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.isDarkMode
              ? colors.border.withValues(alpha: 0.5)
              : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ProfileCardTile(
              item: items[i],
              borderRadius: _getBorderRadius(i, items.length),
            ),
            if (i < items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: colors.border.withValues(alpha: 0.2),
                indent: 50.w,
                endIndent: 16.w,
              ),
          ],
        ],
      ),
    );
  }

  BorderRadius _getBorderRadius(int index, int total) {
    if (total == 1) return BorderRadius.circular(16.r);
    if (index == 0) {
      return BorderRadius.vertical(top: Radius.circular(16.r));
    }
    if (index == total - 1) {
      return BorderRadius.vertical(bottom: Radius.circular(16.r));
    }
    return BorderRadius.zero;
  }
}
