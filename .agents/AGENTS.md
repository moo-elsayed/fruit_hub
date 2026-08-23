# Project Coding Guidelines & Best Practices

## State Management & Rebuild Optimization
- **Minimize `setState`**: Use `setState` only when absolutely necessary and scoped to the narrowest possible widget tree to prevent unnecessary widget rebuilds.
- **Prefer `ValueNotifier` & `ValueListenableBuilder`**: For simple reactive UI states within widgets, use `ValueNotifier` / `ValueListenableBuilder` instead of triggering full-widget `setState`.
- **Reactive & Shared Cubit Instances**: Share Cubit instances across child/detail routes using `BlocProvider.value` so UI updates automatically propagate in real-time across all views without redundant network re-fetching (`getInvoices()`).

## Component Architecture & Modularization
- **No Helper Build Functions**: Avoid creating private helper methods that return widgets (e.g. `_buildHeader()`, `_buildCard()`).
- **Separate Custom Widgets**: Always split UI sections into dedicated, reusable custom widget classes (`StatelessWidget` or `StatefulWidget`) placed in their own separate files under `widgets/`.
- **Keep Files Concise & Focused**: Keep screen and widget files small and readable (aim for under 150-200 lines per file). Extract buttons, forms, and calculation sections into dedicated custom widgets along with their handler logic.

## Code Quality & Formatting
- **Prefer Expression Bodies**: Use expression function syntax `=>` for concise single-statement `build()` methods, handlers, and getters.
- **No Hardcoded Strings**: Always use localized strings (`AppStrings` / `easy_localization`) for all user-facing UI text.

## Form & Keyboard Interactions
- **Keyboard Unfocus**: Always wrap screens, cards, or forms containing text input fields with `CustomKeyboardUnfocus` widget so the user can easily dismiss the keyboard by tapping outside.

## Performance Best Practices
- Always enforce performance best practices (e.g., using `const` constructors where possible, avoiding heavy work inside `build` methods, optimizing list view builders and animations).
