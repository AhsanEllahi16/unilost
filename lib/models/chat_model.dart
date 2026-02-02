class ChatModel {
  final String id;
  final String title;
  final String postedBy;
  final bool unread;
  final DateTime createdAt;
  final Map<String, dynamic> item;

  ChatModel({
    required this.id,
    required this.title,
    required this.postedBy,
    required this.unread,
    required this.createdAt,
    required this.item,
  });

  ChatModel copyWith({
    bool? unread,
  }) {
    return ChatModel(
      id: id,
      title: title,
      postedBy: postedBy,
      unread: unread ?? this.unread,
      createdAt: createdAt,
      item: item,
    );
  }
}
