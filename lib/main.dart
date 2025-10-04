import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // إضافة هذا السطر
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:itqan_gym/core/services/ad_service.dart';
import 'package:itqan_gym/providers/auth_provider.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/language/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/exercise_library_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/skill_library_provider.dart';
import 'providers/team_provider.dart';
import 'providers/member_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'data/database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ============ Initialize Supabase ============
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );


  // ============ DataBase ============
  try {
    await DatabaseHelper.instance.fixExistingDatabase();
  } catch (e) {
    debugPrint('Database fix error: $e');
  }

  // ============ Initialize AdMob ============
  await AdsService.instance.initialize();
  runApp(const GymnasticsApp());
}

class GymnasticsApp extends StatelessWidget {
  const GymnasticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            ChangeNotifierProvider(create: (_) => TeamProvider()),
            ChangeNotifierProvider(create: (_) => MemberProvider()),
            ChangeNotifierProvider(create: (_) => ExerciseLibraryProvider()),
            ChangeNotifierProvider(create: (_) => SkillLibraryProvider()),
            ChangeNotifierProvider(create: (_) => MemberLibraryProvider()),
            ChangeNotifierProvider(create: (_) => MemberNotesProvider()),
            ChangeNotifierProvider<ExerciseAssignmentProvider>(
              create: (_) => ExerciseAssignmentProvider(),
            ),
          ],
          child: Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return MaterialApp(
                title: 'ITQAN Gym',

                // Theme configuration
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: settings.themeMode,

                // Localization configuration
                locale: Locale(settings.languageCode),
                supportedLocales: const [
                  Locale('ar', 'SA'),
                  Locale('en', 'US'),
                ],

                // هنا الإضافة المهمة
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                builder: (context, child) {
                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: child!,
                  );
                },

                home: const DashboardScreen(),
              );
            },
          ),
        );
      },
    );
  }
}