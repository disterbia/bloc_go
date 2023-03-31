class ObjectData {
  final String title;
  final String description;
  final List<String> imageFiles;

  ObjectData({required this.title, required this.description, required this.imageFiles});

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'imageFiles': imageFiles,
  };
}