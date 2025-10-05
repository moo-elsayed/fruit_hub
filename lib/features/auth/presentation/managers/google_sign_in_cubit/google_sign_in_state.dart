part of 'google_sign_in_cubit.dart';

@immutable
sealed class GoogleSignInState {}

final class GoogleSignInInitial extends GoogleSignInState {}

final class GoogleLoading extends GoogleSignInState {}

final class GoogleSuccess extends GoogleSignInState {}

final class GoogleFailure extends GoogleSignInState {
  GoogleFailure(this.message);

  final String message;
}
