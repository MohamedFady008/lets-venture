import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lets_adventure/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool rememberMe = false.obs;

  final username = ''.obs;
  final email = ''.obs;
  final password = ''.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    rememberMe.value = prefs.getBool('rememberMe') ?? false;
  }

  void toggleRememberMe(bool value) async {
    rememberMe.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);

    if (!value) {
      await prefs.remove('userEmail');
      await prefs.remove('userPassword');
    }
  }

  Future<void> signIn(
    String email,
    String password, {
    bool autoSignIn = false,
  }) async {
    if (!autoSignIn) {
      isLoading.value = true;
      error.value = '';
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (rememberMe.value) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);
        await prefs.setString('userPassword', password);
      }

      Get.offAll(() => MainScaffold());
    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
    } finally {
      if (!autoSignIn) {
        isLoading.value = false;
      }
    }
  }

  Future<void> signUp(String username, String email, String password) async {
    isLoading.value = true;
    error.value = '';

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(username);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await userCredential.user?.sendEmailVerification();

      Get.snackbar(
        'Success',
        'Account created successfully! Please verify your email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.find<TabController>().animateTo(0);
    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
    } catch (e) {
      error.value = 'Error saving user data: ${e.toString()}';
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
  }

  void handleAuthError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No user found with this email.';
        break;
      case 'wrong-password':
        errorMessage = 'Wrong password.';
        break;
      case 'email-already-in-use':
        errorMessage = 'Email is already in use.';
        break;
      case 'weak-password':
        errorMessage = 'Password is too weak.';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email format.';
        break;
      default:
        errorMessage = 'An error occurred. Please try again.';
    }

    error.value = errorMessage;
    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
