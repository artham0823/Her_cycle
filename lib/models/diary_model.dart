
class DiaryModel {
  final String id;
  final String userId;
  final DateTime date;
  final String content;
  final DateTime createdAt;

  DiaryModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.content,
    required this.createdAt,
  });

  factory DiaryModel.fromMap(Map<String, dynamic> map, String docId) {
    return DiaryModel(
      id: docId,
      userId: map['userId'] ?? '',
      date: DateTime.parse(map['date'] as String),
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  DiaryModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? content,
    DateTime? createdAt,
  }) {
    return DiaryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
