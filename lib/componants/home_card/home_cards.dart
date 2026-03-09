import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/componants/home_card/home_card_controller.dart';

class HomeCards extends StatelessWidget {
  const HomeCards({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeCardsController controller = Get.find();

    return Obx(() {
      if (controller.filteredCards.isEmpty) {
        return const Center(
          child: Text(
            'No matching cards found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
      }

      return PageView.builder(
        controller: controller.pageController,
        itemCount: controller.filteredCards.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final scale =
                (index == controller.currentPage.floor() ||
                        index == controller.currentPage.ceil())
                    ? 1.0
                    : 0.9;
            final card = controller.filteredCards[index];

            return AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 300),
              child: _buildCard(card, context),
            );
          });
        },
      );
    });
  }

  Widget _buildCard(Map<String, dynamic> card, BuildContext context) {
    return GestureDetector(
      onTap: () {
        final screen = card['screen'];
        if (screen is Widget) {
          Get.to(() => screen);
        } else if (screen is Function) {
          Get.to(screen);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 50),
        decoration: BoxDecoration(
          color: card['color'],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  card['image'],
                  fit: BoxFit.cover,
                  cacheWidth: 200,
                  cacheHeight: 200,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              card['title'],
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              card['description'],
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: card['progress'],
              backgroundColor: Colors.white38,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.folder_open, color: Colors.white70, size: 18),
                const SizedBox(width: 4),
                Text(
                  "${card['files']}${'homeCard6'.tr}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
