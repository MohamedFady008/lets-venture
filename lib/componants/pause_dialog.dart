import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PauseDialog {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onResume,
    required VoidCallback onRestart,
    required VoidCallback onHome,
    required String levelLabel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFFFDF0D5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 32,
              horizontal: 24,
            ),
            titlePadding: const EdgeInsets.only(top: 16),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Let’s Adventure".tr,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  levelLabel,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      _buildButton(
                        label: "Resume".tr,
                        icon: Icons.play_arrow,
                        color: Colors.green.shade600,
                        onPressed: () {
                          Navigator.pop(context);
                          onResume();
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildButton(
                        label: "Restart Level".tr,
                        icon: Icons.refresh,
                        color: Colors.orange.shade700,
                        onPressed: () {
                          Navigator.pop(context);
                          onRestart();
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildButton(
                        label: "game_home".tr,
                        icon: Icons.home,
                        color: Colors.redAccent,
                        onPressed: () {
                          Navigator.pop(context);
                          onHome();
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

  static Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 220,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
