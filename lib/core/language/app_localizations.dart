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

  // ============= Auth Section =============
  String get emailRequired;
  String get emailInvalid;
  String get passwordRequired;
  String get password;
  String get email;
  String get passwordTooShort;
  String get forgotPassword;
  String get dontHaveAccount;
  String get signUpTitle;
  String get timeManipulationDetected;
  String get signUpDescription;
  String get confirmPassword;
  String get confirmPasswordRequired;
  String get passwordsDoNotMatch;
  String get mustAgreeToTerms;
  String get iAgreeToThe;
  String get termsAndConditions;
  String get verifyEmail;
  String get verificationEmailSent;
  String get resendEmail;
  String get gotIt;
  String get alreadyHaveAccount;
  String get upgradeToPremium;
  String get monthlyPlan;
  String get lifetimePlan;
  String get perMonth;
  String get oneTime;
  String get bestValue;
  String get whatsIncluded;
  String get continueToPayment;
  String get maybeLater;

  // ============= Teams Section =============
  String get teams;
  String get addTeam;
  String get editTeam;
  String get deleteTeam;
  String get teamName;
  String get teamMembers;
  String get noTeams;
  String get confirmDelete;
  String get actionCannotBeUndone;
  String deleteTeamConfirmation(String teamName);
  String get allRelatedDataWillBeDeleted;
  String get member;
  String get members;
  String get teamDeletedSuccessfully;
  String get errorDeletingTeam;

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
  String get createBackup;
  String get createBackupConfirmation;
  String get backupSuccess;
  String get backupFailed;
  String get restoreWarning;
  String get restoreSuccess;
  String get restartAppMessage;
  String get closeApp;
  String get noBackupsFound;
  String get backupHistory;
  String get viewBackupHistory;
  String get backupsAvailable;
  String get errorLoadingBackups;
  String get restoreFailed;
  String get deleteBackup;
  String get deleteBackupConfirmation;
  String get backupDeleted;

  // payment
  String get payment;
  String get viewPaymentRequests;
  String get paymentMethod;
  String get backupDate;
  String get size;
  String get close;
  String get totalAmount;
  String get egp;
  String get paymentInstructions;
  String get paymentInstructionsDetails;
  String get phoneNumber;
  String get copiedToClipboard;
  String get vodafoneCash;
  String get instaPay;
  String get transactionReference;
  String get transactionReferenceOptional;
  String get uploadPaymentProof;
  String get tapToUploadProof;
  String get submitPaymentRequest;
  String get paymentRequestSubmitted;
  String get paymentUnderReview;
  String get paymentStatus;
  String get noPaymentRequests;
  String get pending;
  String get approved;
  String get rejected;
  String get submittedAt;
  String get reviewedAt;
  String get adminNotes;
  // About Section
  String get about;
  String get version;
  String get privacyPolicy;
  String get termsOfService;
  String get contactUs;
  String get rateApp;
  String get shareApp;
  String get helpCenter;

  // ============= Account Section =============
  String get loginTitle;
  String get loginDescription;
  String get profileTitle;
  String get profileDescription;
  String get logoutTitle;
  String get logoutDescription;
  String get logoutConfirmTitle;
  String get logoutConfirmMessage;

  // ============= Appearance Section =============
  String get selectTheme;
  String get selectLanguage;
  String getThemeName(ThemeMode mode);

  // ============= Backup Section =============
  String get backupNowDescription;
  String get restoreData;
  String get restoreDataDescription;
  String get autoBackupTitle;
  String get autoBackupDescription;

  // ============= Manage Assignments Screen =============
  String get assignContentToTeam;
  String assignContentDescription(String teamName);
  String get saving;
  String get searchInContent;
  String get selectedItems;
  String get noResultsFound;
  String get tryDifferentKeywords;
  String get addExercise;
  String get addSkill;
  String get addNewFromLibrary;
  String get assignmentsSavedSuccessfully;
  String get errorSavingAssignments;
  String noExercisesInCategory(String category);
  // ============= Library Screen =============
  String get exercisesAndSkillsLibrary;
  String get manageExercisesAndSkills;
  String get statistics;
  String searchIn(String category);
  String get loadingContent;
  String addFirst(String category);
  String addNew(String category);
  String get addNewSkill;
  String get addFirstSkill;
  String get skills;

  // ============= Team Detail Screen =============
  String get content;
  String get loadingData;
  String get noContentAssigned;
  String get startAssigningContent;
  String get manageAssignments;
  String get assignedExercises;
  String get assignedSkills;
  String get comingSoonProgressTracking;
  String get featureComingSoon;
  String memberCount(int count);
  String exerciseCount(int count);
  String skillCount(int count);

// إضافة في abstract class AppLocalizations

  // ============= Member Notes Screen =============
  String memberNotes(String memberName);
  String get generalCoachNote;
  String get noGeneralNoteDescription;
  String get viewMore;
  String get noDetailedNotes;
  String get addFirstNote;
  String get completed;
  String get inProgress;
  String get notStarted;
  String get updateProgress;
  String get addNote;
  String get removeSkill;
  String get progress;
  String get progressUpdated;
  String get noteSaved;
  String get skillRemoved;
  String get confirmRemoval;
  String get confirmRemoveSkill;
  String get enterNoteHere;
  String get loadingNotes;
  String get errorOccurred;
  String get couldNotLoadNotes;
  String get retryAgain;
  String get totalNotes;
  String get highPriority;
  String get thisWeek;
  String allNotesCount(int count);
  String generalNotesCount(int count);
  String performanceNotesCount(int count);
  String behaviorNotesCount(int count);
  String healthNotesCount(int count);
  String get noNotes;
  String get noNotesOfThisType;
  String get editNote;
  String get addNewNote;
  String get noteTitle;
  String get title;
  String get enterNoteTitle;
  String get noteContent;
  String get writeNoteHere;
  String get enterNoteContent;
  String get update;
  String get noteDetails;
  String get trainer;
  String get deleteNote;
  String get deleteNoteConfirmation;
  String get noteUpdatedSuccessfully;
  String get noteAddedSuccessfully;
  String get errorUpdatingNote;
  String get errorAddingNote;
  String get noteDeletedSuccessfully;
  String get errorDeletingNote;
  String get currentTrainer;

  // ============= Member Actions =============
  String get editGeneralNote;
  String get generalNoteHint;
  String get generalNoteUpdated;
  String get updateFailed;
  String get addDetailedNote;
  String get viewAllNotes;
  String get viewAll;
  String get details;
  String get type;
  String get priority;
  String get by;
  String get date;
  String get today;
  String get yesterday;
  String daysAgo(int days);

  // ============= Note Card =============
  String get important;

  // ============= Exercise Detail Sheet =============
  String assignedMembers(int count);
  String get noMembersAssigned;
  String get noMembersAssignedDescription;
  String get assignMembers;
  String get educationalMedia;
  String get thumbnail;
  String get cannotDisplayImage;
  String mediaGallery(int count);
  String get exerciseDescription;
  String get exerciseInfo;
  String get dateAdded;
  String get lastUpdate;
  String get usageStatistics;
  String get assignedTeams;
  String get addition;
  String get assignToMembers;

  // Member Options
  String get ageCategoryTitle;
  String get shareProfile;
  String get removeFromTeam;
  String get deleteMemberPermanently;
  String get removeFromTeamTitle;
  String removeFromTeamConfirmation(String memberName);
  String get memberWillStayInLibrary;
  String get remove;
  String memberRemovedFromTeam(String memberName);
  String get deleteMemberTitle;
  String deleteMemberConfirmation(String memberName);
  String get cannotBeUndone;
  String get deletePermanently;
  String memberDeletedPermanently(String memberName);

  // Progress Status
  String get beginning;
  String get performanceChart;
  String get trackProgressOverTime;
  String get last6Weeks;
  String get skillsProgress;
  String get addedSkillsCompletion;
  String get performanceStatistics;
  String get overallPerformanceView;
  String get detailedNotes;
  String get advancedNotesWithDates;
  String get upgradeNow;
  String get availableForPremium;
  String get newMemberDataAfterWeek;
  String get insufficientDataAssignSkills;

  // Member Info
  String get age;
  String get level;


  // ============= Select Content Step =============
  String get selectContent;
  String get selectContentDescription;
  String noExercisesAvailable(String type);
  String get noSkillsAvailable;
  String get addFromLibraryFirst;
  String get mastered;
  String week(int number);
  String get errorLoadingData;
  String get noDataToDisplay;
  String viewAllSkills(int count);

  // ============= Dashboard =============
  String get addMemberToLibrary;
  String get noTeamsYet;
  String get noTeamsSubtitle;
  String get createTeam;
  String get manageTeamsTrackSkills;

  // ============= Age Categories =============
  String ageCategory(String code);
  String get under6;
  String get under7;
  String get under8;
  String get under9;
  String get under10;
  String get under11;
  String get under12;
  String get under13;
  String get under14;

  // ============= Exercise Types =============
  String get warmup;
  String get stretching;
  String get conditioning;


  // ============= Note Types =============
  String get general;
  String get performance;
  String get behavior;
  String get health;

  // ============= Member Library Screen =============
  String get searchForMember;
  String get totalMembers;
  String activeMembers(int count);
  String get loadingMembers;
  String get noMembersInLibrary;
  String get startAddingFirstMember;
  String get addFirstMember;
  String get excellentPerformance;
  String get goodProgress;
  String get goodStart;
  String get startTrainingJourney;
  String get overallProgress;
  String get editMemberData;
  String get additionalInfo;
  String get registrationDate;
  String get editMemberNotice;
  String get errorPickingImage;
  String get memberDataUpdatedSuccessfully;
  String get errorUpdatingMemberData;

  // ============= Member Card =============
  String get activity;
  String yearsOld(int age);
  String skillsCount(int count);
  String get new_;
  String daysCount(int days);
  String weeksCount(int weeks);
  String get moreThan30Days;
  String get editMember;
  String get memberNotesHint;
  String get notesOptional;
  String get editMemberLibraryNotice;
  String get addMemberLibraryNotice;
  String get saveChanges;
  String get addMember;
  String get memberUpdatedSuccessfully;
  String get memberAddedSuccessfully;
  String get errorSavingMember;
  String get deleteMember;
  String get errorDeletingMember;

  // ============= Note Priority =============
  String get lowPriority;
  String get normalPriority;

  // ============= Apparatus =============
  String get floor;
  String get pommelHorse;
  String get stillRings;
  String get vault;
  String get parallelBars;
  String get horizontalBar;
  String get unevenBars;
  String get beam;

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