import 'package:flutter/material.dart';
import 'package:lets_adventure/models/game_type.dart';
import 'package:lets_adventure/screens/vr_detail.dart';
import 'package:lets_adventure/utils/page_transitions.dart';

class CardItem extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final String imageAsset;
  final String url;
  final int index;
  final GameType gameType;
  final VoidCallback onCompleted;

  const CardItem({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.imageAsset,
    required this.url,
    required this.index,
    required this.gameType,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final levelNumber = index + 1;
    return GestureDetector(
      onTap: () async {
        final screen = switch (gameType) {
          GameType.vr => VrDetail(level: levelNumber),
          GameType.match => throw UnimplementedError(),
          GameType.puzzle => throw UnimplementedError(),
          GameType.colors => throw UnimplementedError(),
          GameType.journey => throw UnimplementedError(),
          GameType.listen => throw UnimplementedError(),
        };
        await Navigator.push(context, SlideRoute(page: screen));
        onCompleted();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        padding: const EdgeInsets.all(16),
        height: 160,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Image.asset(imageAsset, height: 80),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (gameType != GameType.vr)
                    Flexible(
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
