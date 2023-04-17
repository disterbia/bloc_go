class UserInfo {
  final String id;
  final String image;

  UserInfo({required this.id, required this.image});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(id: json['id'], image: json['image']);
  }
}
