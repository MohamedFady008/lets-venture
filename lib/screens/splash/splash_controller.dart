import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/authscreen.dart';
import '../auth/auth_controller.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  final AuthController authController = Get.put(AuthController());

  var isAnimationCompleted = false.obs;
  var isAuthCheckCompleted = false.obs;
  var signInSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(animationController);

    animationController.forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isAnimationCompleted.value = true;
        _navigateIfReady();
      }
    });

    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      final savedEmail = prefs.getString('userEmail');
      final savedPassword = prefs.getString('userPassword');

      if (savedEmail != null &&
          savedPassword != null &&
          savedEmail.isNotEmpty &&
          savedPassword.isNotEmpty) {
        await authController.signIn(
          savedEmail,
          savedPassword,
          autoSignIn: true,
        );
        signInSuccess.value = true;
      }
    }

    isAuthCheckCompleted.value = true;
    _navigateIfReady();
  }

  void _navigateIfReady() {
    if (isAnimationCompleted.value && isAuthCheckCompleted.value) {
      if (signInSuccess.value) {
        Get.off(() => MainScaffold());
      } else {
        Get.off(() => const AuthScreen());
      }
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
