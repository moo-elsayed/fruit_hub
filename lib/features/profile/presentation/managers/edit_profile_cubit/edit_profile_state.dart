part of 'edit_profile_cubit.dart';

sealed class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

final class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

final class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

final class EditProfileSuccess extends EditProfileState {
  const EditProfileSuccess(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

final class EditProfileFailure extends EditProfileState {
  const EditProfileFailure(this.errorMessage);

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}
