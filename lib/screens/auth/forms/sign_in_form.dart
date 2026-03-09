import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/componants/custom_text_field.dart';
import 'package:lets_adventure/screens/auth/auth_controller.dart';

class SignInForm extends StatelessWidget {
  final FocusNode passwordFocusNode;
  final FocusNode userFocusNode;
  final TextEditingController passwordController;
  final TextEditingController usernameController;
  final AuthController authController;

  const SignInForm({
    super.key,
    required this.passwordFocusNode,
    required this.userFocusNode,
    required this.passwordController,
    required this.usernameController,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          buildCustomTextField(
            "auth4".tr,
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
            focusNode: userFocusNode,
            controller: usernameController,
            onChanged: (value) => authController.email.value = value,
          ),
          const SizedBox(height: 12),
          buildCustomTextField(
            "auth5".tr,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            focusNode: passwordFocusNode,
            controller: passwordController,
            onChanged: (value) => authController.password.value = value,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Obx(
                () => Checkbox(
                  value: authController.rememberMe.value,
                  onChanged: (val) {
                    if (val != null) {
                      authController.toggleRememberMe(val);
                    }
                  },
                ),
              ),
              Text("auth6".tr),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => ElevatedButton(
              onPressed:
                  authController.isLoading.value
                      ? null
                      : () {
                        authController.signIn(
                          usernameController.text,
                          passwordController.text,
                        );
                      },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.orange],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(
                    minWidth: 150,
                    minHeight: 50,
                  ),
                  child:
                      authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "auth7".tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text("auth9".tr),
                  content: TextField(
                    decoration: InputDecoration(hintText: "auth10".tr),
                    onChanged: (value) => authController.email.value = value,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text("auth11".tr),
                    ),
                    TextButton(
                      onPressed: () {
                        if (authController.email.value.isNotEmpty) {
                          FirebaseAuth.instance.sendPasswordResetEmail(
                            email: authController.email.value,
                          );
                          Get.back();
                          Get.snackbar(
                            "Password Reset",
                            "Password reset email sent",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: Text("auth12".tr),
                    ),
                  ],
                ),
              );
            },
            child: Text("auth8".tr, style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
