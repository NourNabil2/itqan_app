
class AppConstants {
static const String appName = 'Gymnastics Coach';
static const String dbName = 'gymnastics_app.db';
static const int dbVersion = 1;

// Age Groups
static const Map<String, String> ageGroups = {
'under_4': 'Under 4',
'under_5': 'Under 5',
'under_6': 'Under 6',
'under_7': 'Under 7',
'under_8': 'Under 8',
'under_9': 'Under 9',
'under_10': 'Under 10',
'under_11': 'Under 11',
'under_12': 'Under 12',
'under_13': 'Under 13',
'under_14': 'Under 14',
};

// Apparatus Types
static const List<String> apparatus = [
'Floor',
'Beam',
'Uneven Bars',
'Vault',
];

// Skill Levels
static const Map<String, int> skillLevels = {
'Not Started': 0,
'In Progress': 50,
'Mastered': 100,
};
}