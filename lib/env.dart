import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_KEY_ANDROID', obfuscate: true)
  static final String apiKeyAndroid = _Env.apiKeyAndroid;

  @EnviedField(varName: 'API_KEY_IOS', obfuscate: true)
  static final String apiKeyIos = _Env.apiKeyIos;

  @EnviedField(varName: 'PAYPAL_CLIENT_ID', obfuscate: true)
  static final String paypalClientId = _Env.paypalClientId;

  @EnviedField(varName: 'PAYPAL_SECRET_KEY', obfuscate: true)
  static final String paypalSecretKey = _Env.paypalSecretKey;

  @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY', obfuscate: true)
  static final String stripePublishableKey = _Env.stripePublishableKey;

  @EnviedField(varName: 'STRIPE_SECRET_KEY', obfuscate: true)
  static final String stripeSecretKey = _Env.stripeSecretKey;
}
