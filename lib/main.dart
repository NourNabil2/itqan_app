// ============= main.dart - محسن =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'core/theme/app_theme.dart';
import 'providers/exercise_library_provider.dart';
import 'providers/skill_library_provider.dart';
import 'providers/team_provider.dart';
import 'providers/member_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'data/database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// final dbPath = await getDatabasesPath();
// await deleteDatabase(join(dbPath, 'gymnastics_app.db'));

  try {
    await DatabaseHelper.instance.fixExistingDatabase();
  } catch (e) {
    debugPrint('Database fix error: $e');
  }

  runApp(const GymnasticsApp());
}

class GymnasticsApp extends StatelessWidget {
  const GymnasticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseLibraryProvider()),
        ChangeNotifierProvider(create: (_) => SkillLibraryProvider()),
        ChangeNotifierProvider(create: (_) => MemberLibraryProvider()),
        ChangeNotifierProvider(create: (_) => MemberNotesProvider()),
        ChangeNotifierProvider(create: (_) => MemberNotesProvider()),
        ChangeNotifierProvider<ExerciseAssignmentProvider>(
          create: (_) => ExerciseAssignmentProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Itqan',
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: const DashboardScreen(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

