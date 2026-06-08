
class PeriodModel {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime createdAt;

  PeriodModel({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.createdAt,
  });

  factory PeriodModel.fromMap(Map<String, dynamic> map, String docId) {
    return PeriodModel(
      id: docId,
      userId: map['userId'] ?? '',
      startDate: DateTime.parse(map['startDate'] as String),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
