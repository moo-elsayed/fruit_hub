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
- **Strict `AppStrings` Usage (No Hardcoded Strings)**: Always use `AppStrings` for all user-facing UI text, titles, hints, labels, error messages, and buttons. Hardcoded strings are strictly prohibited across UI code, except when defining mock / dummy data.

## Buttons & Action Controls
- **Always Use `CustomMaterialButton`**: Never use raw `ElevatedButton`, `MaterialButton`, or generic buttons for primary actions, forms, bottom sheets, and dialogs. Always use `CustomMaterialButton` to guarantee uniform brand styling, loading indicator handling (`isLoading`), consistent dimensions, and rounded corners.

## Form & Keyboard Interactions
- **Always Use `TextFormFieldHelper`**: Never use raw `TextField` or `TextFormField`. Always use `TextFormFieldHelper` across all forms, dialogs, and bottom sheets to guarantee automatic bidirectional text direction (RTL/LTR), consistent theme borders, selection colors, and unified styling.
- **Keyboard Unfocus**: Always wrap screens, cards, or forms containing text input fields with `CustomKeyboardUnfocus` widget so the user can easily dismiss the keyboard by tapping outside.

## Theming & Color Management
- **Strict Color System Usage**: Never use hardcoded colors (e.g., `Colors.white`, `Colors.black`, raw hex `Color(0xFF...)`) outside the theme definition. Always access colors via `context.colors` (`ColorsManager`) or directly through `AppPalette`.

## Routing & Navigation Guidelines
- **Unified Navigation via `context` Extensions**: Always use the project's centralized navigation extensions on `BuildContext` (`context.pushNamed(Routes.xxx, arguments: ...)`, `context.pushReplacementNamed(...)`, `context.pop(...)`). Direct use of `Navigator.push` / `MaterialPageRoute` is strictly prohibited.
- **Centralized Route Registration**: All views must have their route named constant in `Routes` and handled inside `AppRouter` (`generateRoute`).

## Layout & Spacing Optimization
- **Prefer `spacing` on `Row`, `Column`, & `Wrap`**: Whenever children have uniform spacing, always use the built-in `spacing` property (e.g., `Row(spacing: 4.w, ...)`, `Column(spacing: 8.h, ...)`, `Wrap(spacing: ..., runSpacing: ...)`) instead of inserting intermediate `Gap` or `SizedBox` widgets. This flattens the widget tree and reduces unnecessary layout elements.
- **Use `Gap` Only for Non-Uniform Spacing**: Only resort to `Gap` / `SizedBox` when spacing between specific child widgets is deliberately non-uniform, asymmetric, or conditional where a global `spacing` is unsuitable.

## Performance Best Practices
- Always enforce performance best practices (e.g., using `const` constructors where possible, avoiding heavy work inside `build` methods, optimizing list view builders and animations).

