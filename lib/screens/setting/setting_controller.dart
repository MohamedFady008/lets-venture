import 'package:get/get.dart';
import 'package:lets_adventure/locale/locale_controller.dart';
import 'package:lets_adventure/screens/auth/auth_controller.dart';
import 'package:lets_adventure/screens/auth/authscreen.dart';

class SettingsController extends GetxController {
  final MyLocaleController langController = Get.find();
  final AuthController authController = Get.find();

  final RxBool isArabic = false.obs;

  @override
  void onInit() {
    super.onInit();
    isArabic.value = langController.initialLang.languageCode == 'ar';
  }

  void toggleLanguage() {
    isArabic.value = !isArabic.value;
    langController.changeLang(isArabic.value ? 'ar' : 'en');
  }

  void signOut() {
    authController.signOut().then((_) {
      Get.offAll(() => const AuthScreen());
    });
  }
}
