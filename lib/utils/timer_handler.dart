import 'dart:async';

import 'package:flutter/material.dart';

mixin TimerHandler<T extends StatefulWidget> on State<T> {
  late Stopwatch stopwatch;
  Timer? timer;
  int elapsedSeconds = 0;
  bool isPaused = false;
  bool timeFrozen = false;

  void startTimer({required VoidCallback onTick}) {
    stopwatch = Stopwatch()..start();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !timeFrozen && !isPaused) {
        setState(() {
          elapsedSeconds = stopwatch.elapsed.inSeconds;
        });
        onTick();
      }
    });
  }

  void pauseTimer() {
    isPaused = true;
    stopwatch.stop();
  }

  void resumeTimer() {
    isPaused = false;
    stopwatch.start();
  }

  void disposeTimer() {
    stopwatch.stop();
    timer?.cancel();
  }
}
