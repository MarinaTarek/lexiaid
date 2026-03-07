import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const _pointsKey = "points";
  static const _streakKey = "streak";
  static const _lastActiveKey = "last_active";
  static const _tasksKey = "tasks_done";
  static const _activeDaysKey = "active_days";

  /// ============================
  /// Points (XP)
  /// ============================
  static Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  static Future<void> addPoints(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_pointsKey) ?? 0;
    await prefs.setInt(_pointsKey, current + xp);

    await _updateActiveDay();
  }

  /// ============================
  /// Streak
  /// ============================
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    int streak = prefs.getInt(_streakKey) ?? 0;
    String? last = prefs.getString(_lastActiveKey);

    if (last != null) {
      DateTime lastDate = DateTime.parse(last);
      if (!isSameDay(lastDate, DateTime.now()) &&
          DateTime.now().difference(lastDate).inDays > 1) {
        streak = 0;
        await prefs.setInt(_streakKey, streak);
      }
    }
    return streak;
  }

  static Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    int streak = await getStreak();
    String? last = prefs.getString(_lastActiveKey);

    if (last != null) {
      DateTime lastDate = DateTime.parse(last);
      if (!isSameDay(lastDate, DateTime.now())) {
        streak++;
        await prefs.setInt(_streakKey, streak);
        await prefs.setString(_lastActiveKey, DateTime.now().toIso8601String());
        await _updateActiveDay();
      }
    } else {
      streak = 1;
      await prefs.setInt(_streakKey, streak);
      await prefs.setString(_lastActiveKey, DateTime.now().toIso8601String());
      await _updateActiveDay();
    }
  }

  static bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// ============================
  /// Tasks Done
  /// ============================
  static Future<int> getTasksCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tasksKey) ?? 0;
  }

  static Future<void> addTask() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_tasksKey) ?? 0;
    await prefs.setInt(_tasksKey, current + 1);

    await _updateActiveDay();
  }

  /// ============================
  /// Active Days
  /// ============================
  static Future<int> getActiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_activeDaysKey) ?? 0;
  }

  static Future<void> _updateActiveDay() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String();
    String? lastActiveDay = prefs.getString("last_active_day");

    if (lastActiveDay == null || !isSameDay(DateTime.parse(lastActiveDay), DateTime.now())) {
      int activeDays = prefs.getInt(_activeDaysKey) ?? 0;
      activeDays++;
      await prefs.setInt(_activeDaysKey, activeDays);
      await prefs.setString("last_active_day", today);
    }
  }
}