import 'package:itqan_gym/data/models/exercise_template.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/team.dart';
import '../models/member/member.dart';
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

    // Members - كل الأعضاء global
    await db.execute('''
    CREATE TABLE IF NOT EXISTS members (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      age INTEGER NOT NULL,
      level TEXT NOT NULL,
      photo_path TEXT,
      notes TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
  ''');

    // Member Notes
    await db.execute('''
    CREATE TABLE IF NOT EXISTS member_notes (
      id TEXT PRIMARY KEY,
      member_id TEXT NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      note_type TEXT NOT NULL DEFAULT 'general',
      priority TEXT NOT NULL DEFAULT 'normal',
      created_by TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE
    )
  ''');

    // Team Member (جدول الربط)
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

    // Progress
    await db.execute('''
    CREATE TABLE IF NOT EXISTS progress (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      member_id TEXT NOT NULL,
      exercise_id INTEGER NOT NULL,
      status TEXT NOT NULL,
      completed_at TEXT,
      notes TEXT,
      FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE,
      FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE,
      UNIQUE(member_id, exercise_id)
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

    // Global Exercise Template
    await db.execute('''
  CREATE TABLE IF NOT EXISTS exercise_template (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    thumbnail_path TEXT,
    media_gallery TEXT,
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

  // إصلاح الداتابيس الموجودة لإزالة team_id و is_global
  Future<void> fixExistingDatabase() async {
    final db = await database;

    try {
      // تحقق من البنية الحالية
      final tableInfo = await db.rawQuery("PRAGMA table_info(members)");
      final columns = tableInfo.map((row) => row['name'] as String).toSet();

      if (columns.contains('team_id') || columns.contains('is_global')) {
        print("Updating members table structure...");

        // إنشاء جدول مؤقت بالبنية الجديدة
        await db.execute('''
        CREATE TABLE IF NOT EXISTS members_new (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          age INTEGER NOT NULL,
          level TEXT NOT NULL,
          photo_path TEXT,
          notes TEXT,
          created_at TEXT NOT NULL DEFAULT (datetime('now')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
      ''');

        // نقل البيانات (بدون team_id و is_global)
        await db.execute('''
        INSERT INTO members_new (id, name, age, level, photo_path, notes, created_at, updated_at)
        SELECT id, name, age, level, photo_path, notes, 
               COALESCE(created_at, datetime('now')), 
               COALESCE(updated_at, datetime('now'))
        FROM members
      ''');

        // حذف الجدول القديم
        await db.execute('DROP TABLE members');

        // إعادة تسمية الجدول الجديد
        await db.execute('ALTER TABLE members_new RENAME TO members');

        print("Successfully updated members table structure");
      }

      // تأكد من وجود جدول member_notes
      await db.execute('''
      CREATE TABLE IF NOT EXISTS member_notes (
        id TEXT PRIMARY KEY,
        member_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        note_type TEXT NOT NULL DEFAULT 'general',
        priority TEXT NOT NULL DEFAULT 'normal',
        created_by TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE
      )
    ''');
    } catch (e) {
      print("Error fixing database: $e");
    }
  }

  Future<List<Team>> getAllTeams() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT t.*, COUNT(tm.member_id) as member_count
    FROM teams t
    LEFT JOIN team_member tm ON t.id = tm.team_id
    GROUP BY t.id
  ''');

    return result.map((map) => Team.fromMap(map)).toList();
  }

  Future<double> getMemberOverallProgress(String memberId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT 
      COUNT(CASE WHEN status = 'Mastered' THEN 1 END) * 100.0 / 
      NULLIF(COUNT(*), 0) as progress_percentage
    FROM progress
    WHERE member_id = ?
  ''', [memberId]);

    if (result.isNotEmpty && result.first['progress_percentage'] != null) {
      return (result.first['progress_percentage'] as num).toDouble();
    }
    return 0.0;
  }

  Future<List<Progress>> getMemberProgress(String memberId) async {
    final db = await database;
    final maps = await db.query(
      'progress',
      where: 'member_id = ?',
      whereArgs: [memberId],
    );

    return maps.map((map) => Progress.fromMap(map)).toList();
  }

  Future<Map<String, double>> getTeamProgress(String teamId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT 
      e.category,
      COUNT(CASE WHEN p.status = 'Mastered' THEN 1 END) * 100.0 / 
      COUNT(*) as progress_percentage
    FROM team_member tm
    JOIN members m ON tm.member_id = m.id
    JOIN progress p ON m.id = p.member_id
    JOIN exercises e ON p.exercise_id = e.id
    WHERE tm.team_id = ?
    GROUP BY e.category
  ''', [teamId]);

    final progressMap = <String, double>{};
    for (var row in result) {
      progressMap[row['category'] as String] =
          (row['progress_percentage'] as num).toDouble();
    }
    return progressMap;
  }

  Future<List<Member>> getTeamMembers(String teamId) async {
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

  // تعيين الأعضاء للفريق
  Future<void> assignMembersToTeam(
      String teamId, List<String> memberIds) async {
    final db = await database;
    final batch = db.batch();

    // حذف التعيينات السابقة
    await db.delete('team_member', where: 'team_id = ?', whereArgs: [teamId]);

    // إضافة التعيينات الجديدة
    for (final memberId in memberIds) {
      batch.insert(
          'team_member',
          {
            'team_id': teamId,
            'member_id': memberId,
            'joined_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
  }

  // CRUD Operations for Members - كل الأعضاء global
  Future<String> createMember(Member member) async {
    final db = await database;
    await db.insert('members', member.toMap());
    return member.id;
  }

  // جلب كل الأعضاء (كلهم global الآن)
  Future<List<Member>> getAllMembers() async {
    final db = await database;
    final maps = await db.query(
      'members',
      orderBy: 'name ASC',
    );
    return maps.map((map) => Member.fromMap(map)).toList();
  }

  Future<Member?> getMember(String id) async {
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

  Future<int> unassignMemberFromTeam(String teamId, String memberId) async {
    final db = await database;
    return db.delete(
      'team_member',
      where: 'team_id = ? AND member_id = ?',
      whereArgs: [teamId, memberId],
    );
  }

  Future<void> deleteMember(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      // حذف من جدول الربط
      await txn.delete('team_member', where: 'member_id = ?', whereArgs: [id]);
      // حذف العضو
      final deleted =
          await txn.delete('members', where: 'id = ?', whereArgs: [id]);
      if (deleted == 0) throw Exception('No member deleted (id=$id)');
    });
  }

  // جلب الأعضاء غير المعينين لفريق معين
  Future<List<Member>> getUnassignedMembers(String teamId) async {
    final db = await database;
    final maps = await db.rawQuery('''
    SELECT m.*
    FROM members m
    WHERE m.id NOT IN (
      SELECT tm.member_id 
      FROM team_member tm 
      WHERE tm.team_id = ?
    )
    ORDER BY m.name ASC
  ''', [teamId]);
    return maps.map((m) => Member.fromMap(m)).toList();
  }

  // تحقق إذا كان العضو معين لفريق معين
  Future<bool> isMemberAssignedToTeam(String memberId, String teamId) async {
    final db = await database;
    final result = await db.query(
      'team_member',
      where: 'member_id = ? AND team_id = ?',
      whereArgs: [memberId, teamId],
    );
    return result.isNotEmpty;
  }

  // جلب الفرق التي ينتمي إليها العضو
  Future<List<Team>> getMemberTeams(String memberId) async {
    final db = await database;
    final maps = await db.rawQuery('''
    SELECT t.*
    FROM team_member tm
    JOIN teams t ON t.id = tm.team_id
    WHERE tm.member_id = ?
    ORDER BY t.name ASC
  ''', [memberId]);
    return maps.map((m) => Team.fromMap(m)).toList();
  }

  // CRUD Operations for Member Notes
  Future<String> createMemberNote(MemberNote note) async {
    final db = await database;
    await db.insert('member_notes', note.toMap());
    return note.id;
  }

  Future<List<MemberNote>> getMemberNotes(String memberId) async {
    final db = await database;
    final maps = await db.query(
      'member_notes',
      where: 'member_id = ?',
      whereArgs: [memberId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MemberNote.fromMap(map)).toList();
  }

  Future<void> updateMemberNote(MemberNote note) async {
    final db = await database;
    await db.update(
      'member_notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteMemberNote(String id) async {
    final db = await database;
    await db.delete(
      'member_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MemberNote>> getMemberNotesByType(
      String memberId, String noteType) async {
    final db = await database;
    final maps = await db.query(
      'member_notes',
      where: 'member_id = ? AND note_type = ?',
      whereArgs: [memberId, noteType],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MemberNote.fromMap(map)).toList();
  }

  Future<List<MemberNote>> getHighPriorityNotes(String memberId) async {
    final db = await database;
    final maps = await db.query(
      'member_notes',
      where: 'member_id = ? AND priority = ?',
      whereArgs: [memberId, 'high'],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MemberNote.fromMap(map)).toList();
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
    final maps =
        await db.query('exercise_template', orderBy: 'updated_at DESC');
    return maps.map((m) => ExerciseTemplate.fromMap(m)).toList();
  }

  Future<String> createExerciseTemplate(ExerciseTemplate ex) async {
    final db = await database;
    await db.insert('exercise_template', ex.toMap());
    return ex.id;
  }

  Future<void> updateExerciseTemplate(ExerciseTemplate ex) async {
    final db = await database;
    await db.update('exercise_template', ex.toMap(),
        where: 'id = ?', whereArgs: [ex.id]);
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
    await db.update('skill_template', sk.toMap(),
        where: 'id = ?', whereArgs: [sk.id]);
  }

  Future<void> deleteSkillTemplate(String id) async {
    final db = await database;
    await db.delete('skill_template', where: 'id = ?', whereArgs: [id]);
  }

  // ===== Team Assignments =====
  Future<List<ExerciseTemplate>> getTeamAssignedExercises(String teamId) async {
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

  Future<void> assignExercisesToTeam(
      String teamId, List<String> templateIds) async {
    final db = await database;
    final batch = db.batch();
    await db.delete('team_exercise', where: 'team_id = ?', whereArgs: [teamId]);
    for (final id in templateIds) {
      batch.insert(
          'team_exercise',
          {
            'team_id': teamId,
            'exercise_template_id': id,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<void> assignSkillsToTeam(
      String teamId, List<String> templateIds) async {
    final db = await database;
    final batch = db.batch();
    await db.delete('team_skill', where: 'team_id = ?', whereArgs: [teamId]);
    for (final id in templateIds) {
      batch.insert(
          'team_skill',
          {
            'team_id': teamId,
            'skill_template_id': id,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  /// إضافة أعضاء جدد للفريق (بدون حذف الموجودين)
  Future<void> addMembersToTeam(String teamId, List<String> memberIds) async {
    final db = await database;

    // استخدام transaction لضمان إضافة جميع الأعضاء أو فشل العملية بالكامل
    await db.transaction((txn) async {
      for (String memberId in memberIds) {
        await txn.insert(
          'team_member',
          {
            'team_id': teamId,
            'member_id': memberId,
            'joined_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm:
              ConflictAlgorithm.ignore, // تجاهل إذا كان العضو مضاف بالفعل
        );
      }
    });
  }

  /// إزالة عضو واحد من الفريق
  Future<void> removeMemberFromTeam(String teamId, String memberId) async {
    final db = await database;

    await db.delete(
      'team_member',
      where: 'team_id = ? AND member_id = ?',
      whereArgs: [teamId, memberId],
    );
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

  // إعادة تعيين الداتابيس في حالة المشاكل
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gymnastics_app.db');

    await deleteDatabase(path);
    _database = null;
    await database;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
