import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_adventure/models/game_type.dart';
import 'package:lets_adventure/utils/game_firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final _userName = RxString('');
  final _userEmail = RxString('');
  final _imageUrl = RxString('');
  final _isLoading = RxBool(false);
  final _isLoadingStats = RxBool(false);

  final gameStats = <Map<String, dynamic>>[].obs;

  String get userName => _userName.value;
  String get userEmail => _userEmail.value;
  String get imageUrl => _imageUrl.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingStats => _isLoadingStats.value;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    loadGameStats();
  }

  void showSuccessSnackBar(String message) {
    Get.snackbar(
      'Success!',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> fetchUserData() async {
    try {
      _isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      _userName.value = prefs.getString('userName') ?? '';
      _userEmail.value = prefs.getString('userEmail') ?? '';
      _imageUrl.value = prefs.getString('userImageUrl') ?? '';

      if (_userName.isEmpty || _userEmail.isEmpty) {
        await _fetchFromFirestore();
      }
    } catch (e) {
      showErrorSnackBar('Failed to fetch user data');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _fetchFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (docSnapshot.exists) {
        _userName.value = docSnapshot.data()?['name'] ?? '';
        _userEmail.value = docSnapshot.data()?['email'] ?? '';
        _imageUrl.value = docSnapshot.data()?['imageUrl'] ?? '';

        await _saveToSharedPreferences();
      }
    }
  }

  Future<void> _saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName.value);
    await prefs.setString('userEmail', _userEmail.value);
    await prefs.setString('userImageUrl', _imageUrl.value);
  }

  Future<void> updateUserName(String newName) async {
    if (newName.isEmpty) {
      showErrorSnackBar('Name cannot be empty');
      return;
    }

    try {
      _isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'name': newName});

        _userName.value = newName;
        await _saveToSharedPreferences();
        showSuccessSnackBar('Name updated successfully');
      }
    } catch (e) {
      showErrorSnackBar('Failed to update name');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUserImage() async {
    try {
      _isLoading.value = true;
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final compressedImage = await FlutterImageCompress.compressWithFile(
            image.path,
            minWidth: 300,
            minHeight: 300,
            quality: 60,
          );

          if (compressedImage != null) {
            final ref = FirebaseStorage.instance
                .ref()
                .child('userImages')
                .child('${user.uid}.jpg');

            await ref.putData(compressedImage);
            final newImageUrl = await ref.getDownloadURL();

            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'imageUrl': newImageUrl});

            _imageUrl.value = newImageUrl;
            await _saveToSharedPreferences();
            showSuccessSnackBar('Profile image updated successfully');
          }
        }
      }
    } catch (e) {
      showErrorSnackBar('Failed to update profile image');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadGameStats() async {
    try {
      _isLoadingStats.value = true;
      final gameService = GameFirebaseService();
      final stats = <Map<String, dynamic>>[];

      final otherGameTypes =
          GameType.values.where((type) => type != GameType.vr).toList();

      for (final gameType in otherGameTypes) {
        final highestLevel = await gameService.getHighestLevel(gameType);
        final allStars = await gameService.getAllStars(gameType);
        final totalStars = allStars.values.fold<int>(
          0,
          (acc, stars) => acc + stars,
        );

        String title;
        switch (gameType) {
          case GameType.listen:
            title = 'Listen and Say';
            break;
          case GameType.puzzle:
            title = 'Puzzle of Pyramids';
            break;
          case GameType.match:
            title = 'Match and identify';
            break;
          case GameType.colors:
            title = 'Colors of Features';
            break;
          case GameType.journey:
            title = 'Journey Through History';
            break;
          default:
            title = 'Unknown Game';
        }

        stats.add({
          'title': title,
          'level': highestLevel,
          'totalStars': totalStars,
          'gameType': gameType,
        });
      }

      gameStats.value = stats;
    } catch (e) {
      showErrorSnackBar('Failed to load game statistics');
    } finally {
      _isLoadingStats.value = false;
    }
  }
}
