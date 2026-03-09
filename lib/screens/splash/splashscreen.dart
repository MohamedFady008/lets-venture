import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashController controller = Get.put(SplashController());

  Widget buildLoadingBar() {
    return Container(
      width: 200,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: controller.animation,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: controller.animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              );
            },
          ),
          Center(
            child: Text(
              'splash1'.tr,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
            cacheHeight: 1080,
            cacheWidth: 1920,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  buildLoadingBar(),
                  const SizedBox(height: 20),
                  Obx(
                    () => Text(
                      controller.isAuthCheckCompleted.value
                          ? 'splash2'.tr
                          : 'splash2'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
