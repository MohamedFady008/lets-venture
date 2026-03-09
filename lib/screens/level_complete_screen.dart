import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'package:lets_adventure/games/listen_and_say/game_listen_screen.dart';
import 'package:lets_adventure/models/game_type.dart';
import 'package:lets_adventure/screens/level_selector.dart';
import 'package:lets_adventure/games/colors_of_features/game_screen.dart';
import 'package:lets_adventure/games/match_and_identify/game_match_screen.dart';
import 'package:lets_adventure/games/puzzle_and_challenge/puzzle_screen.dart';
import 'package:lets_adventure/utils/page_transitions.dart';

class LevelCompleteScreen extends StatefulWidget {
  final int level;
  final int stars;
  final GameType gameType;

  const LevelCompleteScreen({
    super.key,
    required this.level,
    required this.stars,
    required this.gameType,
  });

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastLevel = widget.level >= 18;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 5,
              gravity: 0.2,
              shouldLoop: false,
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/name.png', height: 150),
                  const SizedBox(height: 10),
                  Text(
                    "- Level ${widget.level}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Icon(
                        index < widget.stars
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (!isLastLevel) ...[
                    _buildButton(
                      label: "next_level".tr,
                      icon: Icons.navigate_next,
                      color: Colors.green.shade600,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          SlideRoute(page: _getNextLevelScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildButton(
                    label: "back_to_levels".tr,
                    icon: Icons.list,
                    color: Colors.deepPurple.shade400,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        FadeRoute(page: _getLevelSelector()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    final bg = switch (widget.gameType) {
      GameType.match => 'assets/match_back.png',
      GameType.puzzle => 'assets/background_kids_theme.png',
      GameType.colors || GameType.journey =>
        throw UnimplementedError("VR does not use LevelCompleteScreen."),
      GameType.vr =>
        throw UnimplementedError("VR does not use LevelCompleteScreen."),
      GameType.listen => 'assets/background_kids_theme.png',
    };

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(bg), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: Get.width * 0.6,
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _getNextLevelScreen() {
    final next = widget.level + 1;
    return switch (widget.gameType) {
      GameType.match => MatchGameScreen(level: next),
      GameType.puzzle => PuzzleScreen(level: next),
      GameType.colors => GameScreen(level: next),
      GameType.journey =>
        throw UnimplementedError("VR does not use LevelCompleteScreen."),
      GameType.vr =>
        throw UnimplementedError("VR does not use LevelCompleteScreen."),
      GameType.listen => ListenAndSay(level: next),
    };
  }

  Widget _getLevelSelector() {
    return GameLevelSelector(
      title: switch (widget.gameType) {
        GameType.match => "Match and Identify",
        GameType.puzzle => "Puzzle & Challenge",
        GameType.colors => "Colors of Features",
        GameType.journey => "Journey Begins Here",
        GameType.vr =>
          throw UnimplementedError("VR does not use LevelCompleteScreen."),
        GameType.listen => "Listen And Say",
      },
      gameType: widget.gameType,
    );
  }
}
