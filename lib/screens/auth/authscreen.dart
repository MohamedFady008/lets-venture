import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/screens/auth/auth_controller.dart';
import 'forms/sign_in_form.dart';
import 'forms/sign_up_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthController authController = Get.put(AuthController());

  final FocusNode _passwordFocusNodeSignIn = FocusNode();
  final FocusNode _passwordFocusNodeSignUp = FocusNode();
  final FocusNode _userFocusNodeSignIn = FocusNode();
  final FocusNode _userFocusNodeSignUp = FocusNode();
  final FocusNode _emailFocusNodeSignUp = FocusNode();

  final TextEditingController _usernameControllerSignIn =
      TextEditingController();
  final TextEditingController _passwordControllerSignIn =
      TextEditingController();
  final TextEditingController _usernameControllerSignUp =
      TextEditingController();
  final TextEditingController _passwordControllerSignUp =
      TextEditingController();
  final TextEditingController _emailControllerSignUp = TextEditingController();

  final RxBool _isPasswordFocused = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Get.put(_tabController);

    _tabController.addListener(() {
      setState(() {});
    });

    _userFocusNodeSignIn.addListener(_updateFocus);
    _userFocusNodeSignUp.addListener(_updateFocus);
    _emailFocusNodeSignUp.addListener(_updateFocus);
    _passwordFocusNodeSignIn.addListener(_updateFocus);
    _passwordFocusNodeSignUp.addListener(_updateFocus);
  }

  void _updateFocus() {
    _isPasswordFocused.value =
        _passwordFocusNodeSignIn.hasFocus || _passwordFocusNodeSignUp.hasFocus;
  }

  @override
  void dispose() {
    _tabController.dispose();

    _passwordFocusNodeSignIn.removeListener(_updateFocus);
    _passwordFocusNodeSignUp.removeListener(_updateFocus);
    _userFocusNodeSignIn.removeListener(_updateFocus);
    _userFocusNodeSignUp.removeListener(_updateFocus);
    _emailFocusNodeSignUp.removeListener(_updateFocus);

    _passwordFocusNodeSignIn.dispose();
    _passwordFocusNodeSignUp.dispose();
    _userFocusNodeSignIn.dispose();
    _userFocusNodeSignUp.dispose();
    _emailFocusNodeSignUp.dispose();

    _usernameControllerSignIn.dispose();
    _passwordControllerSignIn.dispose();
    _usernameControllerSignUp.dispose();
    _passwordControllerSignUp.dispose();
    _emailControllerSignUp.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double tabWidth = Get.width / 2;
    double petXOffset = (_tabController.index * tabWidth) + (tabWidth / 2) - 45;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "auth1".tr,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Image.asset('assets/name.png', fit: BoxFit.fill),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: Colors.black,
                              indicatorColor: Colors.yellow,
                              indicatorWeight: 2,
                              tabs: [
                                Tab(text: "auth2".tr),
                                Tab(text: "auth3".tr),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                SignInForm(
                                  passwordFocusNode: _passwordFocusNodeSignIn,
                                  userFocusNode: _userFocusNodeSignIn,
                                  passwordController: _passwordControllerSignIn,
                                  usernameController: _usernameControllerSignIn,
                                  authController: authController,
                                ),
                                SignUpForm(
                                  passwordFocusNode: _passwordFocusNodeSignUp,
                                  userFocusNode: _userFocusNodeSignUp,
                                  emailFocusNode: _emailFocusNodeSignUp,
                                  passwordController: _passwordControllerSignUp,
                                  usernameController: _usernameControllerSignUp,
                                  emailController: _emailControllerSignUp,
                                  authController: authController,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 210,
            left: Get.locale?.languageCode == 'en' ? petXOffset : null,
            right: Get.locale?.languageCode == 'ar' ? petXOffset : null,
            child: Obx(
              () => SizedBox(
                width: 90,
                child: Image.asset(
                  _isPasswordFocused.value
                      ? 'assets/peeking_pet.png'
                      : 'assets/peeking_pet.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
