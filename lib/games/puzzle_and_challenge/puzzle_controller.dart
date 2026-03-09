import 'dart:math';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:lets_adventure/games/puzzle_and_challenge/models/puzzle_tile.dart';
import 'package:lets_adventure/games/puzzle_and_challenge/models/puzzle_logic.dart';
import 'package:lets_adventure/models/game_type.dart' as types;
import 'package:lets_adventure/utils/game_progress.dart';

class PuzzleController extends GetxController with GetTickerProviderStateMixin {
  final int level;
  late final PuzzleGame game;
  late final ConfettiController confettiController;

  // Observable variables
  final RxDouble tileSize = 0.0.obs;
  final RxInt elapsedSeconds = 0.obs;
  final RxBool isGameLoaded = false.obs;
  final RxInt currentScore = 0.obs;
  final RxList<PuzzleTile> availablePieces = <PuzzleTile>[].obs;
  final RxList<PuzzleTile?> placedPieces = <PuzzleTile?>[].obs;

  PuzzleController({required this.level}) {
    game = PuzzleGame(level: level);
    confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _initializeGame();
    startTimer();
  }

  void startTimer() {
    ever(elapsedSeconds, (_) => update());
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      elapsedSeconds.value++;
      return true;
    });
  }

  Future<void> _initializeGame() async {
    try {
      await game.loadImage();
      availablePieces.value = game.pieces;
      placedPieces.value = game.placed;
      currentScore.value = game.score;
      isGameLoaded.value = true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load level image.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void updateTileSize(Size size) {
    tileSize.value = min(size.width, size.height) / game.gridSize;
  }

  bool acceptTile(int index, PuzzleTile tile) {
    if (game.acceptTile(index, tile)) {
      availablePieces.value = game.pieces;
      placedPieces.value = game.placed;
      currentScore.value = game.score;

      if (game.isComplete) {
        _handleGameComplete();
      }
      return true;
    }
    return false;
  }

  Future<void> _handleGameComplete() async {
    final stars = game.calculateStars();
    final previous = await GameProgress.getStarsForLevel(
      types.GameType.puzzle,
      level,
    );
    final highest = await GameProgress.getHighestLevel(types.GameType.puzzle);

    await GameProgress.setStarsForLevel(
      types.GameType.puzzle,
      level,
      max(previous, stars),
    );

    if (level == highest && level < 18) {
      await GameProgress.setHighestLevel(types.GameType.puzzle, level + 1);
    }

    confettiController.play();
    await Future.delayed(const Duration(milliseconds: 300));

    Get.offNamed(
      '/level-complete',
      arguments: {
        'level': level,
        'stars': stars,
        'gameType': types.GameType.puzzle,
      },
    );
  }

  @override
  void onClose() {
    confettiController.dispose();
    super.onClose();
  }
}
