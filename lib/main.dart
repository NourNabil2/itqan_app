import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/exercise_library_provider.dart';
import 'providers/skill_library_provider.dart';
import 'providers/team_provider.dart';
import 'providers/member_provider.dart';
// import 'providers/exercise_provider.dart';
// import 'providers/progress_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final dbPath = await getDatabasesPath();
  // await deleteDatabase(join(dbPath, 'gymnastics_app.db'));
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
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Gymnastics Coach',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}