class StoryPageModel {
  StoryPageModel({required this.text, required this.image});

  final String text;
  final String image;

  factory StoryPageModel.fromJson(Map<String, dynamic> j) {
    return StoryPageModel(
      text: (j['text'] ?? '') as String,
      image: (j['image'] ?? 'panda.png') as String,
    );
  }
}
