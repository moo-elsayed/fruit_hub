part of 'user_info_cubit.dart';

abstract class UserInfoState {}

class UserInfoInitial extends UserInfoState {}

class UserInfoLoading extends UserInfoState {}

class UserInfoSuccess extends UserInfoState {
  UserInfoSuccess(this.user);
  final UserEntity user;
}

class UserInfoFailure extends UserInfoState {
  UserInfoFailure(this.error);
  final String error;
}
