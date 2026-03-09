import 'package:flutter/material.dart';

Widget buildCustomTextField(
  String label, {
  required FocusNode focusNode,
  required TextEditingController controller,
  required TextInputType keyboardType,
  bool obscureText = false, required Function(dynamic value) onChanged,
}) {
  bool showGradient = focusNode.hasFocus || controller.text.isNotEmpty;

  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Colors.purple, Colors.orange]),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            showGradient
                ? TextStyle(
                  fontSize: 18,
                  foreground:
                      Paint()
                        ..shader = const LinearGradient(
                          colors: [Colors.purple, Colors.orange],
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                )
                : const TextStyle(fontSize: 18, color: Colors.white),
        filled: true,
        fillColor: showGradient ? Colors.white : Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent, width: 1),
        ),
      ),
    ),
  );
}
