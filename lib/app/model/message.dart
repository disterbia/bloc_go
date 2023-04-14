class Message {
  final String username;
  final String text;
  final String sendTime;

  Message({required this.username, required this.text,required this.sendTime});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(username: json['username'], text: json['text'],sendTime: json['sendTime'],);
  }
}