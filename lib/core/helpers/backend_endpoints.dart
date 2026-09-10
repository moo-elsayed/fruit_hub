class BackendEndpoints {
  BackendEndpoints._();

  // Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String constantsCollection = 'constants';
  static const String notificationsCollection = 'notifications';

  // Documents
  static const String shippingConfigDoc = 'shipping_config';

  // Fields
  static const String favoriteIdsField = 'favoriteIds';
  static const String cartItemsField = 'cartItems';
  static const String customerIdField = 'customerId';
  static const String freeShippingThresholdField = 'free_shipping_threshold';
  static const String shippingCostField = 'shipping_cost';

  // Storage
  static const String userAvatarsStorage = 'users_avatars';
}
