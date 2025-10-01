import 'package:flutter/material.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('ar', 'SA'),
    Locale('en', 'US'),
  ];

  // ============= General =============
  String get appName;
  String get cancel;
  String get confirm;
  String get save;
  String get delete;
  String get edit;
  String get add;
  String get search;
  String get loading;
  String get error;
  String get success;
  String get warning;
  String get ok;
  String get yes;
  String get no;

  // ============= Premium Section =============
  String get premiumTitle;
  String get premiumSubtitle;
  String get premiumBadge;
  String get subscribeNow;
  String get cancelAnytime;

  String get removeAds;
  String get cloudBackup;
  String get syncDevices;
  String get premiumSupport;

  // ============= Settings Screen =============
  String get settings;
  String get welcomeBack;
  String get premiumMember;
  String get basicMember;

  // Account Section
  String get account;
  String get login;
  String get logout;
  String get register;
  String get profile;
  String get editProfile;
  String get changePassword;
  String get deleteAccount;

  // Appearance Section
  String get appearance;
  String get theme;
  String get language;
  String get lightMode;
  String get darkMode;
  String get systemMode;
  String get chooseLanguage;
  String get arabic;
  String get english;

  // Notifications Section
  String get notifications;
  String get enableNotifications;
  String get notificationsDescription;
  String get pushNotifications;
  String get emailNotifications;

  // Backup Section
  String get backup;
  String get autoBackup;
  String get backupDescription;
  String get backupNow;
  String get restore;
  String get lastBackup;
  String get neverBackedUp;
  String get premiumFeature;
  String get upgradeToAccess;

  // About Section
  String get about;
  String get version;
  String get privacyPolicy;
  String get termsOfService;
  String get contactUs;
  String get rateApp;
  String get shareApp;
  String get helpCenter;

  // Dashboard
  String get dashboard;
  String get teams;
  String get members;
  String get exercises;
  String get skills;
  String get statistics;
  String get reports;

  // Validation Messages
  String get requiredField;
  String get invalidEmail;
  String get invalidPhone;
  String fieldMinLength(int length);
  String fieldMaxLength(int length);

  // Success Messages
  String get savedSuccessfully;
  String get deletedSuccessfully;
  String get updatedSuccessfully;
  String get addedSuccessfully;

  // Error Messages
  String get somethingWentWrong;
  String get noInternetConnection;
  String get serverError;
  String get notFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'ar':
        return AppLocalizationsAr();
      case 'en':
        return AppLocalizationsEn();
      default:
        return AppLocalizationsAr();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}