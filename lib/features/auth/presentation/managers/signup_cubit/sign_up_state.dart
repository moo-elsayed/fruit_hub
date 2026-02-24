part of 'sign_up_cubit.dart';

@immutable
sealed class SignupState {}

final class SignUpInitial extends SignupState {}

final class SignUpLoading extends SignupState {}

final class SignUpSuccess extends SignupState {}

final class SignUpFailure extends SignupState {
  SignUpFailure(this.message);

  final String message;
}
