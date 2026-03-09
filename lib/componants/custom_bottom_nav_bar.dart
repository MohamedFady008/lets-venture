import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final List<String> icons = const [
    'assets/home.png',
    'assets/vr.png',
    'assets/profile.png',
    'assets/settings.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(icons.length, (index) {
                  return currentIndex == index
                      ? SizedBox(
                        width: 60,
                        height: 200,
                        child: CustomPaint(painter: ConePainter()),
                      )
                      : const SizedBox(width: 60, height: 80);
                }),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(icons.length, (index) {
                  return currentIndex == index
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [const SizedBox(height: 8)],
                      )
                      : const SizedBox(width: 62);
                }),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(icons.length, (index) {
                return GestureDetector(
                  onTap: () => onTap(index),
                  child: Image.asset(icons[index], height: 28),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class ConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.yellow.withValues(alpha: 0.6), Colors.transparent],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path path =
        Path()
          ..moveTo(size.width * 0.4, 0)
          ..lineTo(size.width * 0.6, 0)
          ..lineTo(size.width, size.height * 1.2)
          ..lineTo(0, size.height * 1.2)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
