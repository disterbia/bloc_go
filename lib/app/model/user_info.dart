class UserInfo {
  final String id;
  final String image;
  final String nickname;
  final String intro;
  final String thumbnail;

  UserInfo({required this.id, required this.image,required this.thumbnail,required this.nickname,required this.intro});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(id: json['id'], image: json['image'],thumbnail: json['thumbnail'],nickname: json["nickname"],intro: json["introduction"]);
  }
}
