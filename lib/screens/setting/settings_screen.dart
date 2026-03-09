import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/screens/setting/setting_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset('assets/settings_back.png', fit: BoxFit.cover),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: MediaQuery.of(context).padding.top + 30,
            bottom: MediaQuery.of(context).padding.bottom + 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Align(
                      alignment:
                          controller.isArabic.value
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: controller.toggleLanguage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: Obx(
                          () => Text(
                            controller.isArabic.value
                                ? 'اللغة العربية'
                                : 'English',
                            style: const TextStyle(
                              fontFamily: 'Papyrus',
                              color: Color(0xFFFFB85D),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Text(
                "setting1".tr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "setting2".tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              Text(
                "setting3".tr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "setting4".tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: controller.signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB85D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: Text(
                  "setting5".tr,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
