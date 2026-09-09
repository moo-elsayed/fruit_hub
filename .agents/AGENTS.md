# Flutter Project Coding Guidelines & Best Practices

## State Management & Rebuild Optimization
- **Minimize `setState`**: Use `setState` only when absolutely necessary and scoped to the narrowest possible widget tree to prevent unnecessary widget rebuilds.
- **Prefer `ValueNotifier` & `ValueListenableBuilder`**: For simple reactive UI states within widgets, use `ValueNotifier` / `ValueListenableBuilder` instead of triggering full-widget `setState`.
- **Reactive & Shared Cubit Instances**: Share Cubit instances across child/detail routes using `BlocProvider.value` so UI updates automatically propagate in real-time across all views without redundant network re-fetching.

## Component Architecture & Modularization
- **No Helper Build Functions**: Avoid creating private helper methods that return widgets (e.g. `_buildHeader()`, `_buildCard()`).
- **Separate Custom Widgets**: Always split UI sections into dedicated, reusable custom widget classes (`StatelessWidget` or `StatefulWidget`) placed in their own separate files under `widgets/`.
- **Keep Files Concise & Focused**: Keep screen and widget files small and readable (aim for under 150-200 lines per file). Extract buttons, forms, and calculation sections into dedicated custom widgets along with their handler logic.

## Code Quality & Formatting
- **Prefer Expression Bodies**: Use expression function syntax `=>` for concise single-statement `build()` methods, handlers, and getters.
- **No Hardcoded Strings**: Always use a centralized strings class (e.g. `AppStrings`) for all user-facing UI text, titles, hints, labels, error messages, and buttons. Hardcoded strings are strictly prohibited across UI code, except when defining mock / dummy data.

## Buttons & Action Controls
- **Use a Consistent Custom Button**: Never use raw `ElevatedButton`, `MaterialButton`, or generic buttons for primary actions, forms, bottom sheets, and dialogs. Always use a shared custom button widget to guarantee uniform brand styling, loading state handling, consistent dimensions, and rounded corners.

## Form & Keyboard Interactions
- **Use a Consistent Custom TextField**: Never use raw `TextField` or `TextFormField` directly. Always wrap them in a shared helper widget across all forms, dialogs, and bottom sheets to guarantee automatic bidirectional text direction (RTL/LTR), consistent theme borders, and unified styling.
- **Keyboard Unfocus**: Always wrap screens or forms containing text input fields with a keyboard-dismissing wrapper widget so the user can easily dismiss the keyboard by tapping outside.

## Theming & Color Management
- **Strict Color System Usage**: Never use hardcoded colors (e.g., `Colors.white`, `Colors.black`, raw hex `Color(0xFF...)`) outside the theme definition. Always access colors via the theme or a centralized color palette class.

## Typography & Text Styling
- **No Raw `TextStyle` in UI**: Never instantiate raw `TextStyle(...)` directly inside UI widgets or screens. Always rely on a centralized typography class (e.g. `AppTextStyles`) or the theme's `TextTheme`. For any style variations (e.g., changing color, line height, or text decoration), always call `.copyWith(...)` on an existing predefined typography token. This enforces consistent font families, correct font scaling, and maintainable text hierarchy across the entire application.

## Routing & Navigation Guidelines
- **Unified Navigation via `context` Extensions**: Always use centralized navigation extensions on `BuildContext`. Direct use of `Navigator.push` / `MaterialPageRoute` is strictly prohibited.
- **Centralized Route Registration**: All views must have their route named constant in a `Routes` class and handled inside a central `AppRouter`.

## Layout & Spacing Optimization
- **Prefer `spacing` on `Row`, `Column`, & `Wrap`**: Whenever children have uniform spacing, always use the built-in `spacing` property instead of inserting intermediate `Gap` or `SizedBox` widgets between every child. This flattens the widget tree.
- **Use `Gap` Only for Non-Uniform Spacing**: Only resort to `Gap` / `SizedBox` when spacing between specific child widgets is deliberately non-uniform, asymmetric, or conditional.

## Performance Best Practices
- Always enforce performance best practices (e.g., using `const` constructors where possible, avoiding heavy work inside `build` methods, optimizing list view builders and animations).

## Dependency Injection (GetIt) Guidelines
- **Always Prefer `registerLazySingleton`**: Always use `getIt.registerLazySingleton` instead of `registerSingleton` for all repositories, data sources, use cases, and services (unless asynchronous startup is explicitly required like `registerSingletonAsync`). This prevents unnecessary early instantiation on app startup and guarantees resources are initialized lazily on-demand.

## Cubit / BLoC Design Rules
- **Cubits Must Be Context-Free**: Never pass `BuildContext` into a Cubit method. Cubits handle business logic only (emit state, persist data, call services). Any operation that requires `context` (e.g. `context.setLocale`, `context.pushNamed`) must live in the UI layer via `BlocListener` or `BlocConsumer`.
- **Pattern for Context-Dependent Side Effects**: When a Cubit state change must trigger a context-dependent action (e.g. locale change, navigation), use a root-level `BlocListener` in the app's root widget to react to the state and call the context method there — mirroring how `BlocBuilder<ThemeCubit>` drives `themeMode` in `MaterialApp`.
- **Dedicated Cubit per Cross-Cutting Concern**: Create a dedicated Cubit for each app-wide concern (e.g. `AppThemeCubit`, `AppLanguageCubit`). Each Cubit owns: emitting the new state, persisting to local storage, and syncing to any remote backend. The UI layer only reacts via `BlocListener`.

## Services Design Guidelines
- **Services Must Be Context-Free**: Services must never accept or use `BuildContext`. Any locale or language reading must come from a local storage service, not from `context.locale` or `PlatformDispatcher.instance.locale`.
- **Never Read Device Language for App Language**: The device system language (`PlatformDispatcher.instance.locale`) and the user-selected app language (stored in preferences) are two different things. Always use the user-selected language stored in the app's own preferences service.
- **Constructor Injection Over `getIt` Inside Methods**: Dependencies must be injected via the class constructor, not fetched with `getIt<X>()` inside methods. `getIt` is only used at the DI registration site and at the `BlocProvider` creation site. Hidden `getIt` calls inside service methods or Cubits are strictly prohibited.
- **Prefer Existing Abstractions**: Before using `SharedPreferences` or any platform API directly, check whether a registered service (e.g. `AppPreferencesService`) already wraps it. Always use the project's own abstraction layer.

## Cloud Functions (Firebase) Guidelines
- **Bilingual Notification Storage**: All in-app notification documents saved to Firestore must store both language variants: `titleAr`, `titleEn`, `bodyAr`, `bodyEn` — never a single `title`/`body`. This allows the Flutter app to display the correct language based on the current app locale, even if the user changes language after the notification was saved.
- **FCM Push vs. In-App Notification Language**: The FCM push banner uses the user's stored `languageCode` at the time of sending. The in-app notification screen always renders from the bilingual fields using a `localizedTitle(isArabic)` / `localizedBody(isArabic)` helper on the entity.
- **Field Name Consistency**: All Firestore field names used in Cloud Functions must exactly match the Dart model `toJson()` / `fromJson()` keys. Cross-check against the model before writing a new function.
- **`languageCode` Sync**: The `languageCode` field on the user's Firestore document must be kept in sync whenever the user changes language. This sync should be triggered from the language Cubit so it's guaranteed to run on every language change.
