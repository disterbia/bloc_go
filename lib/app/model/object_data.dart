class ObjectData {
  final String userId;
  final List<String> imageFiles;

  ObjectData({required this.userId,  required this.imageFiles});

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'imageFiles': imageFiles,
  };
}