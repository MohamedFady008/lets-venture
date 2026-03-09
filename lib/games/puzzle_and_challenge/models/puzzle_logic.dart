import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lets_adventure/games/puzzle_and_challenge/models/puzzle_tile.dart';

class PuzzleGame {
  final int level;
  final int gridSize;
  List<PuzzleTile> pieces = [];
  List<PuzzleTile?> placed = [];
  int score = 0;
  int get totalPieces => gridSize * gridSize;
  bool isLoaded = false;

  PuzzleGame({required this.level}) : gridSize = 3 + ((level - 1) ~/ 5);

  Future<void> loadImage() async {
    try {
      final byteData = await rootBundle.load('assets/full_$level.png');
      final codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: 512,
      );
      final frame = await codec.getNextFrame();
      final fullImage = frame.image;

      final pieceWidth = fullImage.width / gridSize;
      final pieceHeight = fullImage.height / gridSize;

      pieces = List.generate(totalPieces, (i) {
        final row = i ~/ gridSize;
        final col = i % gridSize;
        return PuzzleTile(
          index: i,
          image: fullImage,
          region: Rect.fromLTWH(
            col * pieceWidth,
            row * pieceHeight,
            pieceWidth,
            pieceHeight,
          ),
        );
      });

      placed = List<PuzzleTile?>.filled(totalPieces, null);
      pieces.shuffle();
      isLoaded = true;
    } catch (e) {
      debugPrint('Error loading image: $e');
      rethrow;
    }
  }

  bool acceptTile(int index, PuzzleTile tile) {
    if (tile.index == index) {
      pieces.remove(tile);
      placed[index] = tile;
      score += (100 ~/ totalPieces);
      return true;
    } else {
      score = max(0, score - 5);
      return false;
    }
  }

  bool get isComplete => placed.every((tile) => tile != null);

  int calculateStars() {
    return score >= 90
        ? 3
        : score >= 60
        ? 2
        : 1;
  }
}
