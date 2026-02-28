import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const String streakKey = 'streak';
  static const String lastLoginKey = 'last_login';
  static const String pointsKey = 'points';

  // تحديث الستريك عند فتح التطبيق
  static Future<int> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();

    int streak = prefs.getInt(streakKey) ?? 0;
    String? lastLogin = prefs.getString(lastLoginKey);

    DateTime today = DateTime.now();
    String todayStr = "${today.year}-${today.month}-${today.day}";

    if (lastLogin == null) {
      streak = 1;
    } else {
      DateTime lastDate = DateTime.parse(lastLogin);
      int difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        streak += 1;
      } else if (difference > 1) {
        streak = 1;
      }
    }

    await prefs.setInt(streakKey, streak);
    await prefs.setString(lastLoginKey, todayStr);

    return streak;
  }

  // جلب الستريك
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(streakKey) ?? 0;
  }

  // إضافة نقاط
  static Future<int> addPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(pointsKey) ?? 0;
    current += points;
    await prefs.setInt(pointsKey, current);
    return current;
  }

  // جلب النقاط
  static Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(pointsKey) ?? 0;
  }
}