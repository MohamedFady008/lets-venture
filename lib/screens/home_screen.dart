import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/componants/home_card/home_card_controller.dart';
import '../componants/home_card/home_cards.dart';
import '../screens/profile/profile_controller.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());
    final HomeCardsController homeCardsController = Get.put(
      HomeCardsController(),
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    "${"home2".tr}${profileController.userName}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Center(
                    child: Icon(Icons.person, color: Colors.indigo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => homeCardsController.search(value),
              decoration: InputDecoration(
                hintText: 'home1'.tr,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: const HomeCards()),
          ],
        ),
      ),
    );
  }
}
