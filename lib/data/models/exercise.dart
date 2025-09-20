class Exercise {
  final int? id;
  final String name;
  final String description;
  final String category; // Floor, Beam, etc.
  final String difficulty; // Beginner, Intermediate, Advanced
  final String ageGroup;
  final String? imagePath;
  final String? videoPath;
  final bool isCustom;
  final int? teamId; // For custom exercises

  Exercise({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.ageGroup,
    this.imagePath,
    this.videoPath,
    this.isCustom = false,
    this.teamId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'age_group': ageGroup,
      'image_path': imagePath,
      'video_path': videoPath,
      'is_custom': isCustom ? 1 : 0,
      'team_id': teamId,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      difficulty: map['difficulty'],
      ageGroup: map['age_group'],
      imagePath: map['image_path'],
      videoPath: map['video_path'],
      isCustom: map['is_custom'] == 1,
      teamId: map['team_id'],
    );
  }
}