import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/componants/game_scaffold.dart';
import 'package:lets_adventure/games/puzzle_and_challenge/puzzle_controller.dart';
import 'package:lets_adventure/games/puzzle_and_challenge/models/puzzle_tile.dart';

class PuzzleScreen extends GetView<PuzzleController> {
  final int level;
  final VoidCallback? onCompleted;

  PuzzleScreen({super.key, required this.level, this.onCompleted}) {
    Get.put(PuzzleController(level: level));
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: "level".tr.replaceAll('@number', level.toString()),
      onPause: () {},
      background: const Image(
        image: AssetImage('assets/background_kids_theme.png'),
        fit: BoxFit.fill,
      ),
      appBarForegroundColor: Colors.white,
      child: Obx(() {
        controller.updateTileSize(Get.size);

        return controller.isGameLoaded.value
            ? Column(
              children: [
                Text(
                  "score_time".tr
                      .replaceAll('@score', controller.currentScore.toString())
                      .replaceAll(
                        '@time',
                        controller.elapsedSeconds.toString(),
                      ),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
                Expanded(child: _buildPuzzleGrid()),
                const SizedBox(height: 8),
                _buildDraggablePieces(),
                const SizedBox(height: 12),
              ],
            )
            : const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
      }),
    );
  }

  Widget _buildPuzzleGrid() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Obx(
          () => SizedBox(
            width: controller.tileSize.value * controller.game.gridSize,
            height: controller.tileSize.value * controller.game.gridSize,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: controller.game.gridSize,
              ),
              itemCount: controller.game.totalPieces,
              itemBuilder: (_, index) => _buildGridTile(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridTile(int index) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DragTarget<PuzzleTile>(
        onWillAcceptWithDetails: (details) => details.data.index == index,
        onAcceptWithDetails:
            (details) => controller.acceptTile(index, details.data),
        builder: (context, candidate, rejected) {
          return RepaintBoundary(
            child: Obx(
              () =>
                  controller.placedPieces[index]?.build() ??
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color:
                          candidate.isNotEmpty
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.transparent,
                    ),
                    child: SizedBox(
                      width: controller.tileSize.value,
                      height: controller.tileSize.value,
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDraggablePieces() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Obx(
            () => Row(
              children:
                  controller.availablePieces.map((tile) {
                    final built = tile.build();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Draggable<PuzzleTile>(
                        data: tile,
                        feedback: SizedBox(
                          width: controller.tileSize.value * 0.5,
                          height: controller.tileSize.value * 0.5,
                          child: built,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: SizedBox(
                            width: controller.tileSize.value * 0.5,
                            height: controller.tileSize.value * 0.5,
                            child: built,
                          ),
                        ),
                        child: SizedBox(
                          width: controller.tileSize.value * 0.5,
                          height: controller.tileSize.value * 0.5,
                          child: built,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
