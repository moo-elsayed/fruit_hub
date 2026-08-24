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
  static String get general => 'general'.tr();
  static String get itemAddedToCart => 'item_added_to_cart'.tr();
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
  static String get validity => 'validity'.tr();
  static String get days => 'days'.tr();
  static String get organic => 'organic'.tr();
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
  static String get noInternetConnection => 'noInternetConnection'.tr();
  static String get unexpectedError => 'unexpectedError'.tr();
  static String get unauthorizedError => 'unauthorizedError'.tr();
  static String get notFoundError => 'notFoundError'.tr();
  static String get serverError => 'serverError'.tr();
  static String get somethingWentWrong => 'somethingWentWrong'.tr();
  static String get userNotFound => 'userNotFound'.tr();
  static String get wrongPassword => 'wrongPassword'.tr();
  static String get invalidCredential => 'invalidCredential'.tr();
  static String get emailAlreadyInUse => 'emailAlreadyInUse'.tr();
  static String get accountExistsWithDifferentCredential =>
      'accountExistsWithDifferentCredential'.tr();
  static String get invalidEmail2 => 'invalidEmail'.tr();
  static String get tooManyRequests2 => 'tooManyRequests'.tr();
  static String get permissionDenied2 => 'permissionDenied'.tr();
  static String get userDisabled2 => 'userDisabled'.tr();
  static String get operationNotAllowed2 => 'operationNotAllowed'.tr();
  static String get cacheError => 'cacheError'.tr();
  static String get googleSignInCancelled => 'googleSignInCancelled'.tr();
  static String get emailCannotBeEmpty2 => 'emailCannotBeEmpty'.tr();
  static String get enterAValidEmailAddress2 => 'enterAValidEmailAddress'.tr();
  static String get requiredField => 'requiredField'.tr();
  static String get passwordCannotBeEmpty2 => 'passwordCannotBeEmpty'.tr();
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
  static String get nameCannotBeEmpty2 => 'nameCannotBeEmpty'.tr();
  static String get profilePictureIsRequired => 'profilePictureIsRequired'.tr();
  static String get idCardImageIsRequired => 'idCardImageIsRequired'.tr();
  static String get usernameCannotBeEmpty => 'usernameCannotBeEmpty'.tr();
  static String get streetNameCannotBeEmpty2 => 'streetNameCannotBeEmpty'.tr();
  static String get cityCannotBeEmpty2 => 'cityCannotBeEmpty'.tr();
  static String get buildingNumberCannotBeEmpty2 =>
      'buildingNumberCannotBeEmpty'.tr();
  static String get itMustBeANumber2 => 'itMustBeANumber'.tr();
  static String get pleaseEnterDescription => 'pleaseEnterDescription'.tr();
  static String get pleaseSelectLocation => 'pleaseSelectLocation'.tr();
  static String get pleaseSelectDate => 'pleaseSelectDate'.tr();
  static String get pleaseSelectTime => 'pleaseSelectTime'.tr();
  static String get yearsOfExperienceCannotBeEmpty =>
      'yearsOfExperienceCannotBeEmpty'.tr();
  static String get phoneNumberCannotBeEmpty2 =>
      'phoneNumberCannotBeEmpty'.tr();
  static String get enterAValidPhoneNumber2 => 'enterAValidPhoneNumber'.tr();
  static String get codeCannotBeEmpty => 'codeCannotBeEmpty'.tr();
  static String get codeShouldBeAtLeast6Digits =>
      'codeShouldBeAtLeast6Digits'.tr();
  static String get nationalIdCannotBeEmpty => 'nationalIdCannotBeEmpty'.tr();
  static String get nationalIdMustBe14Digits => 'nationalIdMustBe14Digits'.tr();
  static String get onboardingSkip => 'onboardingSkip'.tr();
  static String get getStarted => 'getStarted'.tr();
  static String get onboardingTitle1 => 'onboardingTitle1'.tr();
  static String get onboardingDescription1 => 'onboardingDescription1'.tr();
  static String get onboardingTitle2 => 'onboardingTitle2'.tr();
  static String get onboardingDescription2 => 'onboardingDescription2'.tr();
  static String get onboardingTitle3 => 'onboardingTitle3'.tr();
  static String get onboardingDescription3 => 'onboardingDescription3'.tr();
  static String get appTagline => 'appTagline'.tr();
  static String get forgotPassword2 => 'forgotPassword'.tr();
  static String get dontHaveAccount2 => 'dontHaveAccount'.tr();
  static String get createAnAccount2 => 'createAnAccount'.tr();
  static String get signInWithGoogle2 => 'signInWithGoogle'.tr();
  static String get newAccount2 => 'newAccount'.tr();
  static String get fullName2 => 'fullName'.tr();
  static String get alreadyHaveAnAccount2 => 'alreadyHaveAnAccount'.tr();
  static String get passwordReset2 => 'passwordReset'.tr();
  static String get sendEmailResetLink2 => 'sendEmailResetLink'.tr();
  static String get sendPasswordResetLink2 => 'sendPasswordResetLink'.tr();
  static String get send => 'send'.tr();
  static String get sendPasswordResetConfirmation =>
      'sendPasswordResetConfirmation'.tr();
  static String get emailSent2 => 'emailSent'.tr();
  static String get emailSentToReset2 => 'emailSentToReset'.tr();
  static String get emailCreated2 => 'emailCreated'.tr();
  static String get emailSentToVerify2 => 'emailSentToVerify'.tr();
  static String get youShouldAcceptTermsAndConditions2 =>
      'youShouldAcceptTermsAndConditions'.tr();
  static String get termsAndConditionsP12 => 'termsAndConditionsP1'.tr();
  static String get termsAndConditionsP22 => 'termsAndConditionsP2'.tr();
  static String get noUserFoundForThatEmail2 => 'noUserFoundForThatEmail'.tr();
  static String get pleaseVerifyYourEmail2 => 'pleaseVerifyYourEmail'.tr();
  static String get invoices => 'invoices'.tr();
  static String get clients => 'clients'.tr();
  static String get settings => 'settings'.tr();
  static String get generalSettings => 'generalSettings'.tr();
  static String get localSettings => 'localSettings'.tr();
  static String get profileInformation => 'profileInformation'.tr();
  static String get securitySettings => 'securitySettings'.tr();
  static String get theme => 'theme'.tr();
  static String get arabic => 'arabic'.tr();
  static String get english => 'english'.tr();
  static String get currency => 'currency'.tr();
  static String get signOut2 => 'signOut'.tr();
  static String get signOutConfirmation => 'signOutConfirmation'.tr();
  static String get passwordResetSent => 'passwordResetSent'.tr();
  static String get currencyUpdated => 'currencyUpdated'.tr();
  static String get usd => 'usd'.tr();
  static String get egp => 'egp'.tr();
  static String get eur => 'eur'.tr();
  static String get sar => 'sar'.tr();
  static String get aed => 'aed'.tr();
  static String get businessNameUpdated => 'businessNameUpdated'.tr();
  static String get businessName => 'businessName'.tr();
  static String get memberSince => 'memberSince'.tr();
  static String get accountStatus => 'accountStatus'.tr();
  static String get verified => 'verified'.tr();
  static String get unverified => 'unverified'.tr();
  static String get saveChanges => 'saveChanges'.tr();
  static String get accountDetails => 'accountDetails'.tr();
  static String get addClient => 'addClient'.tr();
  static String get editClient => 'editClient'.tr();
  static String get deleteClient => 'deleteClient'.tr();
  static String get deleteClientConfirmation => 'deleteClientConfirmation'.tr();
  static String get searchClients => 'searchClients'.tr();
  static String get noClientsFound => 'noClientsFound'.tr();
  static String get clientName => 'clientName'.tr();
  static String get clientEmail => 'clientEmail'.tr();
  static String get clientPhone => 'clientPhone'.tr();
  static String get clientAddress => 'clientAddress'.tr();
  static String get clientInformation => 'clientInformation'.tr();
  static String get clientAddedSuccessfully => 'clientAddedSuccessfully'.tr();
  static String get clientUpdatedSuccessfully =>
      'clientUpdatedSuccessfully'.tr();
  static String get clientDeletedSuccessfully =>
      'clientDeletedSuccessfully'.tr();
  static String get phone => 'phone'.tr();
  static String get createInvoice => 'createInvoice'.tr();
  static String get invoiceNumber => 'invoiceNumber'.tr();
  static String get selectClient => 'selectClient'.tr();
  static String get pleaseSelectClient => 'pleaseSelectClient'.tr();
  static String get issueDate => 'issueDate'.tr();
  static String get dueDate => 'dueDate'.tr();
  static String get paidDate => 'paidDate'.tr();
  static String get invoiceItems => 'invoiceItems'.tr();
  static String get addItem => 'addItem'.tr();
  static String get itemName => 'itemName'.tr();
  static String get itemDescriptionHint => 'itemDescriptionHint'.tr();
  static String get quantity => 'quantity'.tr();
  static String get unitPrice => 'unitPrice'.tr();
  static String get taxRate => 'taxRate'.tr();
  static String get taxAmount => 'taxAmount'.tr();
  static String get grandTotal => 'grandTotal'.tr();
  static String get notes => 'notes'.tr();
  static String get notesHint => 'notesHint'.tr();
  static String get saveAsDraft => 'saveAsDraft'.tr();
  static String get invoiceCreatedSuccessfully =>
      'invoiceCreatedSuccessfully'.tr();
  static String get pleaseAddAtLeastOneItem => 'pleaseAddAtLeastOneItem'.tr();
  static String get statusDraft => 'statusDraft'.tr();
  static String get statusSent => 'statusSent'.tr();
  static String get statusOpened => 'statusOpened'.tr();
  static String get statusPaid => 'statusPaid'.tr();
  static String get statusOverdue => 'statusOverdue'.tr();
  static String get statusCancelled => 'statusCancelled'.tr();
  static String get all => 'all'.tr();
  static String get noClientsYet => 'noClientsYet'.tr();
  static String get noClientsAvailable => 'noClientsAvailable'.tr();
  static String get noInvoicesYet => 'noInvoicesYet'.tr();
  static String get noInvoicesFound => 'noInvoicesFound'.tr();
  static String get deleteInvoiceConfirmation =>
      'deleteInvoiceConfirmation'.tr();
  static String get invoiceDeletedSuccessfully =>
      'invoiceDeletedSuccessfully'.tr();
  static String get selectDate => 'selectDate'.tr();
  static String get updateStatus => 'updateStatus'.tr();
  static String get editInvoice => 'editInvoice'.tr();
  static String get invoiceDetails => 'invoiceDetails'.tr();
  static String get invoiceUpdatedSuccessfully =>
      'invoiceUpdatedSuccessfully'.tr();
  static String get deleteInvoice => 'deleteInvoice'.tr();
  static String get dashboard => 'dashboard'.tr();
  static String get monthlyEarnings => 'monthlyEarnings'.tr();
  static String get totalOverdue => 'totalOverdue'.tr();
  static String get pendingAmount => 'pendingAmount'.tr();
  static String get activeClients => 'activeClients'.tr();
  static String get revenueOverview => 'revenueOverview'.tr();
  static String get invoiceBreakdown => 'invoiceBreakdown'.tr();
  static String get recentInvoices => 'recentInvoices'.tr();
  static String get viewAll => 'viewAll'.tr();
  static String get totalRevenue => 'totalRevenue'.tr();
  static String get noAnalyticsData => 'noAnalyticsData'.tr();
  static String get sendInvoice => 'sendInvoice'.tr();
  static String get invoiceSentSuccessfully => 'invoiceSentSuccessfully'.tr();
  static String get confirmPaymentTitle => 'confirmPaymentTitle'.tr();
  static String get confirmPaymentSubtitle => 'confirmPaymentSubtitle'.tr();
  static String get confirmPaymentButton => 'confirmPaymentButton'.tr();
  static String get markAsPaid => 'markAsPaid'.tr();
  static String get cannotEditPaidOrCancelled =>
      'cannotEditPaidOrCancelled'.tr();
  static String get confirmSendInvoiceSubtitle =>
      'confirmSendInvoiceSubtitle'.tr();
  static String get cancelInvoice => 'cancelInvoice'.tr();
  static String get confirmCancelInvoiceSubtitle =>
      'confirmCancelInvoiceSubtitle'.tr();
}
