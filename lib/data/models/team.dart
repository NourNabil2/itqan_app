import 'package:itqan_gym/core/utils/enums.dart';
import 'package:uuid/uuid.dart';


class Team {
  final String id;
  final String name;
  final AgeCategory ageCategory;
  final DateTime createdAt;
  final DateTime updatedAt;
  int memberCount;
  double completionPercentage;

  Team({
    String? id,
    required this.name,
    required this.ageCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.memberCount = 0,
    this.completionPercentage = 0.0,
  }) : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age_category': ageCategory.code,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    // نحاول نحول الـid لأي حالة (int أو String) إلى String
    final dynamic rawId = map['id'];
    final String safeId =
    rawId == null ? const Uuid().v4() : rawId.toString();

    // بعض الجداول القديمة كان اسم العمود age_group بدل age_category
    final dynamic ageCodeRaw = map['age_category'] ?? map['age_group'];
    final String ageCode = ageCodeRaw?.toString() ?? '';

    // نحاول نجيب الـ AgeCategory من الكود، لو مش لاقي نحط الافتراضي U6
    final AgeCategory safeAgeCategory =
    AgeCategory.values.firstWhere(
          (a) => a.code.toLowerCase() == ageCode.toLowerCase(),
      orElse: () => AgeCategory.u6,
    );

    // تواريخ آمنة (لو العمود null أو مش String)
    DateTime parseDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {}
      }
      return DateTime.now();
    }

    double toDoubleSafe(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int toIntSafe(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return Team(
      id: safeId,
      name: (map['name'] ?? '').toString(),
      ageCategory: safeAgeCategory,
      createdAt: parseDate(map['created_at']),
      updatedAt: parseDate(map['updated_at']),
      memberCount: toIntSafe(map['member_count']),
      completionPercentage: toDoubleSafe(map['completion_percentage']),
    );
  }

}