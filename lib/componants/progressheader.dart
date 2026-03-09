import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressHeader extends StatelessWidget {
  final String title;
  final double progress;
  final int stars;
  final int? highestLevel;
  final int? maxLevels;

  const ProgressHeader({
    super.key,
    required this.title,
    required this.progress,
    required this.stars,
    this.highestLevel,
    this.maxLevels,
  });

  @override
  Widget build(BuildContext context) {
    final validProgress = progress.isNaN || progress < 0 ? 0.0 : progress;
    final validStars = stars < 0 ? 0 : stars;
    final maxPossibleStars = (maxLevels ?? 18) * 3; // 3 نجوم لكل مستوى

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade200.withAlpha(230),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // إضافة معلومات المستوى
          if (highestLevel != null && maxLevels != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'level_progress'.trParams({
                  'current': '$highestLevel',
                  'total': '$maxLevels',
                }),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          Row(
            children: [
              Text(
                "${(validProgress * 100).toInt()}%",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: validProgress,
                  backgroundColor: Colors.white.withAlpha(76),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.greenAccent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$validStars ⭐",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "/ $maxPossibleStars",
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
