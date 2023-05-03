class Message {
  final String username;
  final String text;
  final String? sendTime;
  final int? totalCount;

  Message({required this.username, required this.text,this.sendTime,this.totalCount});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(username: json['username'], text: json['text'],sendTime: json['sendTime'],totalCount: json['total_count']);
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'text': text ,
      'sendTime': sendTime
    };
  }
}