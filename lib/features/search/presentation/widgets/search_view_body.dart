import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/search/presentation/widgets/search_placeholder_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/widgets/fruits_grid_view.dart';
import '../../../../core/widgets/search_text_field.dart';
import '../managers/search_cubit/search_cubit.dart';

class SearchViewBody extends StatefulWidget {
  const SearchViewBody({super.key});

  @override
  State<SearchViewBody> createState() => _SearchViewBodyState();
}

class _SearchViewBodyState extends State<SearchViewBody> {
  late TextEditingController _searchController;
  Timer? _debounce;
  final _focusNode = FocusNode();

  void _buildOnChanged(String? text) {
    if (text != null && text.trim().isNotEmpty) {
      _search(text);
    } else {
      setState(() {});
    }
  }

  void _search(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (_searchController.text.trim() == query.trim() && query.isNotEmpty) {
        context.read<SearchCubit>().searchProducts(query);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.delayed(Duration.zero, () => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: SearchTextFiled(
                focusNode: _focusNode,
                onChanged: _buildOnChanged,
                controller: _searchController,
              ),
            ),
            BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (_searchController.text.isEmpty) {
                  return const SizedBox.shrink();
                } else {
                  if (state is SearchSuccess) {
                    if (state.fruits.isEmpty) {
                      return const SearchPlaceholderWidget();
                    } else {
                      return Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.only(
                                top: 16.w,
                                start: 16.w,
                                bottom: 16.h,
                              ),
                              child: Text(
                                "search_results".tr(),
                                style: AppTextStyles.font13color949D9ERegular,
                              ),
                            ),
                            Expanded(
                              child: FruitsGridView(fruits: state.fruits),
                            ),
                          ],
                        ),
                      );
                    }
                  } else if (state is SearchLoading) {
                    return const Expanded(
                      child: Skeletonizer(
                        enabled: true,
                        child: FruitsGridView(itemCount: 3),
                      ),
                    );
                  } else if (state is SearchFailure) {
                    return const SearchPlaceholderWidget();
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
