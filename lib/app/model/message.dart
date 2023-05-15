class Message {
  final String username;
  final String nickname;
  final String userImage;
  final String text;
  final String? sendTime;
  final int? totalCount;

  Message({required this.username, required this.text,this.sendTime,this.totalCount,required this.userImage,required this.nickname});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(username: json['username'], text: json['text'],sendTime: json['sendTime'],totalCount: json['total_count'],nickname: json["nickname"],userImage: json['user_image']);
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'user_image': userImage,
      'username': username,
      'text': text ,
      'sendTime': sendTime
    };
  }
}