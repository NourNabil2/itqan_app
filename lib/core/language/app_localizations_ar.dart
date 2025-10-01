import 'package:flutter/src/material/app.dart';

import 'app_localizations.dart';

class AppLocalizationsAr extends AppLocalizations {
  // ============= General =============
  @override
  String get appName => 'ITQAN Gym';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get search => 'بحث';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجح';

  @override
  String get warning => 'تحذير';

  @override
  String get ok => 'حسناً';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  // ============= Premium Section =============
  @override
  String get premiumTitle => 'احصل على النسخة المميزة';

  @override
  String get premiumSubtitle => 'استمتع بتجربة كاملة بدون حدود';

  @override
  String get premiumBadge => 'عرض خاص';

  @override
  String get subscribeNow => 'الاشتراك الآن';

  @override
  String get cancelAnytime => 'يمكنك الإلغاء في أي وقت';

  @override
  String get removeAds => 'إزالة جميع الإعلانات';

  @override
  String get cloudBackup => 'نسخ احتياطي سحابي';

  @override
  String get syncDevices => 'مزامنة بين الأجهزة';

  @override
  String get premiumSupport => 'دعم فني مميز 24/7';

  // ============= Settings Screen =============
  @override
  String get settings => 'الإعدادات';

  @override
  String get welcomeBack => 'مرحباً بك';

  @override
  String get premiumMember => 'عضو مميز';

  @override
  String get basicMember => 'عضو أساسي';

  // Account Section
  @override
  String get account => 'الحساب';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get deleteAccount => 'حذف الحساب';

  // About Section
  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الاستخدام';

  @override
  String get shareApp => 'مشاركة التطبيق';

  @override
  String get rateApp => 'تقييم التطبيق';

  @override
  String get appVersion => 'الإصدار';

// Appearance Section
  @override
  String get appearance => 'المظهر';

  @override
  String get selectTheme => 'اختر المظهر';

  @override
  String get selectLanguage => 'اختر اللغة';

// Backup Section
  @override
  String get backupNow => 'نسخ احتياطي الآن';

  @override
  String get backupNowDescription => 'حفظ البيانات على السحابة';

  @override
  String get restoreData => 'استعادة البيانات';

  @override
  String get restoreDataDescription => 'استرجاع آخر نسخة احتياطية';

  @override
  String get autoBackupTitle => 'النسخ التلقائي';

  @override
  String get autoBackupDescription => 'نسخ احتياطي يومي تلقائي';
  // ============= Teams Section =============
  @override
  String get teams => 'الفرق';

  @override
  String get addTeam => 'إضافة فريق';

  @override
  String get editTeam => 'تعديل فريق';

  @override
  String get deleteTeam => 'حذف فريق';

  @override
  String get teamName => 'اسم الفريق';

  @override
  String get teamMembers => 'أعضاء الفريق';

  @override
  String get noTeams => 'لا توجد فرق';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get actionCannotBeUndone => 'هذا الإجراء لا يمكن التراجع عنه';

  @override
  String deleteTeamConfirmation(String teamName) => 'هل أنت متأكد من حذف فريق "$teamName"؟';

  @override
  String get allRelatedDataWillBeDeleted => 'سيتم حذف جميع البيانات المرتبطة بالفريق';

  @override
  String get member => 'عضو';

  @override
  String get members => 'أعضاء';

  @override
  String get teamDeletedSuccessfully => 'تم حذف الفريق بنجاح';

  @override
  String get errorDeletingTeam => 'خطأ في حذف الفريق';

  // Appearance Section

  @override
  String get theme => 'السمة';

  @override
  String get language => 'اللغة';

  @override
  String get lightMode => 'الوضع النهاري';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get systemMode => 'وضع النظام';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  // Notifications Section
  @override
  String get notifications => 'الإشعارات';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get notificationsDescription => 'احصل على تنبيهات حول التحديثات والأنشطة';

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get emailNotifications => 'إشعارات البريد';

  // Backup Section
  @override
  String get backup => 'النسخ الاحتياطي';

  @override
  String get autoBackup => 'نسخ احتياطي تلقائي';

  @override
  String get backupDescription => 'احفظ بياناتك بشكل آمن';

  @override
  String get restore => 'استعادة';

  @override
  String get lastBackup => 'آخر نسخة احتياطية';

  @override
  String get neverBackedUp => 'لم يتم النسخ الاحتياطي';

  @override
  String get premiumFeature => 'ميزة مميزة';

  @override
  String get upgradeToAccess => 'قم بالترقية للوصول';

  // About Section
  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get helpCenter => 'مركز المساعدة';

  // Library Screen
  @override
  String get exercisesAndSkillsLibrary => 'مكتبة التمارين والمهارات';

  @override
  String get manageExercisesAndSkills => 'إدارة وتنظيم جميع التمارين والمهارات';

  @override
  String get statistics => 'إحصائيات';

  @override
  String searchIn(String category) => 'البحث في $category...';

  @override
  String get loadingContent => 'جاري تحميل المحتوى...';

  @override
  String addFirst(String category) => 'إضافة أول $category';

  @override
  String addNew(String category) => 'إضافة $category جديد';

  @override
  String get addNewSkill => 'إضافة مهارة جديدة';

  @override
  String get addFirstSkill => 'إضافة أول مهارة';

  @override
  String get skills => 'المهارات';

  // Dashboard
  String get dashboard => 'لوحة التحكم';

  String get exercises => 'التمارين';

  String get reports => 'التقارير';

  // Manage Assignments Screen
  @override
  String get assignContentToTeam => 'تعيين المحتوى للفريق';

  @override
  String assignContentDescription(String teamName) => 'اختر التمارين والمهارات المناسبة لـ $teamName';

  @override
  String get saving => 'جاري الحفظ...';

  @override
  String get searchInContent => 'البحث في المحتوى...';

  @override
  String get selectedItems => 'العناصر المختارة';

  @override
  String get noResultsFound => 'لا توجد نتائج';

  @override
  String get tryDifferentKeywords => 'جرب البحث بكلمات مختلفة';

  @override
  String get addExercise => 'إضافة تمرين';

  @override
  String get addSkill => 'إضافة مهارة';

  @override
  String get addNewFromLibrary => 'قم بإضافة عناصر جديدة من المكتبة';

  @override
  String get assignmentsSavedSuccessfully => 'تم حفظ التعيينات بنجاح';

  @override
  String get errorSavingAssignments => 'خطأ في حفظ التعيينات';

  @override
  String noExercisesInCategory(String category) => 'لا توجد تمارين $category';

  // Team Detail Screen

  @override
  String get content => 'المحتوى';

  @override
  String get loadingData => 'جاري تحميل البيانات...';

  @override
  String get noContentAssigned => 'لم يتم تعيين محتوى بعد';

  @override
  String get startAssigningContent => 'ابدأ بتعيين التمارين والمهارات لهذا الفريق';

  @override
  String get manageAssignments => 'إدارة التعيينات';

  @override
  String get assignedExercises => 'التمارين المُعيَّنة';

  @override
  String get assignedSkills => 'المهارات المُعيَّنة';

  @override
  String get comingSoonProgressTracking => 'قريباً: تتبع التقدم';

  @override
  String get featureComingSoon => 'سيتم إضافة هذه الوظيفة قريباً';

  @override
  String memberCount(int count) => '$count عضو';

  @override
  String exerciseCount(int count) => '$count تمرين';

  @override
  String skillCount(int count) => '$count مهارة';

  // Member Actions
  @override
  String get editGeneralNote => 'تعديل الملاحظة العامة';

  @override
  String get generalNoteHint => 'اكتب ملاحظة عامة عن العضو...';

  @override
  String get generalNoteUpdated => 'تم تحديث الملاحظة العامة';

  @override
  String get updateFailed => 'فشل في التحديث';

  @override
  String get addDetailedNote => 'إضافة ملاحظة مفصلة';

  @override
  String get viewAllNotes => 'عرض جميع الملاحظات';

  @override
  String get close => 'إغلاق';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get details => 'تفاصيل';

  @override
  String get type => 'النوع';

  @override
  String get priority => 'الأولوية';

  @override
  String get by => 'بواسطة';

  @override
  String get date => 'التاريخ';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String daysAgo(int days) => 'منذ $days أيام';

// Member Options
  @override
  String get shareProfile => 'مشاركة الملف';

  @override
  String get removeFromTeam => 'إزالة من الفريق';

  @override
  String get deleteMemberPermanently => 'حذف العضو نهائياً';

  @override
  String get removeFromTeamTitle => 'إزالة من الفريق';

  @override
  String removeFromTeamConfirmation(String memberName) =>
      'هل أنت متأكد من إزالة $memberName من الفريق؟ سيبقى العضو في المكتبة العامة.';

  @override
  String get memberWillStayInLibrary => 'سيبقى العضو في المكتبة العامة';

  @override
  String get remove => 'إزالة';

  @override
  String memberRemovedFromTeam(String memberName) => 'تم إزالة $memberName من الفريق';

  @override
  String get deleteMemberTitle => 'حذف العضو';

  @override
  String deleteMemberConfirmation(String memberName) =>
      'هل أنت متأكد من حذف $memberName نهائياً من المكتبة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء';

  @override
  String get deletePermanently => 'حذف نهائياً';

  @override
  String memberDeletedPermanently(String memberName) => 'تم حذف $memberName نهائياً';

  @override
  String get beginning => 'بداية';

  @override
  String get age => 'العمر';

  @override
  String get level => 'المستوى';

  // Member Notes Screen
  @override
  String memberNotes(String memberName) => 'ملاحظات $memberName';

  @override
  String get loadingNotes => 'جاري تحميل الملاحظات...';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get couldNotLoadNotes => 'لم نتمكن من تحميل الملاحظات، يرجى المحاولة مرة أخرى';

  @override
  String get retryAgain => 'إعادة المحاولة';

  @override
  String get totalNotes => 'إجمالي الملاحظات';

  @override
  String get highPriority => 'عالية الأولوية';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String allNotesCount(int count) => 'الكل ($count)';

  @override
  String generalNotesCount(int count) => 'عام ($count)';

  @override
  String performanceNotesCount(int count) => 'الأداء ($count)';

  @override
  String behaviorNotesCount(int count) => 'السلوك ($count)';

  @override
  String healthNotesCount(int count) => 'الصحة ($count)';

  @override
  String get noNotes => 'لا توجد ملاحظات';

  @override
  String get noNotesOfThisType => 'لم يتم إضافة أي ملاحظات من هذا النوع بعد';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get addNewNote => 'إضافة ملاحظة جديدة';

  @override
  String get noteTitle => 'عنوان الملاحظة';

  @override
  String get title => 'العنوان';

  @override
  String get enterNoteTitle => 'الرجاء إدخال عنوان الملاحظة';

  @override
  String get noteContent => 'المحتوى';

  @override
  String get writeNoteHere => 'اكتب الملاحظة هنا...';

  @override
  String get enterNoteContent => 'الرجاء إدخال محتوى الملاحظة';

  @override
  String get update => 'تحديث';

  @override
  String get noteDetails => 'تفاصيل الملاحظة';

  @override
  String get trainer => 'المدرب';

  @override
  String get deleteNote => 'حذف الملاحظة';

  @override
  String get deleteNoteConfirmation => 'هل أنت متأكد من حذف هذه الملاحظة؟';

  @override
  String get noteUpdatedSuccessfully => 'تم تحديث الملاحظة بنجاح';

  @override
  String get noteAddedSuccessfully => 'تم إضافة الملاحظة بنجاح';

  @override
  String get errorUpdatingNote => 'حدث خطأ في تحديث الملاحظة';

  @override
  String get errorAddingNote => 'حدث خطأ في إضافة الملاحظة';

  @override
  String get noteDeletedSuccessfully => 'تم حذف الملاحظة بنجاح';

  @override
  String get errorDeletingNote => 'حدث خطأ في حذف الملاحظة';

  @override
  String get currentTrainer => 'المدرب الحالي';
  // Note Card
  @override
  String get important => 'مهم';

  // Exercise Detail Sheet
  @override
  String assignedMembers(int count) => 'الأعضاء المعينون ($count)';

  @override
  String get noMembersAssigned => 'لم يتم تعيين أي عضو لهذا التمرين';

  @override
  String get noMembersAssignedDescription => 'قم بتعيين أعضاء لهذا التمرين';

  @override
  String get assignMembers => 'تعيين أعضاء';

  @override
  String get educationalMedia => 'الوسائط التعليمية';

  @override
  String get thumbnail => 'الصورة المصغرة';

  @override
  String get cannotDisplayImage => 'لا يمكن عرض الصورة';

  @override
  String mediaGallery(int count) => 'معرض الوسائط ($count)';

  @override
  String get exerciseDescription => 'وصف التمرين';

  @override
  String get exerciseInfo => 'معلومات التمرين';

  @override
  String get dateAdded => 'تاريخ الإضافة';

  @override
  String get lastUpdate => 'آخر تحديث';

  @override
  String get usageStatistics => 'إحصائيات الاستخدام';

  @override
  String get assignedTeams => 'الفرق المعينة';

  @override
  String get addition => 'الإضافة';

  @override
  String get assignToMembers => 'تعيين للأعضاء';
// Age Category
  @override
  String get ageCategoryTitle => 'الفئة العمرية';
  // Select Content Step
  @override
  String get selectContent => 'اختيار المحتوى';

  @override
  String get selectContentDescription => 'اختر التمارين والمهارات من المكتبة العالمية';

  @override
  String noExercisesAvailable(String type) => 'لا توجد تمارين $type';

  @override
  String get noSkillsAvailable => 'لا توجد مهارات';

  @override
  String get addFromLibraryFirst => 'أضف من المكتبة أولاً';

  // Skills Progress
  @override
  String get progress => 'التقدم';

  @override
  String get completed => 'مكتمل';

  @override
  String get inProgress => 'قيد التقدم';

  @override
  String get notStarted => 'لم يبدأ';

  @override
  String get mastered => 'متقن';

  @override
  String viewAllSkills(int count) => 'عرض كل المهارات ($count)';

  // Account Section
  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginDescription => 'قم بتسجيل الدخول للوصول لجميع المميزات';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileDescription => 'عرض وتعديل معلوماتك';

  @override
  String get logoutTitle => 'تسجيل الخروج';

  @override
  String get logoutDescription => 'الخروج من حسابك';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل تريد تسجيل الخروج من حسابك؟';

  // Dashboard
  @override
  String get addMemberToLibrary => 'إضافة عضو';


  @override
  String get noTeamsYet => 'لا توجد فرق بعد';

  @override
  String get noTeamsSubtitle => 'ابدأ بإنشاء أول فريق لك لتنظيم الأعضاء والتمارين.';

  @override
  String get createTeam => 'إنشاء فريق';

  @override
  String get manageTeamsTrackSkills => 'إدارة الفرق وتتبع المهارات';

// Age Categories
  @override
  String ageCategory(String code) {
    switch (code.toUpperCase()) {
      case 'U6':
        return under6;
      case 'U7':
        return under7;
      case 'U8':
        return under8;
      case 'U9':
        return under9;
      case 'U10':
        return under10;
      case 'U11':
        return under11;
      case 'U12':
        return under12;
      case 'U13':
        return under13;
      case 'U14':
        return under14;
      default:
        return code;
    }
  }

  @override
  String get under6 => 'تحت 6 سنوات';

  @override
  String get under7 => 'تحت 7 سنوات';

  @override
  String get under8 => 'تحت 8 سنوات';

  @override
  String get under9 => 'تحت 9 سنوات';

  @override
  String get under10 => 'تحت 10 سنوات';

  @override
  String get under11 => 'تحت 11 سنوات';

  @override
  String get under12 => 'تحت 12 سنوات';

  @override
  String get under13 => 'تحت 13 سنوات';

  @override
  String get under14 => 'تحت 14 سنوات';

// Exercise Types
  @override
  String get warmup => 'الإحماء';

  @override
  String get stretching => 'الإطالة';

  @override
  String get conditioning => 'اللياقة البدنية';


// Note Types
  @override
  String get general => 'عام';

  @override
  String get performance => 'الأداء';

  @override
  String get behavior => 'السلوك';

  @override
  String get health => 'الصحة';

// Note Priority
  @override
  String get lowPriority => 'منخفضة';

  @override
  String get normalPriority => 'عادية';

  // Member Library Screen
  @override
  String get searchForMember => 'البحث عن عضو...';

  @override
  String get totalMembers => 'إجمالي الأعضاء';

  @override
  String activeMembers(int count) => '$count عضو نشط';

  @override
  String get loadingMembers => 'جاري تحميل الأعضاء...';

  @override
  String get noMembersInLibrary => 'لا توجد أعضاء في المكتبة';

  @override
  String get startAddingFirstMember => 'ابدأ بإضافة أول عضو لبناء قاعدة بياناتك';

  @override
  String get addFirstMember => 'إضافة أول عضو';

// Member Card
  @override
  String get activity => 'النشاط';

  @override
  String yearsOld(int age) => '$age سنة';

  @override
  String skillsCount(int count) => '$count مهارة';

  @override
  String get new_ => 'جديد';

  @override
  String daysCount(int days) => '$days أيام';

  @override
  String weeksCount(int weeks) => '$weeks أسابيع';

  @override
  String get moreThan30Days => '+30 يوم';

// Apparatus
  @override
  String get floor => 'الحركات الأرضية';

  @override
  String get pommelHorse => 'حصان الحلق';

  @override
  String get stillRings => 'الحلق';

  @override
  String get vault => 'طاولة القفز';

  @override
  String get parallelBars => 'المتوازي';

  @override
  String get horizontalBar => 'العقلة';

  @override
  String get unevenBars => 'المتوازي المختلف';

  @override
  String get beam => 'عارضة التوازن';

  // Validation Messages
  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get invalidEmail => 'البريد الإلكتروني غير صحيح';

  @override
  String get invalidPhone => 'رقم الهاتف غير صحيح';

  @override
  String getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'حسب النظام';
    }
  }

  @override
  String fieldMinLength(int length) => 'يجب أن يكون $length أحرف على الأقل';

  @override
  String fieldMaxLength(int length) => 'يجب أن لا يتجاوز $length حرف';

  // Success Messages
  @override
  String get savedSuccessfully => 'تم الحفظ بنجاح';

  @override
  String get deletedSuccessfully => 'تم الحذف بنجاح';

  @override
  String get updatedSuccessfully => 'تم التحديث بنجاح';

  @override
  String get addedSuccessfully => 'تم الإضافة بنجاح';

  // Error Messages
  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get serverError => 'خطأ في الخادم';

  @override
  String get notFound => 'غير موجود';

}