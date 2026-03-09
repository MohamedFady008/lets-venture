import 'dart:convert';
import 'package:flutter/services.dart';

class PixelArtDataLoader {
  static Future<Map<String, dynamic>> loadFromJson(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);

    List<int?> pixelNumbers = List<int?>.from(
      decoded['pixelNumbers'].map((e) => e == null ? null : e as int),
    );

    List<Color> palette =
        List<int>.from(decoded['palette']).map((argb) => Color(argb)).toList();

    return {'pixelNumbers': pixelNumbers, 'palette': palette};
  }
}
