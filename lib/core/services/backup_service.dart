// lib/services/backup_service.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BackupService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String bucketName = 'database-backups';

  // Get database file path
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, 'gymnastics_app.db');
  }

  Future<bool> deleteBackup(String backupPath) async {
    try {
      await _supabase.storage
          .from(bucketName)
          .remove([backupPath]);
      return true;
    } catch (e) {
      print('Error deleting backup: $e');
      return false;
    }
  }

  // Create backup and upload to Supabase
  Future<BackupResult> createBackup() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Get database file
      final dbPath = await getDatabasePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      // Read database file
      final bytes = await dbFile.readAsBytes();
      final fileSize = bytes.length;

      // Generate filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = '$userId/backup_$timestamp.db';

      // Upload to Supabase Storage
      await _supabase.storage.from(bucketName).uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'application/x-sqlite3',
          upsert: false,
        ),
      );

      return BackupResult(
        success: true,
        message: 'Backup created successfully',
        fileName: fileName,
        fileSize: fileSize,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Backup failed: ${e.toString()}',
      );
    }
  }

  // Get list of available backups
  Future<List<BackupInfo>> getBackupsList() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final files = await _supabase.storage
          .from(bucketName)
          .list(path: userId);

      return files
          .map((file) => BackupInfo(
        name: file.name,
        size: file.metadata?['size'] ?? 0,
        createdAt: DateTime.parse(file.createdAt ?? DateTime.now().toIso8601String()),
        fullPath: '$userId/${file.name}',
      ))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get backups list: ${e.toString()}');
    }
  }

  // Restore from latest backup
  Future<RestoreResult> restoreLatestBackup() async {
    try {
      final backups = await getBackupsList();
      if (backups.isEmpty) {
        throw Exception('No backups found');
      }

      final latestBackup = backups.first;
      return await restoreFromBackup(latestBackup.fullPath);
    } catch (e) {
      return RestoreResult(
        success: false,
        message: 'Restore failed: ${e.toString()}',
      );
    }
  }

  // Restore from specific backup
  Future<RestoreResult> restoreFromBackup(String backupPath) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Download backup file
      final bytes = await _supabase.storage
          .from(bucketName)
          .download(backupPath);

      // Get current database path
      final dbPath = await getDatabasePath();

      // Create backup of current database before replacing
      final currentDbFile = File(dbPath);
      if (await currentDbFile.exists()) {
        final backupPath = '$dbPath.bak';
        await currentDbFile.copy(backupPath);
      }

      // Write downloaded backup to database location
      final newDbFile = File(dbPath);
      await newDbFile.writeAsBytes(bytes);

      return RestoreResult(
        success: true,
        message: 'Database restored successfully',
        restoredFrom: backupPath,
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        message: 'Restore failed: ${e.toString()}',
      );
    }
  }

  // Delete old backups (keep only last N backups)
  Future<void> cleanOldBackups({int keepCount = 5}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final backups = await getBackupsList();

      if (backups.length <= keepCount) return;

      // Delete old backups
      final toDelete = backups.skip(keepCount).toList();
      for (final backup in toDelete) {
        await _supabase.storage
            .from(bucketName)
            .remove([backup.fullPath]);
      }
    } catch (e) {
      print('Error cleaning old backups: $e');
    }
  }

  // Get backup info (size, count)
  Future<BackupStats> getBackupStats() async {
    try {
      final backups = await getBackupsList();
      final totalSize = backups.fold<int>(
        0,
            (sum, backup) => sum + backup.size,
      );

      return BackupStats(
        count: backups.length,
        totalSize: totalSize,
        lastBackup: backups.isNotEmpty ? backups.first.createdAt : null,
      );
    } catch (e) {
      return BackupStats(count: 0, totalSize: 0);
    }
  }
}

// Models
class BackupResult {
  final bool success;
  final String message;
  final String? fileName;
  final int? fileSize;
  final DateTime? timestamp;

  BackupResult({
    required this.success,
    required this.message,
    this.fileName,
    this.fileSize,
    this.timestamp,
  });
}

class RestoreResult {
  final bool success;
  final String message;
  final String? restoredFrom;

  RestoreResult({
    required this.success,
    required this.message,
    this.restoredFrom,
  });
}

class BackupInfo {
  final String name;
  final int size;
  final DateTime createdAt;
  final String fullPath;

  BackupInfo({
    required this.name,
    required this.size,
    required this.createdAt,
    required this.fullPath,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class BackupStats {
  final int count;
  final int totalSize;
  final DateTime? lastBackup;

  BackupStats({
    required this.count,
    required this.totalSize,
    this.lastBackup,
  });

  String get totalSizeFormatted {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}