
enum MoodType {
  happy,
  neutral,
  angry;

  String get emoji {
    switch (this) {
      case MoodType.happy:
        return '😊';
      case MoodType.neutral:
        return '😐';
      case MoodType.angry:
        return '😡';
    }
  }

  String label(bool isEnglish) {
    switch (this) {
      case MoodType.happy:
        return isEnglish ? 'Happy' : 'Senang';
      case MoodType.neutral:
        return isEnglish ? 'Neutral' : 'Netral';
      case MoodType.angry:
        return isEnglish ? 'Angry' : 'Marah';
    }
  }
}

class MoodModel {
  final String id;
  final String userId;
  final DateTime date;
  final MoodType mood;
  final int level; // 1-5
  final DateTime createdAt;

  MoodModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.level,
    required this.createdAt,
  });

  factory MoodModel.fromMap(Map<String, dynamic> map, String docId) {
    return MoodModel(
      id: docId,
      userId: map['userId'] ?? '',
      date: DateTime.parse(map['date'] as String),
      mood: MoodType.values.firstWhere(
        (m) => m.name == map['mood'],
        orElse: () => MoodType.neutral,
      ),
      level: map['level'] ?? 3,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'mood': mood.name,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
