// ============= 1. Enhanced Member Card Model =============
class MemberCardData {
  final int skillsCount;
  final double skillsProgress;
  final int attendanceDays;
  final double attendanceRate;
  final DateTime? lastActivity;
  final int completedExercises;

  const MemberCardData({
    this.skillsCount = 0,
    this.skillsProgress = 0,
    this.attendanceDays = 0,
    this.attendanceRate = 0,
    this.lastActivity,
    this.completedExercises = 0,
  });
}