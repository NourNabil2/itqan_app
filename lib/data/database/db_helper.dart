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


// في DatabaseHelper.dart - صحح اسم الجدول في _createDB

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

    // Members - غير من "member" لـ "members"
    await db.execute('''
    CREATE TABLE IF NOT EXISTS members (
      id TEXT PRIMARY KEY,
      team_id TEXT,
      name TEXT NOT NULL,
      age INTEGER NOT NULL,
      level TEXT NOT NULL,
      photo_path TEXT,
      notes TEXT,
      is_global INTEGER DEFAULT 0,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE SET NULL
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

    // Progress - غير الـ FOREIGN KEY reference
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

// اضيف method جديدة لتصحيح الجداول الموجودة
  Future<void> fixExistingDatabase() async {
    final db = await database;

    try {
      // تحقق من وجود الجدول الخطأ
      final wrongTable = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='member'"
      );

      if (wrongTable.isNotEmpty) {
        print("Found table 'member', renaming to 'members'");

        // أنشئ الجدول الصحيح
        await db.execute('''
        CREATE TABLE IF NOT EXISTS members (
          id TEXT PRIMARY KEY,
          team_id TEXT,
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

        // انقل البيانات
        await db.execute('''
        INSERT INTO members 
        SELECT * FROM member
      ''');

        // احذف الجدول الخطأ
        await db.execute('DROP TABLE member');

        print("Successfully migrated data from 'member' to 'members'");
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

// اضيف في getAllTeams method تصحيح للـ JOIN
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

// صحح كل الـ progress methods
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

// اضيف في getTeamAssignedMembers تصحيح للـ JOIN
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


// Assign member to team
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

  // CRUD Operations for Members - Fixed table name
  Future<String> createMember(Member member) async {
    final db = await database;
    // تأكد إن اسم الجدول "members" مش "member"
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


//////////////////////////////////////////////////////////-------------------------------------
  Future<List<Member>> getGlobalMembers() async {
    final db = await database;
    final maps = await db.query(
      'members', // تأكد إن اسم الجدول صحيح
      where: 'is_global = 1',
      orderBy: 'name ASC',
    );
    return maps.map((map) => Member.fromMap(map)).toList();
  }

  Future<List<Member>> getTeamMembers(String? teamId) async {
    final db = await database;
    final maps = await db.query(
      'members', // تأكد إن اسم الجدول صحيح
      where: 'team_id = ?',
      whereArgs: [teamId],
    );
    return maps.map((map) => Member.fromMap(map)).toList();
  }

  Future<Member?> getMember(String id) async { // غيرت من int لـ String
    final db = await database;
    final maps = await db.query(
      'members', // تأكد إن اسم الجدول صحيح
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
      'members', // تأكد إن اسم الجدول صحيح
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

  /// حذف نهائي (مع الكاسكيد)
  Future<void> hardDeleteMember(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      // مع تمكين FK، مش لازم تحذف من team_member يدويًا
      // لكن لو حابب أمان إضافي:
      await txn.delete('team_member', where: 'member_id = ?', whereArgs: [id]);

      final deleted = await txn.delete('members', where: 'id = ?', whereArgs: [id]);
      if (deleted == 0) {
        throw Exception('No member found with id $id');
      }
    });
  }

  /// بدّل دالتك الحالية إلى:
  Future<void> deleteMember(String id) async {
    // لو مصرّ تبقيها، خَلّها تشتغل داخل transaction وتتحقق من عدد الصفوف:
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('team_member', where: 'member_id = ?', whereArgs: [id]);
      final deleted = await txn.delete('members', where: 'id = ?', whereArgs: [id]);
      if (deleted == 0) throw Exception('No member deleted (id=$id)');
    });
  }



  // Get all members (both global and team-specific) for a team
  Future<List<Member>> getAllTeamMembers(String teamId) async {
    final db = await database;

    // Get members assigned through team_member table
    final assignedMembers = await getTeamAssignedMembers(teamId);

    // Get members created directly for this team
    final directMembers = await db.query(
      'members', // تأكد إن اسم الجدول صحيح
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


  // إضافة method للتحقق من وجود الجداول
  Future<void> checkTables() async {
    final db = await database;

    // تحقق من وجود جدول members
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='members'"
    );

    print("Members table exists: ${tables.isNotEmpty}");

    if (tables.isEmpty) {
      print("Creating members table...");
      await _createMembersTable(db);
    }

    // اطبع كل الجداول الموجودة
    final allTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
    );
    print("All tables: ${allTables.map((t) => t['name']).toList()}");
  }
//////////////////////////////////////////////////////////-------------------------------------
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

  // Get notes by type
  Future<List<MemberNote>> getMemberNotesByType(String memberId, String noteType) async {
    final db = await database;
    final maps = await db.query(
      'member_notes',
      where: 'member_id = ? AND note_type = ?',
      whereArgs: [memberId, noteType],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MemberNote.fromMap(map)).toList();
  }

  // Get high priority notes
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


  Future<void> _createMembersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS members (
        id TEXT PRIMARY KEY,
        team_id TEXT,
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
  }

  // إضافة method لـ reset الداتابيس في حالة المشاكل
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gymnastics_app.db');

    // احذف الداتابيس
    await deleteDatabase(path);

    // اعيد إنشاءها
    _database = null;
    await database; // هيعيد إنشاء الداتابيس
  }


  Future<void> close() async {
    final db = await database;
    db.close();
  }
}