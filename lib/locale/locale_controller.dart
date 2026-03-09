import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/main.dart';
import 'package:lets_adventure/componants/home_card/home_card_controller.dart';

class MyLocaleController extends GetxController {
  Locale initialLang =
      sharepref1!.getString("lang") == null
          ? Get.deviceLocale!
          : Locale(sharepref1!.getString("lang")!);

  void changeLang(String codeLang) {
    Locale locale = Locale(codeLang);
    sharepref1!.setString("lang", codeLang);
    Get.updateLocale(locale);

    // تحديث محتوى البطاقات بعد تغيير اللغة
    try {
      final homeCardsController = Get.find<HomeCardsController>();
      homeCardsController.refreshContent();
    } catch (e) {
      // في حالة عدم وجود HomeCardsController      
    }
  }
}
