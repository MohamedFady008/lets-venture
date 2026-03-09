import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/componants/custom_text_field.dart';
import 'package:lets_adventure/screens/auth/auth_controller.dart';

class SignUpForm extends StatelessWidget {
  final FocusNode passwordFocusNode;
  final FocusNode userFocusNode;
  final FocusNode emailFocusNode;
  final TextEditingController passwordController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final AuthController authController;

  const SignUpForm({
    super.key,
    required this.passwordFocusNode,
    required this.userFocusNode,
    required this.emailFocusNode,
    required this.passwordController,
    required this.usernameController,
    required this.emailController,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          buildCustomTextField(
            "auth13".tr,
            obscureText: false,
            keyboardType: TextInputType.name,
            focusNode: userFocusNode,
            controller: usernameController,
            onChanged: (value) => authController.username.value = value,
          ),
          const SizedBox(height: 12),
          buildCustomTextField(
            "auth4".tr,
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
            focusNode: emailFocusNode,
            controller: emailController,
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
          const SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed:
                  authController.isLoading.value
                      ? null
                      : () {
                        authController.signUp(
                          usernameController.text,
                          emailController.text,
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
                            "auth14".tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Get.find<TabController>().animateTo(0);
            },
            child: Text(
              "auth15".tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
