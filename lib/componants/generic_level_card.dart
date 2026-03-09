import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/games/colors_of_features/game_screen.dart';
import 'package:lets_adventure/games/journey_begins_here/journey_begins_here_detail.dart';
import 'package:lets_adventure/games/listen_and_say/game_listen_screen.dart';
import 'package:lets_adventure/models/game_type.dart';
import 'package:lets_adventure/games/match_and_identify/game_match_screen.dart';
import 'package:lets_adventure/games/puzzle_and_challenge/puzzle_screen.dart';
import 'package:lets_adventure/utils/page_transitions.dart';

class GenericLevelCard extends StatelessWidget {
  final int index;
  final GameType gameType;
  final int highestLevel;
  final Map<int, int> levelStars;
  final bool isScrolling;
  final double scrollOffset;
  final double scrollDirection;
  final double screenHeight;
  final VoidCallback onCompleted;
  final String backgroundImageAsset;
  final _cachedScreens = <GameType, Map<int, Widget>>{};

  GenericLevelCard({
    super.key,
    required this.index,
    required this.gameType,
    required this.highestLevel,
    required this.levelStars,
    required this.isScrolling,
    required this.scrollOffset,
    required this.scrollDirection,
    required this.screenHeight,
    required this.onCompleted,
    required this.backgroundImageAsset,
  });

  Widget _getScreenForLevel(GameType type, int levelNumber) {
    if (_cachedScreens[type] == null) {
      _cachedScreens[type] = {};
    }

    if (_cachedScreens[type]![levelNumber] == null) {
      _cachedScreens[type]![levelNumber] = switch (type) {
        GameType.match => MatchGameScreen(level: levelNumber),
        GameType.puzzle => PuzzleScreen(
          level: levelNumber,
          onCompleted: onCompleted,
        ),
        GameType.colors => GameScreen(level: levelNumber),
        GameType.journey => JourneyBeginsHereDetail(level: levelNumber),
        GameType.vr => throw UnimplementedError(),
        GameType.listen => ListenAndSay(level: levelNumber),
      };
    }

    return _cachedScreens[type]![levelNumber]!;
  }

  @override
  Widget build(BuildContext context) {
    final levelNumber = index + 1;
    final unlocked = gameType == GameType.vr || levelNumber <= highestLevel;
    final stars = levelStars[levelNumber] ?? 0;

    final itemOffset = index * 150.0;
    final offset = (itemOffset - scrollOffset - screenHeight / 2 + 50).clamp(
      -300.0,
      300.0,
    );
    final rotationAngle =
        isScrolling ? (offset / 300 * pi / 6) * scrollDirection : 0.0;
    final Widget lockOverlay =
        unlocked
            ? const SizedBox.shrink()
            : Container(
              width: 1040,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.lock, color: Colors.white, size: 36),
              ),
            );

    return Transform(
      alignment: Alignment.center,
      transform:
          Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(rotationAngle),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: GestureDetector(
          onTap:
              unlocked
                  ? () async {
                    final screen = _getScreenForLevel(gameType, levelNumber);
                    await Navigator.push(context, SlideRoute(page: screen));
                    onCompleted();
                  }
                  : null,
          child: Stack(
            children: [
              Container(
                width: 1040,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backgroundImageAsset),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "level".tr.replaceAll(
                          '@number',
                          levelNumber.toString(),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (unlocked)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (starIndex) => Icon(
                              starIndex < stars
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              lockOverlay,
            ],
          ),
        ),
      ),
    );
  }
}
