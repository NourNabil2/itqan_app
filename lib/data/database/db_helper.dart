import 'package:itqan_gym/data/models/exercise_template.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/team.dart';
import '../models/member.dart';
import '../models/exercise.dart';
import '../models/progress.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gymnastics_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }


  Future _createDB(Database db, int version) async {
    // Teams
    await db.execute('''
    CREATE TABLE IF NOT EXISTS teams (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      age_category TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

    // Members
    await db.execute('''
  CREATE TABLE IF NOT EXISTS members (
    id TEXT PRIMARY KEY,
    team_id TEXT,  -- Nullable now
    name TEXT NOT NULL,
    age INTEGER NOT NULL,
    level TEXT NOT NULL,
    photo_path TEXT,
    notes TEXT,
    is_global INTEGER DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
  )
''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS team_member (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_id TEXT NOT NULL,
    member_id TEXT NOT NULL,
    joined_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE(team_id, member_id),
    FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE
  )
''');

    // Exercises (قديمة للاستخدام الداخلي/الموروث)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS exercises (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      difficulty TEXT NOT NULL,
      age_group TEXT NOT NULL,
      image_path TEXT,
      video_path TEXT,
      is_custom INTEGER DEFAULT 0,
      team_id TEXT,
      FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE
    )
  ''');

    // Progress
    await db.execute('''
    CREATE TABLE IF NOT EXISTS progress (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      member_id INTEGER NOT NULL,
      exercise_id INTEGER NOT NULL,
      status TEXT NOT NULL,
      completed_at TEXT,
      notes TEXT,
      FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE,
      FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE,
      UNIQUE(member_id, exercise_id)
    )
  ''');

    // Global Exercise Template
    await db.execute('''
    CREATE TABLE IF NOT EXISTS exercise_template (
      id TEXT PRIMARY KEY,
      type TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      media_path TEXT,
      media_type TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

    // Global Skill Template
    await db.execute('''
    CREATE TABLE IF NOT EXISTS skill_template (
      id TEXT PRIMARY KEY,
      apparatus TEXT NOT NULL,
      skill_name TEXT NOT NULL,
      thumbnail_path TEXT,
      media_gallery TEXT,
      technical_analysis TEXT,
      pre_requisites TEXT,
      skill_progression TEXT,
      drills TEXT,
      physical_preparation TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

    // Assignments
    await db.execute('''
    CREATE TABLE IF NOT EXISTS team_exercise (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      team_id TEXT NOT NULL,
      exercise_template_id TEXT NOT NULL,
      UNIQUE(team_id, exercise_template_id),
      FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE,
      FOREIGN KEY (exercise_template_id) REFERENCES exercise_template (id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS team_skill (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      team_id TEXT NOT NULL,
      skill_template_id TEXT NOT NULL,
      UNIQUE(team_id, skill_template_id),
      FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE,
      FOREIGN KEY (skill_template_id) REFERENCES skill_template (id) ON DELETE CASCADE
    )
  ''');

    await _insertSeedData(db);
  }


  Future<void> _insertSeedData(Database db) async {
    // Seed exercises for different age groups
    final seedExercises = [
      // Under 4 exercises
      {
        'name': 'Forward Roll',
        'description': 'Basic forward roll on mat',
        'category': 'Floor',
        'difficulty': 'Beginner',
        'age_group': 'under_4',
      },
      {
        'name': 'Balance Walk',
        'description': 'Walk on low beam with arms out',
        'category': 'Beam',
        'difficulty': 'Beginner',
        'age_group': 'under_4',
      },
      // Under 6 exercises
      {
        'name': 'Cartwheel',
        'description': 'Basic cartwheel technique',
        'category': 'Floor',
        'difficulty': 'Intermediate',
        'age_group': 'under_6',
      },
      {
        'name': 'Pull-ups',
        'description': 'Assisted pull-ups on bars',
        'category': 'Uneven Bars',
        'difficulty': 'Beginner',
        'age_group': 'under_6',
      },
      // Add more exercises as needed
    ];

    for (var exercise in seedExercises) {
      await db.insert('exercises', {
        ...exercise,
        'is_custom': 0,
      });
    }
  }

  // CRUD Operations for Teams
  Future<String> createTeam(Team team) async {
    final db = await database;
    await db.insert('teams', team.toMap());
    return team.id;
  }


  Future<List<Team>> getAllTeams() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT t.*, COUNT(m.id) as member_count
      FROM teams t
      LEFT JOIN members m ON t.id = m.team_id
      GROUP BY t.id
    ''');

    return result.map((map) => Team.fromMap(map)).toList();
  }

  Future<Team?> getTeam(int id) async {
    final db = await database;
    final maps = await db.query(
      'teams',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Team.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTeam(Team team) async {
    final db = await database;
    return await db.update(
      'teams',
      team.toMap(),
      where: 'id = ?',
      whereArgs: [team.id],
    );
  }

  Future<int> deleteTeam(String id) async {
    final db = await database;
    return await db.delete(
      'teams',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for Members

  Future<List<Member>> getGlobalMembers() async {
    final db = await database;
    final maps = await db.query(
      'members',
      where: 'is_global = 1',
      orderBy: 'name ASC',
    );
    return maps.map((map) => Member.fromMap(map)).toList();
  }

// Get members assigned to a team
  Future<List<Member>> getTeamAssignedMembers(String teamId) async {
    final db = await database;
    final maps = await db.rawQuery('''
    SELECT m.*
    FROM team_member tm
    JOIN members m ON m.id = tm.member_id
    WHERE tm.team_id = ?
    ORDER BY m.name ASC
  ''', [teamId]);
    return maps.map((m) => Member.fromMap(m)).toList();
  }

// Assign members to team
  Future<void> assignMembersToTeam(String teamId, List<String> memberIds) async {
    final db = await database;
    final batch = db.batch();

    // Clear existing assignments
    await db.delete('team_member', where: 'team_id = ?', whereArgs: [teamId]);

    // Add new assignments
    for (final memberId in memberIds) {
      batch.insert('team_member', {
        'team_id': teamId,
        'member_id': memberId,
        'joined_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
  }

// Create member (can be global or team-specific)
  Future<String> createMember(Member member) async {
    final db = await database;
    await db.insert('members', member.toMap());

    // If member has a teamId, also create assignment
    if (member.teamId != null && !member.isGlobal) {
      await db.insert('team_member', {
        'team_id': member.teamId,
        'member_id': member.id,
        'joined_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    return member.id;
  }

// Get all members (both global and team-specific) for a team
  Future<List<Member>> getAllTeamMembers(String teamId) async {
    final db = await database;

    // Get members assigned through team_member table
    final assignedMembers = await getTeamAssignedMembers(teamId);

    // Get members created directly for this team
    final directMembers = await db.query(
      'members',
      where: 'team_id = ? AND is_global = 0',
      whereArgs: [teamId],
    );

    final allMembers = <Member>[];
    allMembers.addAll(assignedMembers);
    allMembers.addAll(directMembers.map((m) => Member.fromMap(m)));

    // Remove duplicates based on member id
    final uniqueMembers = <String, Member>{};
    for (final member in allMembers) {
      uniqueMembers[member.id] = member;
    }

    return uniqueMembers.values.toList();
  }

  Future<List<Member>> getTeamMembers(String? teamId) async {
    final db = await database;
    final maps = await db.query(
      'members',
      where: 'team_id = ?',
      whereArgs: [teamId],
    );

    return maps.map((map) => Member.fromMap(map)).toList();
  }

  Future<Member?> getMember(int id) async {
    final db = await database;
    final maps = await db.query(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Member.fromMap(maps.first);
    }
    return null;
  }


  Future<void> updateMember(Member member) async {
    final db = await database;
    await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<void> deleteMember(String id) async {
    final db = await database;
    await db.delete(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for Exercises
  Future<int> createExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise.toMap());
  }

  Future<List<Exercise>> getExercisesByAgeGroup(String ageGroup) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'age_group = ? AND is_custom = 0',
      whereArgs: [ageGroup],
    );

    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Exercise>> getTeamCustomExercises(int teamId) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'team_id = ? AND is_custom = 1',
      whereArgs: [teamId],
    );

    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  // ===== Exercise Template CRUD =====
  Future<List<ExerciseTemplate>> getExerciseTemplates() async {
    final db = await database;
    final maps = await db.query('exercise_template', orderBy: 'updated_at DESC');
    return maps.map((m) => ExerciseTemplate.fromMap(m)).toList();
  }

  Future<String> createExerciseTemplate(ExerciseTemplate ex) async {
    final db = await database;
    await db.insert('exercise_template', ex.toMap());
    return ex.id; // ex.id uuid
  }

  Future<void> updateExerciseTemplate(ExerciseTemplate ex) async {
    final db = await database;
    await db.update('exercise_template', ex.toMap(), where: 'id = ?', whereArgs: [ex.id]);
  }

  Future<void> deleteExerciseTemplate(String id) async {
    final db = await database;
    await db.delete('exercise_template', where: 'id = ?', whereArgs: [id]);
  }

  // ===== Skill Template CRUD =====
  Future<List<SkillTemplate>> getSkillTemplates() async {
    final db = await database;
    final maps = await db.query('skill_template', orderBy: 'updated_at DESC');
    return maps.map((m) => SkillTemplate.fromMap(m)).toList();
  }

  Future<String> createSkillTemplate(SkillTemplate sk) async {
    final db = await database;
    await db.insert('skill_template', sk.toMap());
    return sk.id;
  }

  Future<void> updateSkillTemplate(SkillTemplate sk) async {
    final db = await database;
    await db.update('skill_template', sk.toMap(), where: 'id = ?', whereArgs: [sk.id]);
  }

  Future<void> deleteSkillTemplate(String id) async {
    final db = await database;
    await db.delete('skill_template', where: 'id = ?', whereArgs: [id]);
  }

// ===== Team Assignments =====
  Future<List<ExerciseTemplate>> getTeamAssignedExercises(String  teamId) async {
    final db = await database;
    final maps = await db.rawQuery('''
    SELECT et.*
    FROM team_exercise te
    JOIN exercise_template et ON et.id = te.exercise_template_id
    WHERE te.team_id = ?
    ORDER BY et.updated_at DESC
  ''', [teamId]);
    return maps.map((m) => ExerciseTemplate.fromMap(m)).toList();
  }

  Future<List<SkillTemplate>> getTeamAssignedSkills(String teamId) async {
    final db = await database;
    final maps = await db.rawQuery('''
    SELECT st.*
    FROM team_skill ts
    JOIN skill_template st ON st.id = ts.skill_template_id
    WHERE ts.team_id = ?
    ORDER BY st.updated_at DESC
  ''', [teamId]);
    return maps.map((m) => SkillTemplate.fromMap(m)).toList();
  }

  Future<void> assignExercisesToTeam(String teamId, List<String> templateIds) async {
    final db = await database;
    final batch = db.batch();
    // امسح القديم وادخل الجديد (أو اعمل upsert حسب ما تحب)
    await db.delete('team_exercise', where: 'team_id = ?', whereArgs: [teamId]);
    for (final id in templateIds) {
      batch.insert('team_exercise', {
        'team_id': teamId,
        'exercise_template_id': id,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<void> assignSkillsToTeam(String teamId, List<String> templateIds) async {
    final db = await database;
    final batch = db.batch();
    await db.delete('team_skill', where: 'team_id = ?', whereArgs: [teamId]);
    for (final id in templateIds) {
      batch.insert('team_skill', {
        'team_id': teamId,
        'skill_template_id': id,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  // Progress Operations
  Future<int> createOrUpdateProgress(Progress progress) async {
    final db = await database;
    return await db.insert(
      'progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Progress>> getMemberProgress(int memberId) async {
    final db = await database;
    final maps = await db.query(
      'progress',
      where: 'member_id = ?',
      whereArgs: [memberId],
    );

    return maps.map((map) => Progress.fromMap(map)).toList();
  }

  Future<double> getMemberOverallProgress(int memberId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(CASE WHEN status = 'Mastered' THEN 1 END) * 100.0 / 
        COUNT(*) as progress_percentage
      FROM progress
      WHERE member_id = ?
    ''', [memberId]);

    if (result.isNotEmpty && result.first['progress_percentage'] != null) {
      return (result.first['progress_percentage'] as num).toDouble();
    }
    return 0.0;
  }

  Future<Map<String, double>> getTeamProgress(int teamId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        e.category,
        COUNT(CASE WHEN p.status = 'Mastered' THEN 1 END) * 100.0 / 
        COUNT(*) as progress_percentage
      FROM members m
      JOIN progress p ON m.id = p.member_id
      JOIN exercises e ON p.exercise_id = e.id
      WHERE m.team_id = ?
      GROUP BY e.category
    ''', [teamId]);

    final progressMap = <String, double>{};
    for (var row in result) {
      progressMap[row['category'] as String] =
          (row['progress_percentage'] as num).toDouble();
    }
    return progressMap;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}