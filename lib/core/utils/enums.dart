enum AgeCategory {
  u6('U6', 'تحت 6 سنوات'),
  u7('U7', 'تحت 7 سنوات'),
  u8('U8', 'تحت 8 سنوات'),
  u9('U9', 'تحت 9 سنوات'),
  u10('U10', 'تحت 10 سنوات'),
  u11('U10', 'تحت 11 سنوات'),
  u12('U12', 'تحت 12 سنوات'),
  u13('U13', 'تحت 13 سنوات'),
  u14('U14', 'تحت 14 سنوات');


  final String code;
  final String arabicName;

  const AgeCategory(this.code, this.arabicName);
}
AgeCategory? ageFromCodeSafe(String code) {
  for (final a in AgeCategory.values) {
    if (a.code.toLowerCase() == code.toLowerCase()) {
      return a;
    }
  }
  return null;
}
enum ExerciseType {
  warmup('warmup', 'الإحماء'),
  stretching('stretching', 'الإطالة'),
  conditioning('conditioning', 'اللياقة البدنية');

  final String value;
  final String arabicName;

  const ExerciseType(this.value, this.arabicName);
}

enum Apparatus {
  floor('floor', 'الحركات الأرضية'),
  beam('beam', 'عارضة التوازن'),
  bars('bars', 'العقلة'),
  vault('vault', 'طاولة القفز');

  final String value;
  final String arabicName;

  const Apparatus(this.value, this.arabicName);
}

enum MediaType {
  image('image'),
  video('video');

  final String value;

  const MediaType(this.value);
}

enum ProgressStatus {
  notStarted('NotStarted', 'لم يبدأ'),
  inProgress('InProgress', 'قيد التنفيذ'),
  mastered('Mastered', 'متقن');

  final String value;
  final String arabicName;

  const ProgressStatus(this.value, this.arabicName);
}