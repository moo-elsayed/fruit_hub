class UserEntity {
  UserEntity({this.uid = '', this.name, this.email, this.isVerified = false});

  final String uid;
  String? name;
  String? email;
  final bool isVerified;
}
