import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/date/vr_card_data.dart';
import 'package:lets_adventure/screens/level_selector.dart';
import 'package:lets_adventure/models/game_type.dart';

import 'componants/custom_bottom_nav_bar.dart';
import 'screens/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/setting/settings_screen.dart';

class MainScreenController extends GetxController {
  var currentIndex = 0.obs;

  final List<Widget> pages = [
    HomeScreenContent(),
    GameLevelSelector(
      title: 'VR Experience',
      gameType: GameType.vr,
      maxLevels: GameType.vr == GameType.vr ? titles.length : 18,
    ),
    const ProfileScreen(),
    SettingsScreen(),
  ];
}

class MainScaffold extends StatelessWidget {
  MainScaffold({super.key});

  final MainScreenController controller = Get.put(
    MainScreenController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/settings_back.png', fit: BoxFit.cover),
          ),
          Obx(() => controller.pages[controller.currentIndex.value]),
        ],
      ),
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: (index) => controller.currentIndex.value = index,
        ),
      ),
    );
  }
}
