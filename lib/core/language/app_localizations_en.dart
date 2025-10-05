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

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Invalid email address';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get password => 'Password';


  @override
  String get passwordTooShort => 'Password is too short (minimum 6 characters)';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get dontHaveAccount => 'Don’t have an account?';

  @override
  String get signUpTitle => 'Create Account';

  @override
  String get timeManipulationDetected => 'Device time manipulation detected';

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

  @override
  String get performanceChart => 'Performance Chart';

  @override
  String get trackProgressOverTime => 'Track progress over time';

  @override
  String get last6Weeks => 'Last 6 weeks';

  @override
  String get skillsProgress => 'Skills Progress';

  @override
  String get addedSkillsCompletion => 'Added skills and completion rate';

  @override
  String get performanceStatistics => 'Performance Statistics';

  @override
  String get overallPerformanceView => 'Overall performance overview';

  @override
  String get detailedNotes => 'Detailed Notes';

  @override
  String get advancedNotesWithDates => 'Record advanced notes with dates and categories';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String get availableForPremium => 'Available for premium members only';

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
  String get signUpDescription => 'Create an account to get started';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Confirm password is required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get mustAgreeToTerms => 'You must agree to the terms and conditions';

  @override
  String get iAgreeToThe => 'I agree to the ';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get verificationEmailSent => 'A verification email has been sent to your inbox';

  @override
  String get resendEmail => 'Resend';

  @override
  String get gotIt => 'Got it';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get lifetimePlan => 'Lifetime Plan';

  @override
  String get perMonth => 'Per month';

  @override
  String get oneTime => 'One-time';

  @override
  String get bestValue => 'Best Value';

  @override
  String get whatsIncluded => 'What’s included:';

  @override
  String get continueToPayment => 'Continue to Payment';

  @override
  String get maybeLater => 'Maybe later';

  // Backup & Restore
  @override
  String get createBackup => 'Create Backup';

  @override
  String get createBackupConfirmation => 'Do you want to create a backup of your data now? It will be uploaded to the cloud.';

  @override
  String get backupSuccess => 'Backup created successfully';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get restoreWarning => 'Warning: All current data will be replaced with the backup. This action cannot be undone. Do you want to continue?';

  @override
  String get restoreSuccess => 'Data restored successfully';

  @override
  String get restartAppMessage => 'The app must be restarted to apply changes. The app will close now.';

  @override
  String get closeApp => 'Close App';

  @override
  String get noBackupsFound => 'No backups available';

  @override
  String get backupHistory => 'Backup History';

  @override
  String get viewBackupHistory => 'View all saved backups';

  @override
  String get backupsAvailable => 'backups available';

  @override
  String get lastBackup => 'Last backup';

  @override
  String get errorLoadingBackups => 'Error loading backups';

  @override
  String get restore => 'Restore';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String get deleteBackup => 'Delete Backup';

  @override
  String get deleteBackupConfirmation => 'Do you want to delete this backup? This action cannot be undone.';

  @override
  String get backupDeleted => 'Backup deleted';
  @override
  String get payment => 'Payment';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get egp => 'EGP';

  @override
  String get paymentInstructions => 'Payment Instructions';

  @override
  String get paymentInstructionsDetails =>
      'To complete your subscription, please contact us via email or WhatsApp to receive the transfer details and confirmation instructions.';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get vodafoneCash => 'Vodafone Cash';

  @override
  String get instaPay => 'InstaPay';

  @override
  String get transactionReference => 'Transaction Reference';

  @override
  String get transactionReferenceOptional => 'Transaction Reference (Optional)';

  @override
  String get uploadPaymentProof => 'Upload Payment Proof';

  @override
  String get tapToUploadProof => 'Tap to upload payment proof image';

  @override
  String get submitPaymentRequest => 'Submit Payment Request';

  @override
  String get paymentRequestSubmitted => 'Payment request submitted successfully';

  @override
  String get paymentUnderReview => 'Your request is under review, your subscription will be activated once approved.';

  @override
  String get paymentStatus => 'Subscribe Status';

  @override
  String get noPaymentRequests => 'No payment requests';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get viewPaymentRequests => 'View Subscribes requests status';

  @override
  String get backupDate => 'Backup date';

  @override
  String get size => 'Size';

  @override
  String get close => 'Close';


  @override
  String get submittedAt => 'Submitted At';

  @override
  String get reviewedAt => 'Reviewed At';

  @override
  String get adminNotes => 'Admin Notes';

  @override
  String get email => 'Email';

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
  String get neverBackedUp => 'Never Backed Up';

  @override
  String get upgradeToAccess => 'Upgrade to Access';

  @override
  String get generalCoachNote => 'Coach\'s general note';

  @override
  String get noGeneralNoteDescription =>
      'No general note.\nYou can add a general note about the member here.';

  @override
  String get viewMore => 'View more';

  @override
  String get noDetailedNotes => 'No detailed notes';

  @override
  String get addFirstNote => 'Add the first detailed note for the member';

  @override
  String get completed => 'Completed';

  @override
  String get updateProgress => 'Update progress';

  @override
  String get removeSkill => 'Remove skill';

  @override
  String get progressUpdated => 'Progress updated to';

  @override
  String get noteSaved => 'Note saved';

  @override
  String get skillRemoved => 'Skill removed';

  @override
  String get confirmRemoval => 'Confirm removal';

  @override
  String get confirmRemoveSkill => 'Are you sure you want to remove the skill?';

  @override
  String get enterNoteHere => 'Enter the note here...';


  @override
  String get newMemberDataAfterWeek =>
      'New member — data will be displayed after one week of training';

  @override
  String get insufficientDataAssignSkills =>
      'Insufficient data — start assigning skills to the member';

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

  @override
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
  String editExerciseType(String type) => 'Edit $type';

  @override
  String addExerciseType(String type) => 'Add $type';

  @override
  String get editExercise => 'Edit Exercise';

  @override
  String get addNewExercise => 'Add New Exercise';

  @override
  String get enterExerciseDetails => 'Enter exercise details and media';

  @override
  String get exerciseTitleHint => 'Example: Jump Rope Exercise';

  @override
  String get exerciseTitle => 'Exercise Title';

  @override
  String get exerciseDescriptionHint => 'Describe how to perform the exercise...';

  @override
  String get instructionalMedia => 'Instructional Media';

  @override
  String get changesWillBeSaved => 'Changes will be saved to the library';

  @override
  String exerciseWillBeAddedToLibrary(String type) =>
      'The exercise will be added to the $type library';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get exerciseTitleRequired => 'Exercise title is required';

  @override
  String get titleMinLength => 'The title must contain at least 3 characters';

  @override
  String get exerciseTitleExists => 'Another exercise with the same title already exists';

  @override
  String get exerciseUpdatedSuccessfully => 'Exercise updated successfully';

  @override
  String get exerciseAddedSuccessfully => 'Exercise added successfully';

  @override
  String get deleteExercise => 'Delete Exercise';

  @override
  String deleteExerciseConfirmation(String title) =>
      'Are you sure you want to permanently delete "$title"?\n\nThis action cannot be undone.';

  @override
  String get exerciseDeletedPermanently => 'Exercise permanently deleted';

  @override
  String noItemsIn(String category) => 'No items in $category';

  @override
  String get startAddingItems => 'Start adding items to display here';

  @override
  String get addNow => 'Add Now';

  @override
  String get libraryStatistics => 'Library Statistics';
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
  String get editSkill => 'Edit Skill';

  @override
  String get addNewSkill => 'Add New Skill';

  @override
  String get enterSkillDetails => 'Enter skill details and instructional media';

  @override
  String get skillNameHint => 'Example: Extended Back Handspring';

  @override
  String get skillName => 'Skill Name';

  @override
  String get apparatus => 'Apparatus';

  @override
  String get technicalAnalysis => 'Technical Analysis';

  @override
  String get preRequisites => 'Prerequisites';

  @override
  String get skillProgression => 'Skill Progression';

  @override
  String get skillDrills => 'Skill Drills';

  @override
  String get physicalPreparation => 'Physical Preparation';

  @override
  String enter(String field) => 'Enter $field...';

  @override
  String skillWillBeAddedToLibrary(String apparatus) =>
      'The skill will be added to the $apparatus library';

  @override
  String get addSkill => 'Add Skill';

  @override
  String get skillNameRequired => 'Skill name is required';

  @override
  String get nameMinLength => 'The name must contain at least 3 characters';

  @override
  String get skillNameExists => 'Another skill with the same name already exists';

  @override
  String get skillUpdatedSuccessfully => 'Skill updated successfully';

  @override
  String get skillAddedSuccessfully => 'Skill added successfully';

  @override
  String get deleteSkill => 'Delete Skill';

  @override
  String deleteSkillConfirmation(String name) =>
      'Are you sure you want to permanently delete "$name"?\n\nThis action cannot be undone.';

  @override
  String get skillDeletedPermanently => 'Skill permanently deleted';

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
  String get playbackSpeed => 'Playback Speed';

  @override
  String get normal => 'Normal';

  @override
  String get video => 'Video';

  @override
  String get loadingVideo => 'Loading video...';

  @override
  String get cannotPlayVideo => 'Cannot play video';

  @override
  String get retry => 'Retry';

  @override
  String addFirst(String category) => 'Add first $category';

  @override
  String addNew(String category) => 'Add new $category';

  @override
  String get assigned => 'Assigned';

  @override
  String get image => 'Image';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get tapToZoom => 'Tap to Zoom';

  @override
  String get selectVideoSource => 'Select Video Source';

  @override
  String get selectVideo => 'Select Video';

  @override
  String get recordVideo => 'Record Video';

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

  @override
  String week(int number) => 'W$number';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get noDataToDisplay => 'No data to display';

  @override
  String get excellentPerformance => 'Excellent performance! Keep going';

  @override
  String get goodProgress => 'Good progress, keep it up';

  @override
  String get goodStart => 'Good start, continue!';

  @override
  String get startTrainingJourney => 'Start your training journey now';

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get editMemberData => 'Edit Member Data';

  @override
  String get additionalInfo => 'Additional Information';

  @override
  String get registrationDate => 'Registration Date';

  @override
  String get editMemberNotice =>
      'Editing this data will affect all exercises and assessments linked to this member. Make sure the data is correct before saving.';

  @override
  String get errorPickingImage => 'Error picking image';

  @override
  String get memberDataUpdatedSuccessfully => 'Member data updated successfully';

  @override
  String get errorUpdatingMemberData => 'Error updating member data';

  @override
  String get editMember => 'Edit Member';

  @override
  String get memberNotesHint => 'Any notes or additional information about the member...';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get editMemberLibraryNotice =>
      'Changes will be saved to this member in the general library';

  @override
  String get addMemberLibraryNotice =>
      'This member will be added to the general library and can be added to any team later';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get addMember => 'Add Member';

  @override
  String get memberUpdatedSuccessfully => 'Member updated successfully';

  @override
  String get memberAddedSuccessfully => 'Member added successfully';

  @override
  String get errorSavingMember => 'Error saving member data';

  @override
  String get deleteMember => 'Delete Member';

  @override
  String get errorDeletingMember => 'Error deleting member';

  @override String get contactOnWhatsApp => 'Subscribe via WhatsApp';
  @override String get contactByEmail => 'Subscribe via Email';
  @override String get pricePerMonth => 'Monthly subscription price';

  @override String get step1 => '1) Transfer the amount via InstaPay.';
  @override String get step2 => '2) After the transfer, contact us via WhatsApp or email to send the confirmation details.';
  @override String get step3 => '3) Your subscription will be activated within 24 hours after verification.';

  @override String get whatsappPrefilledMessage =>
      'Hi, I would like to subscribe to the premium version. I have made the transfer and will send the confirmation details.';
  @override String get emailSubject => 'Premium Subscription Request';
  @override String get emailBody =>
      'Hi, I would like to subscribe to the premium version. I will attach the transfer details in this email.';
  @override String get payOutsideNote => 'Note: The payment and verification process takes place outside the app.';

  @override String get subscriptionInstructions => 'Subscription Instructions';
  @override String get premiumSubscription => 'Premium Subscription';
  @override String get selectedPlan => 'Selected Plan';
  @override String get howToSubscribe => 'How to Subscribe';
  @override String get contactUsForDetails => 'Contact us to get payment details';
  @override String get makePaymentExternally => 'Make payment via agreed method';
  @override String get sendPaymentConfirmation => 'Send payment confirmation via WhatsApp or Email';
  @override String get activationWithin24Hours => 'Your subscription will be activated within 24 hours';
  @override String get contactInformation => 'Contact Information';
  @override String get contactViaWhatsApp => 'Contact via WhatsApp';
  @override String get submitViaEmail => 'Submit Request via Email';
  @override String get paymentProcessedExternally => 'Note: Payment and confirmation are processed outside the app. We will contact you to complete the process.';
  @override String get whatsappMessage => 'Hello, I want to subscribe to the premium version';
  @override String get plan => 'Plan';
  @override String get awaitingPaymentDetails => 'Awaiting payment details';
  @override String get cannotOpenWhatsApp => 'Cannot open WhatsApp';
  @override String get errorOpeningWhatsApp => 'Error opening WhatsApp';
  @override String get mustBeLoggedIn => 'You must be logged in first';
  @override String get errorSubmittingRequest => 'Error submitting request';
  @override String get subscriptionRequestSubject => 'Premium Subscription Request';
  @override String get emailBodyIntro => 'Hello, I want to subscribe to the premium version with the following details:';
  @override String get emailBodyInstructions => 'I will send payment proof in this email after completing the transaction.';
  @override String get requestSubmitted => 'Request Submitted';
  @override String get requestSubmittedMessage => 'Your request has been submitted successfully. We will contact you soon to complete the subscription process.';
  @override String get understood => 'Understood';
  @override String get viewSubscriptionInstructions => 'View Subscription Instructions';

  @override String get support => 'Support';
  @override String get contactSupportForHelp => 'Contact us for help or account deletion';
  @override String get supportRequestSubject => 'Support Request - Itqan Gym';
  @override String get supportRequestBody => '''Hello Support Team,

I need help with:
[ Write your request here ]

If you want to delete your account, please write "I want to delete my account" in the message.

Thank you.''';
}