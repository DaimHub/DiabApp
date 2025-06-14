class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String? imageUrl;
  final int readTime;
  final String difficulty;
  final List<String> tags;
  final bool published;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final String author;
  final int order;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.imageUrl,
    required this.readTime,
    required this.difficulty,
    required this.tags,
    required this.published,
    required this.publishedAt,
    required this.updatedAt,
    required this.author,
    required this.order,
  });

  factory Article.fromFirestore(String id, Map<String, dynamic> data) {
    return Article(
      id: id,
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      readTime: data['readTime'] ?? 0,
      difficulty: data['difficulty'] ?? 'beginner',
      tags: List<String>.from(data['tags'] ?? []),
      published: data['published'] ?? false,
      publishedAt: data['publishedAt'] is String
          ? DateTime.parse(data['publishedAt'])
          : data['publishedAt'] is DateTime
          ? data['publishedAt']
          : (data['publishedAt']?.toDate() ?? DateTime.now()),
      updatedAt: data['updatedAt'] is String
          ? DateTime.parse(data['updatedAt'])
          : data['updatedAt'] is DateTime
          ? data['updatedAt']
          : (data['updatedAt']?.toDate() ?? DateTime.now()),
      author: data['author'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'readTime': readTime,
      'difficulty': difficulty,
      'tags': tags,
      'published': published,
      'publishedAt': publishedAt,
      'updatedAt': updatedAt,
      'author': author,
      'order': order,
    };
  }
}
