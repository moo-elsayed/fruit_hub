import 'package:easy_localization/easy_localization.dart';

abstract class AppStrings {
  AppStrings._();

  static String get pageViewItem1Title => 'page_view_item1_title'.tr();
  static String get pageViewItem2Title => 'page_view_item2_title'.tr();
  static String get pageViewItem1Description =>
      'page_view_item1_description'.tr();
  static String get pageViewItem2Description =>
      'page_view_item2_description'.tr();
  static String get skip => 'skip'.tr();
  static String get startNow => 'start_now'.tr();
  static String get login => 'login'.tr();
  static String get register => 'register'.tr();
  static String get email => 'email'.tr();
  static String get password => 'password'.tr();
  static String get forgotPassword => 'forgot_password'.tr();
  static String get dontHaveAccount => 'don\'t_have_account'.tr();
  static String get createAnAccount => 'create_an_account'.tr();
  static String get or => 'or'.tr();
  static String get signInWithGoogle => 'sign_in_with_google'.tr();
  static String get signInWithApple => 'sign_in_with_apple'.tr();
  static String get signInWithFacebook => 'sign_in_with_facebook'.tr();
  static String get newAccount => 'new_account'.tr();
  static String get fullName => 'full_name'.tr();
  static String get termsAndConditionsP1 => 'terms_and_conditions_p1'.tr();
  static String get termsAndConditionsP2 => 'terms_and_conditions_p2'.tr();
  static String get createNewAccount => 'create_new_account'.tr();
  static String get alreadyHaveAnAccount => 'already_have_an_account'.tr();
  static String get emailCannotBeEmpty => 'email_cannot_be_empty'.tr();
  static String get enterAValidEmailAddress =>
      'enter_a_valid_email_address'.tr();
  static String get passwordCannotBeEmpty => 'password_cannot_be_empty'.tr();
  static String get passwordMustContainOnlyLettersAndNumbers =>
      'password_must_contain_only_letters_and_numbers'.tr();
  static String get passwordMustBeAtLeast6CharactersLong =>
      'password_must_be_at_least_6_characters_long'.tr();
  static String get passwordMustContainAtLeastOneNumber =>
      'password_must_contain_at_least_one_number'.tr();
  static String get nameCannotBeEmpty => 'name_cannot_be_empty'.tr();
  static String get emailCreated => 'email_created'.tr();
  static String get youShouldAcceptTermsAndConditions =>
      'you_should_accept_terms_and_conditions'.tr();
  static String get emailSentToVerify => 'email_sent_to_verify'.tr();
  static String get ok => 'ok'.tr();
  static String get welcome => 'welcome'.tr();
  static String get pleaseVerifyYourEmail => 'please_verify_your_email'.tr();
  static String get userCanceledSignIn => 'user_canceled_sign_in'.tr();
  static String get sendEmailResetLink => 'send_email_reset_link'.tr();
  static String get passwordReset => 'password_reset'.tr();
  static String get sendPasswordResetLink => 'send_password_reset_link'.tr();
  static String get tryAgainLater => 'try_again_later'.tr();
  static String get emailSent => 'email_sent'.tr();
  static String get emailSentToReset => 'email_sent_to_reset'.tr();
  static String get invalidEmail => 'invalid_email'.tr();
  static String get wrongPasswordProvidedForThatUser =>
      'wrong_password_provided_for_that_user'.tr();
  static String get noUserFoundForThatEmail =>
      'no_user_found_for_that_email'.tr();
  static String get userDisabled => 'user_disabled'.tr();
  static String get tooManyRequests => 'too_many_requests'.tr();
  static String get operationNotAllowed => 'operation_not_allowed'.tr();
  static String get invalidEmailOrPassword => 'invalid_email_or_password'.tr();
  static String get networkErrorMessage => 'network_error_message'.tr();
  static String get thePasswordProvidedIsTooWeak =>
      'the_password_provided_is_too_weak'.tr();
  static String get theAccountAlreadyExistsForThatEmail =>
      'the_account_already_exists_for_that_email'.tr();
  static String get internalError => 'internal_error'.tr();
  static String get appNotAuthorized => 'app_not_authorized'.tr();
  static String get userTokenExpired => 'user_token_expired'.tr();
  static String get requiresRecentLogin => 'requires_recent_login'.tr();
  static String get userMismatch => 'user_mismatch'.tr();
  static String get quotaExceeded => 'quota_exceeded'.tr();
  static String get errorOccurredPleaseTryAgain =>
      'error_occurred_please_try_again'.tr();
  static String get permissionDenied => 'permission-denied'.tr();
  static String get goodMorning => 'good_morning'.tr();
  static String get goodEvening => 'good_evening'.tr();
  static String get greeting {
    final hour = DateTime.now().hour;
    return (hour >= 4 && hour < 12) ? goodMorning : goodEvening;
  }

  static String get searchFor => 'search_for'.tr();
  static String get eidOffers => 'eid_offers'.tr();
  static String get discount => 'discount'.tr();
  static String get shopNow => 'shop_now'.tr();
  static String get bestSeller => 'best_seller'.tr();
  static String get more => 'more'.tr();
  static String get pounds => 'pounds'.tr();
  static String get kilo => 'kilo'.tr();
  static String get perKilo => 'per_kilo'.tr();
  static String get home => 'home'.tr();
  static String get products => 'products'.tr();
  static String get shoppingCart => 'shopping_cart'.tr();
  static String get myAccount => 'my_account'.tr();
  static String get search => 'search'.tr();
  static String get noResults => 'no_results'.tr();
  static String get searchResults => 'search_results'.tr();
  static String get language => 'language'.tr();
  static String get appLanguage => 'app_language'.tr();
  static String get signOut => 'sign_out'.tr();
  static String get ourProducts => 'our_products'.tr();
  static String get cartAppBar => 'cart_app_bar'.tr();
  static String get youHave => 'you_have'.tr();
  static String get productsInTheShoppingCart =>
      'products_in_the_shopping_cart'.tr();
  static String get checkout => 'checkout'.tr();
  static String get userNotLoggedIn => 'user_not_logged_in'.tr();
  static String get selectLanguage => 'select_language'.tr();
  static String get languageChangedSuccessfully =>
      'language_changed_successfully'.tr();
  static String get cancel => 'cancel'.tr();
  static String get confirmLanguageChange => 'confirm_language_change'.tr();
  static String get appWillRestart => 'app_will_restart'.tr();
  static String get favorites => 'favorites'.tr();
  static String get noFavorites => 'no_favorites'.tr();
  static String get general => 'general'.tr();
  static String get itemAddedToCart => 'item_added_to_cart'.tr();
  static String get itemAlreadyInCart => 'item_already_in_cart'.tr();
  static String get emptyCartSubtitle => 'empty_cart_subtitle'.tr();
  static String get itemRemovedFromCart => 'item_removed_from_cart'.tr();
  static String get loading => 'loading'.tr();
  static String get logOutConfirmation => 'log_out_confirmation'.tr();
  static String get loggedOutSuccessfully => 'logged_out_successfully'.tr();
  static String get sortBy => 'sort_by'.tr();
  static String get priceLowestToHighest => 'price_lowest_to_highest'.tr();
  static String get priceHighestToLowest => 'price_highest_to_lowest'.tr();
  static String get alphabetical => 'alphabetical'.tr();
  static String get apply => 'apply'.tr();
  static String get reset => 'reset'.tr();
  static String get addToCart => 'add_to_cart'.tr();
  static String get viewCart => 'view_cart'.tr();
  static String get validity => 'validity'.tr();
  static String get days => 'days'.tr();
  static String get organic => 'organic'.tr();
  static String get featured => 'featured'.tr();
  static String get calories => 'calories'.tr();
  static String get gram => 'gram'.tr();
  static String get reviews => 'reviews'.tr();
  static String get review => 'review'.tr();
  static String get shipping => 'shipping'.tr();
  static String get address => 'address'.tr();
  static String get payment => 'payment'.tr();
  static String get confirmAndContinue => 'confirm_and_continue'.tr();
  static String get confirmOrder => 'confirm_order'.tr();
  static String get next => 'next'.tr();
  static String get cashOnDelivery => 'cash_on_delivery'.tr();
  static String get deliveryFromPlace => 'delivery_from_place'.tr();
  static String get onlinePayment => 'online_payment'.tr();
  static String get payByCreditCard => 'pay_by_credit_card'.tr();
  static String get freeShipping => 'free_shipping'.tr();
  static String get free => 'free'.tr();
  static String addAmountMoreForFreeShipping(String amount) =>
      'add_more_for_free_shipping'.tr(args: [amount]);
  static String get congratulationsFreeShipping =>
      'congratulations_free_shipping'.tr();
  static String get justNow => 'just_now'.tr();
  static String minutesAgo(int minutes) =>
      'minutes_ago'.tr(args: [minutes.toString()]);
  static String hoursAgo(int hours) => 'hours_ago'.tr(args: [hours.toString()]);
  static String daysAgo(int days) => 'days_ago'.tr(args: [days.toString()]);
  static String get phoneNumber => 'phone_number'.tr();
  static String get streetNameCannotBeEmpty =>
      'street_name_cannot_be_empty'.tr();
  static String get city => 'city'.tr();
  static String get saveAddress => 'save_address'.tr();
  static String get floorNumber => 'floor_number'.tr();
  static String get apartmentNumber => 'apartment_number'.tr();
  static String get phoneNumberCannotBeEmpty =>
      'phone_number_cannot_be_empty'.tr();
  static String get enterAValidPhoneNumber => 'enter_a_valid_phone_number'.tr();
  static String get cityCannotBeEmpty => 'city_cannot_be_empty'.tr();
  static String get floorNumberCannotBeEmpty =>
      'floor_number_cannot_be_empty'.tr();
  static String get apartmentNumberCannotBeEmpty =>
      'apartment_number_cannot_be_empty'.tr();
  static String get buildingNumberCannotBeEmpty =>
      'building_number_cannot_be_empty'.tr();
  static String get payByPaypal => 'pay_by_paypal'.tr();
  static String get chooseThePaymentMethodThatSuitsYouBest =>
      'choose_the_payment_method_that_suits_you_best'.tr();
  static String get orderSummary => 'order_summary'.tr();
  static String get delivery => 'delivery'.tr();
  static String get subtotal => 'subtotal'.tr();
  static String get total => 'total'.tr();
  static String get pleaseConfirmYourOrder => 'please_confirm_your_order'.tr();
  static String get paymentMethod => 'payment_method'.tr();
  static String get deliveryAddress => 'delivery_address'.tr();
  static String get edit => 'edit'.tr();
  static String get itMustBeANumber => 'it_must_be_a_number'.tr();
  static String get streetName => 'street_name'.tr();
  static String get buildingNumber => 'building_number'.tr();
  static String get building => 'building'.tr();
  static String get floor => 'floor'.tr();
  static String get apartment => 'apartment'.tr();
  static String get pleaseSelectAPaymentMethod =>
      'please_select_a_payment_method'.tr();
  static String get orderPlacedSuccessfully => 'order_placed_successfully'.tr();
  static String get orderCancelled => 'order_cancelled'.tr();
  static String get contactUsForAnyQuestionsOnYourOrder =>
      'contact_us_for_any_questions_on_your_order'.tr();
  static String get trackOrder => 'track_order'.tr();
  static String get itWasDoneSuccessfully => 'It_was_done_successfully!'.tr();
  static String get orderNumber => 'order_number'.tr();
  static String get system => 'system'.tr();
  static String get light => 'light'.tr();
  static String get dark => 'dark'.tr();
  static String get optional => 'optional'.tr();
  static String get notFoundError => 'notFoundError'.tr();
  static String get unexpectedError => 'unexpectedError'.tr();
  static String get userNotFound => 'userNotFound'.tr();
  static String get invalidCredential => 'invalidCredential'.tr();
  static String get emailAlreadyInUse => 'emailAlreadyInUse'.tr();
  static String get accountExistsWithDifferentCredential =>
      'accountExistsWithDifferentCredential'.tr();
  static String get noInternetConnection => 'noInternetConnection'.tr();
  static String get googleSignInCancelled => 'googleSignInCancelled'.tr();
  static String get appTagline => 'appTagline'.tr();
  static String get requiredField => 'requiredField'.tr();
  static String get passwordMustBeAtLeast8CharactersLong =>
      'passwordMustBeAtLeast8CharactersLong'.tr();
  static String get passwordMustContainUppercase =>
      'passwordMustContainUppercase'.tr();
  static String get passwordMustContainLowercase =>
      'passwordMustContainLowercase'.tr();
  static String get passwordMustContainNumber =>
      'passwordMustContainNumber'.tr();
  static String get passwordMustContainSpecialCharacter =>
      'passwordMustContainSpecialCharacter'.tr();
  static String get confirmPasswordMustMatchThePassword =>
      'confirmPasswordMustMatchThePassword'.tr();
  static String get profilePictureIsRequired => 'profilePictureIsRequired'.tr();
  static String get idCardImageIsRequired => 'idCardImageIsRequired'.tr();
  static String get usernameCannotBeEmpty => 'usernameCannotBeEmpty'.tr();
  static String get pleaseEnterDescription => 'pleaseEnterDescription'.tr();
  static String get pleaseSelectLocation => 'pleaseSelectLocation'.tr();
  static String get pleaseSelectDate => 'pleaseSelectDate'.tr();
  static String get pleaseSelectTime => 'pleaseSelectTime'.tr();
  static String get yearsOfExperienceCannotBeEmpty =>
      'yearsOfExperienceCannotBeEmpty'.tr();
  static String get codeCannotBeEmpty => 'codeCannotBeEmpty'.tr();
  static String get codeShouldBeAtLeast6Digits =>
      'codeShouldBeAtLeast6Digits'.tr();
  static String get nationalIdCannotBeEmpty => 'nationalIdCannotBeEmpty'.tr();
  static String get nationalIdMustBe14Digits => 'nationalIdMustBe14Digits'.tr();
  static String get theme => 'theme'.tr();
  static String get arabic => 'arabic'.tr();
  static String get english => 'english'.tr();
  static String get all => 'all'.tr();
  static String get mostPopular => 'most_popular'.tr();
  static String get topRated => 'top_rated'.tr();
  static String get filterAndSort => 'filter_and_sort'.tr();
  static String get filterBy => 'filter_by'.tr();
  static String get resetFilters => 'reset_filters'.tr();
  static String get noProductsFound => 'no_products_found'.tr();
  static String get categories => 'categories'.tr();
  static String get weight => 'weight'.tr();
  static String get per100Gram => 'per_100_gram'.tr();
  static String get selectLocationOnMap => 'select_location_on_map'.tr();
  static String get confirmLocation => 'confirm_location'.tr();
  static String get locating => 'locating'.tr();
  static String get locationPermissionDenied =>
      'location_permission_denied'.tr();
  static String get locationServicesDisabled =>
      'location_services_disabled'.tr();
  static String get selectedLocation => 'selected_location'.tr();
  static String get moveMapToPick => 'move_map_to_pick'.tr();
  static String get currentLocation => 'current_location'.tr();
  static String get mapInstructions => 'map_instructions'.tr();
  static String get pinLocationHint => 'pin_location_hint'.tr();
  static String get gpsDisabled => 'gps_disabled'.tr();
  static String get locationPermissionPermanentlyDenied =>
      'location_permission_permanently_denied'.tr();
  static String get selectLocationFromMap => 'select_location_from_map'.tr();
  static String get dragMapToSelectLocation =>
      'drag_map_to_select_location'.tr();
  static String get unknownArea => 'unknown_area'.tr();
  static String get pleaseSelectLocationOnMap =>
      'please_select_location_on_map'.tr();
  static String get writeReview => 'write_review'.tr();
  static String get yourRating => 'your_rating'.tr();
  static String get writeYourReviewHere => 'write_your_review_here'.tr();
  static String get noReviewsYet => 'no_reviews_yet'.tr();
  static String get beTheFirstToReview => 'be_the_first_to_review'.tr();
  static String get submitReview => 'submit_review'.tr();
  static String get reviewAddedSuccessfully => 'review_added_successfully'.tr();
  static String get pleaseSelectRating => 'please_select_rating'.tr();
  static String get verifiedPurchase => 'verified_purchase'.tr();
  static String get anonymousUser => 'anonymous_user'.tr();
  static String get onlyBuyersCanReview => 'only_buyers_can_review'.tr();
  static String get youPurchasedThisProduct =>
      'you_purchased_this_product'.tr();
  static String get alreadyReviewedProduct => 'already_reviewed_product'.tr();
  static String get ratingSummary => 'rating_summary'.tr();
  static String get excellent => 'excellent'.tr();
  static String get veryGood => 'very_good'.tr();
  static String get good => 'good'.tr();
  static String get fair => 'fair'.tr();
  static String get poor => 'poor'.tr();

  static String getRatingLabel(int rating) => switch (rating) {
    1 => poor,
    2 => fair,
    3 => good,
    4 => veryGood,
    5 => excellent,
    _ => '',
  };
  static String get continueShopping => 'continue_shopping'.tr();
  static String get orderCopied => 'order_copied'.tr();
  static String get estimatedDelivery => 'estimated_delivery'.tr();
  static String get deliveryWithinHours => 'delivery_within_hours'.tr();
  static String get orderPlaced => 'order_placed'.tr();
  static String get orderPreparing => 'order_preparing'.tr();
  static String get orderOnTheWay => 'order_on_the_way'.tr();
  static String get orderDelivered => 'order_delivered'.tr();
  static String get orderedItems => 'ordered_items'.tr();
  static String get thankYouForYourOrder => 'thank_you_for_your_order'.tr();
  static String get copy => 'copy'.tr();
  static String get notifications => 'notifications'.tr();
  static String get noNotifications => 'no_notifications'.tr();
  static String get noNotificationsDesc => 'no_notifications_desc'.tr();
  static String get markAllAsRead => 'mark_all_as_read'.tr();
  static String get allNotificationsMarkedAsRead =>
      'all_notifications_marked_as_read'.tr();
  static String get myOrders => 'my_orders'.tr();
  static String get orderNumberPrefix => 'order_number_prefix'.tr();
  static String get items => 'items'.tr();
  static String get viewDetails => 'view_details'.tr();
  static String get hideDetails => 'hide_details'.tr();
  static String get shippingAddress => 'shipping_address'.tr();
  static String get grandTotal => 'grand_total'.tr();
  static String get codeLabel => 'code_label'.tr();
  static String get noOrdersYet => 'no_orders_yet'.tr();
  static String get noOrdersDescription => 'no_orders_desc'.tr();
  static String get cancelOrder => 'cancel_order'.tr();
  static String get cancelOrderConfirm => 'cancel_order_confirm'.tr();
  static String get orderCancelledSuccessfully =>
      'order_cancelled_successfully'.tr();
  static String get cannotCancelOrder => 'cannot_cancel_order'.tr();
  static String get unknownUser => 'unknown_user'.tr();
  static String get orderDetails => 'order_details'.tr();
  static String get productDetails => 'product_details'.tr();
  static String get editProfile => 'edit_profile'.tr();
  static String get personalInfo => 'personal_info'.tr();
  static String get profilePicture => 'profile_picture'.tr();
  static String get profileUpdatedSuccessfully =>
      'profile_updated_successfully'.tr();
  static String get saveChanges => 'save_changes'.tr();
  static String get emailCannotBeChanged => 'email_cannot_be_changed'.tr();
  static String get verifiedAccount => 'verified_account'.tr();
  static String get basicInfo => 'basic_info'.tr();
  static String get accountSecurity => 'account_security'.tr();
  static String get changePassword => 'change_password'.tr();
  static String get currentPassword => 'current_password'.tr();
  static String get newPassword => 'new_password'.tr();
  static String get confirmNewPassword => 'confirm_new_password'.tr();
  static String get passwordsDoNotMatch => 'passwords_do_not_match'.tr();
  static String get passwordChangedSuccessfully =>
      'password_changed_successfully'.tr();
  static String get currentPasswordCannotBeEmpty =>
      'current_password_cannot_be_empty'.tr();
  static String get newPasswordCannotBeEmpty =>
      'new_password_cannot_be_empty'.tr();
  static String get chooseImageSource => 'choose_image_source'.tr();
  static String get camera => 'camera'.tr();
  static String get gallery => 'gallery'.tr();
}
