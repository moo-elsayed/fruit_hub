part of 'social_sign_in_cubit.dart';

@immutable
sealed class SocialSignInState {}

final class SocialSignInInitial extends SocialSignInState {}

final class GoogleLoading extends SocialSignInState {}

final class GoogleSuccess extends SocialSignInState {}

final class GoogleFailure extends SocialSignInState {
  GoogleFailure(this.message);

  final String message;
}

final class FacebookLoading extends SocialSignInState {}

final class FacebookSuccess extends SocialSignInState {}

final class FacebookFailure extends SocialSignInState {
  FacebookFailure(this.message);

  final String message;
}
