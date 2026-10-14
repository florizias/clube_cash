class NewsCard {
  final String id;
  final String tag;
  final String title;
  final String buttonText;
  final String thumbnailUrl;

  const NewsCard({
    required this.id,
    required this.tag,
    required this.title,
    required this.buttonText,
    required this.thumbnailUrl,
  });

  factory NewsCard.fromJson(Map<String, dynamic> json) {
    return NewsCard(
      id: (json['id'] ?? '').toString(),
      tag: (json['tag'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      buttonText: (json['buttonText'] ?? 'Saiba mais').toString(),
      thumbnailUrl: (json['thumbnailUrl'] ?? '').toString(),
    );
  }
}
