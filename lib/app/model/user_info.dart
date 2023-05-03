class UserInfo {
  final String id;
  final String image;
  final String thumbnail;

  UserInfo({required this.id, required this.image,required this.thumbnail});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(id: json['id'], image: json['image'],thumbnail: json['thumbnail']);
  }
}
