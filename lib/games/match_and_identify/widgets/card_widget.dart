import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final bool revealed;
  final String label;
  final double size;
  final VoidCallback onTap;
  final bool faded;

  const CardWidget({
    super.key,
    required this.revealed,
    required this.label,
    required this.size,
    required this.onTap,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              revealed
                  ? Opacity(
                    opacity: faded ? 0.5 : 1.0,
                    child: Image.asset(label, fit: BoxFit.cover),
                  )
                  : Image.asset('assets/card_back.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}
