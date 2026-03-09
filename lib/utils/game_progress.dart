import 'package:lets_adventure/utils/game_firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_type.dart';

class GameProgress {
  static final GameFirebaseService _firebaseService = GameFirebaseService();
  static SharedPreferences? _prefsInstance;
  static bool _isSyncing = false;

  static Future<SharedPreferences> get _prefs async {
    _prefsInstance ??= await SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  static String _prefix(GameType type) {
    switch (type) {
      case GameType.listen:
        return "listen_";
      case GameType.match:
        return "match_";
      case GameType.puzzle:
        return "puzzle_";
      case GameType.vr:
        return "vr_";
      case GameType.colors:
        return "colors_";
      case GameType.journey:
        return "Journey_";
    }
  }

  static Future<int> getStarsForLevel(GameType type, int level) async {
    final prefs = await _prefs;
    final key = "${_prefix(type)}stars_$level";

    if (prefs.containsKey(key)) {
      return prefs.getInt(key) ?? 0;
    }

    try {
      final firebaseStars = await _firebaseService.getStarsForLevel(
        type,
        level,
      );
      await prefs.setInt(key, firebaseStars);
      return firebaseStars;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> setStarsForLevel(
    GameType type,
    int level,
    int stars,
  ) async {
    final prefs = await _prefs;
    final key = "${_prefix(type)}stars_$level";

    final currentStars = prefs.getInt(key) ?? -1;
    if (currentStars == stars) return;

    await prefs.setInt(key, stars);
    await _firebaseService.saveStarsForLevel(type, level, stars);
  }

  static Future<int> getHighestLevel(GameType type) async {
    final prefs = await _prefs;
    final key = "${_prefix(type)}highest_level";

    if (prefs.containsKey(key)) {
      return prefs.getInt(key) ?? 1;
    }

    try {
      final firebaseHighest = await _firebaseService.getHighestLevel(type);
      await prefs.setInt(key, firebaseHighest);
      return firebaseHighest;
    } catch (e) {
      return 1;
    }
  }

  // إضافة دالة للتحقق من حالة الاتصال
  static Future<bool> isConnected() async {
    try {
      await _firebaseService.getRevealPowerUps();
      return true;
    } catch (e) {
      return false;
    }
  }

  // تحسين دالة loadAllStars
  static Future<Map<int, int>> loadAllStars(
    GameType type, {
    int maxLevel = 18,
    bool forceRefresh = false,
  }) async {
    final prefs = await _prefs;
    Map<int, int> stars = {};
    bool hasLocalData = false;

    // تحميل البيانات المحلية أولاً
    for (int i = 1; i <= maxLevel; i++) {
      final key = "${_prefix(type)}stars_$i";
      if (prefs.containsKey(key)) {
        stars[i] = prefs.getInt(key) ?? 0;
        hasLocalData = true;
      } else {
        stars[i] = 0;
      }
    }

    // إذا لم تكن هناك بيانات محلية أو طُلب تحديث قسري
    if (!hasLocalData || forceRefresh) {
      final firebaseStars = await _firebaseService.getAllStars(
        type,
        maxLevel: maxLevel,
      );

      for (final entry in firebaseStars.entries) {
        final key = "${_prefix(type)}stars_${entry.key}";
        await prefs.setInt(key, entry.value);
        stars[entry.key] = entry.value;
      }
    } else {
      // مزامنة في الخلفية
      _syncStarsWithFirebase(type, maxLevel);
    }

    return stars;
  }

  static Future<void> setHighestLevel(GameType type, int level) async {
    final prefs = await _prefs;
    final key = "${_prefix(type)}highest_level";

    final currentLevel = prefs.getInt(key) ?? -1;
    if (currentLevel == level) return;

    await prefs.setInt(key, level);
    await _firebaseService.saveHighestLevel(type, level);
  }

  static Future<int> getRevealPowerUps() async {
    final prefs = await _prefs;
    final key = "reveal_power_ups";

    if (prefs.containsKey(key)) {
      return prefs.getInt(key) ?? 0;
    }

    try {
      final firebasePowerUps = await _firebaseService.getRevealPowerUps();
      await prefs.setInt(key, firebasePowerUps);
      return firebasePowerUps;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> setRevealPowerUps(int count) async {
    final prefs = await _prefs;
    final key = "reveal_power_ups";

    final currentCount = prefs.getInt(key) ?? -1;
    if (currentCount == count) return;

    await prefs.setInt(key, count);
    await _firebaseService.savePowerUps(reveal: count);
  }

  static Future<int> getFreezePowerUps() async {
    final prefs = await _prefs;
    final key = "freeze_power_ups";

    if (prefs.containsKey(key)) {
      return prefs.getInt(key) ?? 0;
    }

    try {
      final firebasePowerUps = await _firebaseService.getFreezePowerUps();
      await prefs.setInt(key, firebasePowerUps);
      return firebasePowerUps;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> setFreezePowerUps(int count) async {
    final prefs = await _prefs;
    final key = "freeze_power_ups";

    final currentCount = prefs.getInt(key) ?? -1;
    if (currentCount == count) return;

    await prefs.setInt(key, count);
    await _firebaseService.savePowerUps(freeze: count);
  }

  static Future<void> _syncStarsWithFirebase(
    GameType type,
    int maxLevel,
  ) async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final prefs = await _prefs;
      final firebaseStars = await _firebaseService.getAllStars(
        type,
        maxLevel: maxLevel,
      );

      for (final entry in firebaseStars.entries) {
        final level = entry.key;
        final fbStars = entry.value;
        final key = "${_prefix(type)}stars_$level";
        final localStars = prefs.getInt(key) ?? 0;

        if (localStars < fbStars) {
          await prefs.setInt(key, fbStars);
        } else if (localStars > fbStars) {
          await _firebaseService.saveStarsForLevel(type, level, localStars);
        }
      }
    } catch (e) {
      //
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> saveAllStars(GameType type, Map<int, int> stars) async {
    final prefs = await _prefs;

    for (final entry in stars.entries) {
      final level = entry.key;
      final starCount = entry.value;
      final key = "${_prefix(type)}stars_$level";

      final currentStars = prefs.getInt(key) ?? -1;
      if (currentStars == starCount) continue;

      await prefs.setInt(key, starCount);
      await _firebaseService.saveStarsForLevel(type, level, starCount);
    }
  }

  static Future<void> syncAllData() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      for (final type in GameType.values) {
        await _syncStarsWithFirebase(type, 18);
      }

      final prefs = await _prefs;

      final revealKey = "reveal_power_ups";
      if (prefs.containsKey(revealKey)) {
        final localReveal = prefs.getInt(revealKey) ?? 0;
        final firebaseReveal = await _firebaseService.getRevealPowerUps();

        if (localReveal != firebaseReveal) {
          final maxValue =
              localReveal > firebaseReveal ? localReveal : firebaseReveal;

          await prefs.setInt(revealKey, maxValue);
          await _firebaseService.savePowerUps(reveal: maxValue);
        }
      }

      final freezeKey = "freeze_power_ups";
      if (prefs.containsKey(freezeKey)) {
        final localFreeze = prefs.getInt(freezeKey) ?? 0;
        final firebaseFreeze = await _firebaseService.getFreezePowerUps();

        if (localFreeze != firebaseFreeze) {
          final maxValue =
              localFreeze > firebaseFreeze ? localFreeze : firebaseFreeze;

          await prefs.setInt(freezeKey, maxValue);
          await _firebaseService.savePowerUps(freeze: maxValue);
        }
      }
    } catch (e) {
      //
    } finally {
      _isSyncing = false;
    }
  }
}
