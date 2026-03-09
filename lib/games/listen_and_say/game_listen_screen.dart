import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/games/listen_and_say/game_listen_controller.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:lets_adventure/main_screen.dart';

class ListenAndSay extends StatefulWidget {
  final int level;
  const ListenAndSay({super.key, required this.level});

  @override
  State<ListenAndSay> createState() => _ListenAndSayState();
}

class _ListenAndSayState extends State<ListenAndSay>
    with SingleTickerProviderStateMixin {
  late GameController controller;
  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackScale;
  late Animation<double> _wordRotation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      GameController(widget.level),
      tag: 'game_${widget.level}',
    );
    _feedbackAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _feedbackScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _feedbackAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _wordRotation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(
        parent: _feedbackAnimationController,
        curve: Curves.elasticInOut,
      ),
    );
    ever(
      controller.isCorrect,
      (_) => _feedbackAnimationController.forward(from: 0),
    );
  }

  @override
  void dispose() {
    _feedbackAnimationController.dispose();
    Get.delete<GameController>(tag: 'game_${widget.level}', force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final screenSize = Get.size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Get.offAll(() => MainScaffold());
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/background_kids_theme.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () => Get.offAll(() => MainScaffold()),
                        ),
                        Text(
                          "level".tr.replaceAll(
                            '@number',
                            widget.level.toString(),
                          ),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.deepPurple,
                          ),
                        ),
                        const Spacer(),
                        Obx(
                          () => Text(
                            "attempts".tr.replaceAll(
                              '@number',
                              controller.attemptsCount.toString(),
                            ),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 100),
                        child: Column(
                          children: [
                            Obx(
                              () => AnimatedOpacity(
                                opacity: controller.showWord.value ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 800),
                                child: Card(
                                  elevation: 8,
                                  shadowColor: Colors.deepPurple.withValues(
                                    alpha: 0.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 30,
                                      horizontal: 20,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          ':انطق هذه الكلمة',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    Colors.deepPurple.shade700,
                                              ),
                                        ),
                                        const SizedBox(height: 20),
                                        AnimatedBuilder(
                                          animation: _wordRotation,
                                          builder: (context, child) {
                                            return Transform(
                                              alignment: Alignment.center,
                                              transform:
                                                  Matrix4.identity()
                                                    ..rotateZ(
                                                      _wordRotation.value,
                                                    )
                                                    ..scaleByDouble(
                                                      _feedbackScale.value,
                                                      _feedbackScale.value,
                                                      1.0,
                                                      1.0,
                                                    ),
                                              child: Text(
                                                controller.targetWord,
                                                style: TextStyle(
                                                  fontSize:
                                                      screenSize.width * 0.12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepPurple,
                                                  letterSpacing: 1.2,
                                                  shadows: [
                                                    Shadow(
                                                      blurRadius: 3.0,
                                                      color: Colors.deepPurple
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      offset: const Offset(
                                                        1,
                                                        1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Obx(
                                  () => ElevatedButton.icon(
                                    onPressed:
                                        controller.isPlaying.value
                                            ? null
                                            : controller.playAudio,
                                    icon: Icon(
                                      controller.isPlaying.value
                                          ? Icons.volume_down
                                          : Icons.volume_up,
                                    ),
                                    label: Text(
                                      controller.isPlaying.value
                                          ? '...تشغيل'
                                          : 'اسمع الكلمة',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.deepPurple.shade300,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                Obx(
                                  () => ElevatedButton.icon(
                                    onPressed:
                                        controller.isListening.value
                                            ? controller.stopListening
                                            : controller.listen,
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Icon(
                                        controller.isListening.value
                                            ? Icons.stop
                                            : Icons.mic,
                                        key: ValueKey(
                                          controller.isListening.value,
                                        ),
                                      ),
                                    ),
                                    label: Text(
                                      controller.isListening.value
                                          ? 'ايقاف'
                                          : 'تحدث الان',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          controller.isListening.value
                                              ? Colors.redAccent
                                              : Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Obx(
                              () => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child:
                                    controller.isListening.value
                                        ? _buildListeningIndicator()
                                        : const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx(
                              () => AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity:
                                    controller.spokenText.value.isNotEmpty
                                        ? 1
                                        : 0,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        ':انت قلت',
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        controller.spokenText.value,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx(
                              () =>
                                  controller.spokenText.value.isNotEmpty
                                      ? AnimatedOpacity(
                                        opacity: 1.0,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        child: ScaleTransition(
                                          scale: _feedbackScale,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 24,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  controller.isCorrect.value
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color:
                                                    controller.isCorrect.value
                                                        ? Colors.green
                                                        : Colors.red.shade300,
                                                width: 2,
                                              ),
                                            ),
                                            child: Text(
                                              controller.isCorrect.value
                                                  ? '✅ صحيح!'
                                                  : '❌ حاول مجددا!',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    controller.isCorrect.value
                                                        ? Colors.green.shade800
                                                        : Colors.red.shade700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: controller.confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 12,
                minBlastForce: 5,
                emissionFrequency: 0.03,
                numberOfParticles: 30,
                gravity: 0.2,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.red,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.mic, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '...استماع',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            _buildPulsingDot(),
            const SizedBox(width: 2),
            _buildPulsingDot(delay: 300),
            const SizedBox(width: 2),
            _buildPulsingDot(delay: 600),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingDot({int delay = 0}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        final double opacity = (0.4 +
                (0.6 * sin((value * 2 * pi) + (delay / 1000 * 2 * pi))))
            .clamp(0.0, 1.0);
        return Container(
          height: 8 + (4 * sin((value * 2 * pi) + (delay / 1000 * 2 * pi))),
          width: 8 + (4 * sin((value * 2 * pi) + (delay / 1000 * 2 * pi))),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
