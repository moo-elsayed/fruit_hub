import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/core/widgets/custom_keyboard_unfocus.dart';

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
    if (text == null || text.trim().isEmpty) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      context.read<SearchCubit>().resetSearch();
      setState(() {});
      return;
    }
    setState(() {});
    _search(text.trim());
  }

  void _search(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (_searchController.text.trim() == query.trim() && query.isNotEmpty) {
        await context.read<SearchCubit>().searchProducts(query);
      }
    });
  }

  void _onClear() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _searchController.clear();
    context.read<SearchCubit>().resetSearch();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomKeyboardUnfocus(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Hero(
              tag: 'search_bar_hero_tag',
              child: Material(
                color: Colors.transparent,
                child: SearchTextField(
                  focusNode: _focusNode,
                  onChanged: _buildOnChanged,
                  controller: _searchController,
                  onClear: _onClear,
                ),
              ),
            ),
          ),
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (_searchController.text.isEmpty) {
                return const SizedBox.shrink();
              } else {
                if (state is SearchSuccess) {
                  if (state.fruits.isEmpty) {
                    return const Expanded(child: CustomEmptyStateWidget());
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
                              AppStrings.searchResults,
                              style: AppTextStyles.font13Regular.copyWith(
                                color: context.colors.subText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FruitsGridView(
                              fruits: state.fruits,
                              bottomPadding: 24.h,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } else if (state is SearchLoading) {
                  return Expanded(
                    child: FruitsGridView(itemCount: 4, bottomPadding: 24.h),
                  );
                } else if (state is SearchFailure) {
                  return const Expanded(child: CustomEmptyStateWidget());
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
