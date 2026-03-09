import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_type.dart';

class GameFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userUid => _auth.currentUser?.uid;

  DocumentReference? get _userGamesRef {
    final uid = _userUid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('games')
        .doc('progress');
  }

  Future<void> saveStarsForLevel(GameType type, int level, int stars) async {
    final ref = _userGamesRef;
    if (ref == null) return;

    await ref.set({
      _getGameTypeKey(type): {
        'levels': {
          level.toString(): {
            'stars': stars,
            'lastPlayed': FieldValue.serverTimestamp(),
          },
        },
      },
    }, SetOptions(merge: true));
  }

  Future<void> saveHighestLevel(GameType type, int level) async {
    final ref = _userGamesRef;
    if (ref == null) return;

    await ref.set({
      _getGameTypeKey(type): {
        'highestLevel': level,
        'lastUpdated': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  Future<void> savePowerUps({int? reveal, int? freeze}) async {
    final ref = _userGamesRef;
    if (ref == null) return;

    final data = <String, dynamic>{
      'powerUps': {'lastUpdated': FieldValue.serverTimestamp()},
    };

    if (reveal != null) {
      data['powerUps']['reveal'] = reveal;
    }

    if (freeze != null) {
      data['powerUps']['freeze'] = freeze;
    }

    await ref.set(data, SetOptions(merge: true));
  }

  Future<int> getStarsForLevel(GameType type, int level) async {
    final ref = _userGamesRef;
    if (ref == null) return 0;

    final doc = await ref.get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) return 0;

    final gameData = data[_getGameTypeKey(type)] as Map<String, dynamic>?;
    if (gameData == null) return 0;

    final levels = gameData['levels'] as Map<String, dynamic>?;
    if (levels == null) return 0;

    final levelData = levels[level.toString()] as Map<String, dynamic>?;
    if (levelData == null) return 0;

    return levelData['stars'] as int? ?? 0;
  }

  Future<int> getHighestLevel(GameType type) async {
    final ref = _userGamesRef;
    if (ref == null) return 1;

    final doc = await ref.get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) return 1;

    final gameData = data[_getGameTypeKey(type)] as Map<String, dynamic>?;
    if (gameData == null) return 1;

    return gameData['highestLevel'] as int? ?? 1;
  }

  Future<int> getRevealPowerUps() async {
    final ref = _userGamesRef;
    if (ref == null) return 0;

    final doc = await ref.get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) return 0;

    final powerUps = data['powerUps'] as Map<String, dynamic>?;
    if (powerUps == null) return 0;

    return powerUps['reveal'] as int? ?? 0;
  }

  Future<int> getFreezePowerUps() async {
    final ref = _userGamesRef;
    if (ref == null) return 0;

    final doc = await ref.get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) return 0;

    final powerUps = data['powerUps'] as Map<String, dynamic>?;
    if (powerUps == null) return 0;

    return powerUps['freeze'] as int? ?? 0;
  }

  Future<Map<int, int>> getAllStars(GameType type, {int maxLevel = 18}) async {
    final ref = _userGamesRef;
    if (ref == null) return {};

    final doc = await ref.get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) return {};

    final gameData = data[_getGameTypeKey(type)] as Map<String, dynamic>?;
    if (gameData == null) return {};

    final levels = gameData['levels'] as Map<String, dynamic>?;
    if (levels == null) return {};

    final result = <int, int>{};
    for (int i = 1; i <= maxLevel; i++) {
      final levelData = levels[i.toString()] as Map<String, dynamic>?;
      if (levelData != null) {
        result[i] = levelData['stars'] as int? ?? 0;
      } else {
        result[i] = 0;
      }
    }

    return result;
  }

  String _getGameTypeKey(GameType type) {
    switch (type) {
      case GameType.match:
        return 'match';
      case GameType.puzzle:
        return 'puzzle';
      case GameType.vr:
        return 'vr';
      case GameType.colors:
        return 'colors';
      case GameType.journey:
        return 'journey';
      case GameType.listen:
        return 'listen';
    }
  }
}
