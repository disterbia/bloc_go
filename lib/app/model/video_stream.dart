class VideoStream {
  final String title;
  final String uploader;
  final String url;
  final String uploadTime;

  VideoStream({
    required this.title,
    required this.uploader,
    required this.url,
    required this.uploadTime,
  });

  factory VideoStream.fromJson(Map<String, dynamic> json) {
    return VideoStream(title: json['title'], uploader: json['uploader'],url: json['url'], uploadTime: json['upload_time']);
  }
}