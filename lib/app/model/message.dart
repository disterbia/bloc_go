class Message {
  final String username;
  final String text;

  Message({required this.username, required this.text});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(username: json['username'], text: json['text']);
  }
}