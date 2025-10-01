import 'package:flutter/material.dart';

import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  // ============= General =============
  @override
  String get appName => 'ITQAN Gym';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  // ============= Premium Section =============
  @override
  String get premiumTitle => 'Get Premium Version';

  @override
  String get premiumSubtitle => 'Enjoy a complete experience without limits';

  @override
  String get premiumBadge => 'Special Offer';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get removeAds => 'Remove All Ads';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get syncDevices => 'Sync Across Devices';

  @override
  String get premiumSupport => 'Premium Support 24/7';

  // ============= Settings Screen =============
  @override
  String get settings => 'Settings';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get premiumMember => 'Premium Member';

  @override
  String get basicMember => 'Basic Member';

  // Account Section
  @override
  String get account => 'Account';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get deleteAccount => 'Delete Account';

  // Appearance Section
  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemMode => 'System Mode';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  // Notifications Section
  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get notificationsDescription => 'Get alerts about updates and activities';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  // About Section
  String get aboutApp => 'About App';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get shareApp => 'Share App';

  @override
  String get rateApp => 'Rate App';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectLanguage => 'Select Language';

  // About Section
  String get appVersion => 'Version';

  // Member Notes Screen
  @override
  String memberNotes(String memberName) => '$memberName Notes';

  @override
  String get loadingNotes => 'Loading notes...';

  @override
  String get errorOccurred => 'Error Occurred';

  @override
  String get couldNotLoadNotes => 'Could not load notes, please try again';

  @override
  String get retryAgain => 'Retry';

  @override
  String get totalNotes => 'Total Notes';

  @override
  String get highPriority => 'High Priority';

  @override
  String get thisWeek => 'This Week';

  @override
  String allNotesCount(int count) => 'All ($count)';

  @override
  String generalNotesCount(int count) => 'General ($count)';

  @override
  String performanceNotesCount(int count) => 'Performance ($count)';

  @override
  String behaviorNotesCount(int count) => 'Behavior ($count)';

  @override
  String healthNotesCount(int count) => 'Health ($count)';

  @override
  String get noNotes => 'No Notes';

  @override
  String get noNotesOfThisType => 'No notes of this type have been added yet';

  @override
  String get addNote => 'Add Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get addNewNote => 'Add New Note';

  @override
  String get noteTitle => 'Note Title';

  @override
  String get title => 'Title';

  @override
  String get enterNoteTitle => 'Please enter note title';

  @override
  String get noteContent => 'Content';

  @override
  String get writeNoteHere => 'Write note here...';

  @override
  String get enterNoteContent => 'Please enter note content';

  @override
  String get update => 'Update';

  @override
  String get noteDetails => 'Note Details';

  @override
  String get trainer => 'Trainer';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get deleteNoteConfirmation => 'Are you sure you want to delete this note?';

  @override
  String get noteUpdatedSuccessfully => 'Note updated successfully';

  @override
  String get noteAddedSuccessfully => 'Note added successfully';

  @override
  String get errorUpdatingNote => 'Error updating note';

  @override
  String get errorAddingNote => 'Error adding note';

  @override
  String get noteDeletedSuccessfully => 'Note deleted successfully';

  @override
  String get errorDeletingNote => 'Error deleting note';

  @override
  String get currentTrainer => 'Current Trainer';


// Appearance Section

  @override
  String getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

// Backup Section
  @override
  String get backupNow => 'Backup Now';

  @override
  String get backupNowDescription => 'Save data to cloud';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get restoreDataDescription => 'Retrieve last backup';

  @override
  String get autoBackupTitle => 'Auto Backup';

  @override
  String get autoBackupDescription => 'Daily automatic backup';

  // Dashboard
  @override
  String get addMemberToLibrary => 'Add Member';

  @override
  String get addTeam => 'Add Team';

  @override
  String get noTeamsYet => 'No Teams Yet';

  @override
  String get noTeamsSubtitle => 'Start by creating your first team to organize members and exercises.';

  @override
  String get createTeam => 'Create Team';

  @override
  String get manageTeamsTrackSkills => 'Manage teams & track skills';

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
  String get under6 => 'Under 6';

  @override
  String get under7 => 'Under 7';

  @override
  String get under8 => 'Under 8';

  @override
  String get under9 => 'Under 9';

  @override
  String get under10 => 'Under 10';

  @override
  String get under11 => 'Under 11';

  @override
  String get under12 => 'Under 12';

  @override
  String get under13 => 'Under 13';

  @override
  String get under14 => 'Under 14';

// Exercise Types
  @override
  String get warmup => 'Warmup';

  @override
  String get stretching => 'Stretching';

  @override
  String get conditioning => 'Conditioning';

// Progress Status
  @override
  String get notStarted => 'Not Started';

  @override
  String get inProgress => 'In Progress';

  @override
  String get mastered => 'Mastered';

// Note Types
  @override
  String get general => 'General';

  @override
  String get performance => 'Performance';

  @override
  String get behavior => 'Behavior';

  @override
  String get health => 'Health';

// Note Priority
  @override
  String get lowPriority => 'Low';

  @override
  String get normalPriority => 'Normal';

  // Member Library Screen
  @override
  String get searchForMember => 'Search for member...';

  @override
  String get totalMembers => 'Total Members';

  @override
  String activeMembers(int count) => '$count active ${count == 1 ? "member" : "members"}';

  @override
  String get loadingMembers => 'Loading members...';

  @override
  String get noMembersInLibrary => 'No members in library';

  @override
  String get startAddingFirstMember => 'Start by adding your first member to build your database';

  @override
  String get addFirstMember => 'Add First Member';

// Member Card
  @override
  String get skills => 'Skills';

  @override
  String get progress => 'Progress';

  @override
  String get activity => 'Activity';

  @override
  String yearsOld(int age) => '$age ${age == 1 ? "year" : "years"} old';

  @override
  String skillsCount(int count) => '$count ${count == 1 ? "skill" : "skills"}';

  @override
  String get new_ => 'New';

  @override
  String daysCount(int days) => '$days ${days == 1 ? "day" : "days"}';

  @override
  String weeksCount(int weeks) => '$weeks ${weeks == 1 ? "week" : "weeks"}';

  @override
  String get moreThan30Days => '30+ days';

// Apparatus
  @override
  String get floor => 'Floor';

  @override
  String get pommelHorse => 'Pommel Horse';

  @override
  String get stillRings => 'Still Rings';

  @override
  String get vault => 'Vault';

  @override
  String get parallelBars => 'Parallel Bars';

  @override
  String get horizontalBar => 'Horizontal Bar';

  @override
  String get unevenBars => 'Uneven Bars';

  @override
  String get beam => 'Beam';
// Account Section
  @override
  String get loginTitle => 'Login';

  @override
  String get loginDescription => 'Login to access all features';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDescription => 'View and edit your information';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutDescription => 'Sign out of your account';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Do you want to logout from your account?';

  // ============= Teams Section =============
  @override
  String get teams => 'Teams';

  @override
  String get editTeam => 'Edit Team';

  @override
  String get deleteTeam => 'Delete Team';

  @override
  String get teamName => 'Team Name';

  @override
  String get teamMembers => 'Team Members';

  @override
  String get noTeams => 'No teams found';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone';

  @override
  String deleteTeamConfirmation(String teamName) => 'Are you sure you want to delete team "$teamName"?';

  @override
  String get allRelatedDataWillBeDeleted => 'All related data will be deleted';

  @override
  String get member => 'Member';

  @override
  String get members => 'Members';

  @override
  String get teamDeletedSuccessfully => 'Team deleted successfully';

  @override
  String get errorDeletingTeam => 'Error deleting team';


  // Backup Section
  @override
  String get backup => 'Backup';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get backupDescription => 'Keep your data safe';

  @override
  String get restore => 'Restore';

  @override
  String get lastBackup => 'Last Backup';

  @override
  String get neverBackedUp => 'Never Backed Up';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get upgradeToAccess => 'Upgrade to Access';

  // About Section
  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get helpCenter => 'Help Center';

  // Dashboard
  String get dashboard => 'Dashboard';

  String get exercises => 'Exercises';

  String get statistics => 'Statistics';

  String get reports => 'Reports';

  // Select Content Step
  @override
  String get selectContent => 'Select Content';

  @override
  String get selectContentDescription => 'Choose exercises and skills from the library';

  @override
  String get selectedItems => 'Selected Items';

  @override
  String noExercisesAvailable(String type) => 'No $type exercises available';

  @override
  String get noSkillsAvailable => 'No skills available';

  @override
  String get addFromLibraryFirst => 'Add from library first';

  // Note Card
  @override
  String get important => 'Important';

  // Exercise Detail Sheet
  @override
  String assignedMembers(int count) => 'Assigned Members ($count)';

  @override
  String get noMembersAssigned => 'No members assigned to this exercise';

  @override
  String get noMembersAssignedDescription => 'Assign members to this exercise';

  @override
  String get assignMembers => 'Assign Members';

  @override
  String get educationalMedia => 'Educational Media';

  @override
  String get thumbnail => 'Thumbnail';

  @override
  String get cannotDisplayImage => 'Cannot display image';

  @override
  String mediaGallery(int count) => 'Media Gallery ($count)';

  @override
  String get exerciseDescription => 'Exercise Description';

  @override
  String get exerciseInfo => 'Exercise Info';

  @override
  String get dateAdded => 'Date Added';

  @override
  String get lastUpdate => 'Last Update';

  @override
  String get usageStatistics => 'Usage Statistics';

  @override
  String get assignedTeams => 'Assigned Teams';

  @override
  String get addition => 'Addition';

  @override
  String get assignToMembers => 'Assign to Members';

  // Team Detail Screen

  @override
  String get content => 'Content';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get noContentAssigned => 'No content assigned yet';

  @override
  String get startAssigningContent => 'Start assigning exercises and skills to this team';

  @override
  String get manageAssignments => 'Manage Assignments';

  @override
  String get assignedExercises => 'Assigned Exercises';

  @override
  String get assignedSkills => 'Assigned Skills';

  @override
  String get comingSoonProgressTracking => 'Coming Soon: Progress Tracking';

  @override
  String get featureComingSoon => 'This feature will be added soon';
  // Member Actions
  @override
  String get editGeneralNote => 'Edit General Note';

  @override
  String get generalNoteHint => 'Write a general note about the member...';

  @override
  String get generalNoteUpdated => 'General note updated';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get addDetailedNote => 'Add Detailed Note';

  @override
  String get viewAllNotes => 'View All Notes';

  @override
  String get close => 'Close';

  @override
  String get viewAll => 'View All';

  @override
  String get details => 'Details';

  @override
  String get type => 'Type';

  @override
  String get priority => 'Priority';

  @override
  String get by => 'By';

  @override
  String get date => 'Date';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) => '$days days ago';

// Member Options
  @override
  String get shareProfile => 'Share Profile';

  @override
  String get removeFromTeam => 'Remove from Team';

  @override
  String get deleteMemberPermanently => 'Delete Member Permanently';

  @override
  String get removeFromTeamTitle => 'Remove from Team';

  @override
  String removeFromTeamConfirmation(String memberName) =>
      'Are you sure you want to remove $memberName from the team? The member will stay in the library.';

  @override
  String get memberWillStayInLibrary => 'Member will stay in library';

  @override
  String get remove => 'Remove';

  @override
  String memberRemovedFromTeam(String memberName) => '$memberName removed from team';

  @override
  String get deleteMemberTitle => 'Delete Member';

  @override
  String deleteMemberConfirmation(String memberName) =>
      'Are you sure you want to permanently delete $memberName from the library? This action cannot be undone.';

  @override
  String get cannotBeUndone => 'This action cannot be undone';

  // Age Category
  @override
  String get ageCategoryTitle => 'Age Category';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String memberDeletedPermanently(String memberName) => '$memberName deleted permanently';

  @override
  String get beginning => 'Beginning';

  @override
  String get age => 'Age';

  @override
  String get level => 'Level';


  // Manage Assignments Screen
  @override
  String get assignContentToTeam => 'Assign Content to Team';

  @override
  String assignContentDescription(String teamName) => 'Choose suitable exercises and skills for $teamName';

  @override
  String get saving => 'Saving...';

  @override
  String get searchInContent => 'Search in content...';


  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentKeywords => 'Try different keywords';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get addSkill => 'Add Skill';

  @override
  String get addNewFromLibrary => 'Add new items from library';

  @override
  String get assignmentsSavedSuccessfully => 'Assignments saved successfully';

  @override
  String get errorSavingAssignments => 'Error saving assignments';

  @override
  String noExercisesInCategory(String category) => 'No $category exercises';

  // Manage Assignments Screen
  @override
  String memberCount(int count) => '$count ${count == 1 ? "member" : "members"}';

  @override
  String exerciseCount(int count) => '$count ${count == 1 ? "exercise" : "exercises"}';

  @override
  String skillCount(int count) => '$count ${count == 1 ? "skill" : "skills"}';


  // Skills Progress

  @override
  String get completed => 'Completed';

  @override
  String viewAllSkills(int count) => 'View All Skills ($count)';

  // Library Screen
  @override
  String get exercisesAndSkillsLibrary => 'Exercises & Skills Library';

  @override
  String get manageExercisesAndSkills => 'Manage and organize all exercises and skills';

  @override
  String searchIn(String category) => 'Search in $category...';

  @override
  String get loadingContent => 'Loading content...';

  @override
  String addFirst(String category) => 'Add first $category';

  @override
  String addNew(String category) => 'Add new $category';

  @override
  String get addNewSkill => 'Add new skill';

  @override
  String get addFirstSkill => 'Add first skill';

  // Validation Messages
  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String fieldMinLength(int length) => 'Must be at least $length characters';

  @override
  String fieldMaxLength(int length) => 'Must not exceed $length characters';

  // Success Messages
  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get deletedSuccessfully => 'Deleted successfully';

  @override
  String get updatedSuccessfully => 'Updated successfully';

  @override
  String get addedSuccessfully => 'Added successfully';

  // Error Messages
  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get serverError => 'Server error';

  @override
  String get notFound => 'Not found';
}