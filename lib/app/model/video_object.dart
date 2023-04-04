class VideoObject {
  final String title;
  final String uploader;
  final String path;

  VideoObject({
    required this.title,
    required this.uploader,
    required this.path,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'uploader': uploader,
      'path': path,
    };
  }
}