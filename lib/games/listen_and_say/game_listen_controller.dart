import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/games/listen_and_say/game_listen_screen.dart';
import 'package:lets_adventure/main_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lets_adventure/utils/game_progress.dart';
import 'package:lets_adventure/models/game_type.dart';

class GameController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  final stt.SpeechToText speech = stt.SpeechToText();
  final int level;
  late String targetWord;

  final List<String> _targetWords = [
    'اهلا',
    'الاحد',
    'الاثنين',
    'نجمه',
    'ازرق',
    'احمر',
    'اخضر',
    'واحد',
    'اثنين',
    'ثلاثه',
    'اربعه',
    'خمسه',
    'شكرا',
    'مرحبا بك',
    'كيف حالك؟',
    'بخير الحمد لله',
    'مع السلامه',
    'تفاحه',
  ];

  RxBool isListening = false.obs;
  RxString spokenText = ''.obs;
  RxBool isCorrect = false.obs;
  RxBool showWord = false.obs;
  RxInt attemptsCount = 0.obs;
  RxBool isPlaying = false.obs;

  late ConfettiController confettiController;
  late Worker spokenTextWorker;

  GameController(this.level) {
    if (_targetWords.length > level - 1) {
      targetWord = _targetWords[level - 1];
    } else if (_targetWords.isNotEmpty) {
      targetWord = _targetWords.last;
    } else {
      targetWord = "خطأ";
    }
  }

  @override
  void onInit() {
    super.onInit();
    confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    spokenTextWorker = ever(spokenText, (_) => checkAnswer());
    requestMicrophonePermission();
    Future.delayed(
      const Duration(milliseconds: 300),
      () => showWord.value = true,
    );
    Future.delayed(const Duration(milliseconds: 800), playAudio);
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    confettiController.dispose();
    spokenTextWorker.dispose();
    speech.cancel();
    super.onClose();
  }

  Future<void> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      Get.snackbar(
        'Permission Denied',
        'Microphone permission is required for this game',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withValues(alpha: 0.7),
        colorText: Colors.white,
      );
    }
  }

  String normalize(String s) =>
      s
          .replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim()
          .toLowerCase();

  Future<void> playAudio() async {
    try {
      isPlaying.value = true;
      await audioPlayer.play(
        AssetSource('audio/${targetWord.toLowerCase()}.mp3'),
      );
      audioPlayer.onPlayerComplete.first.then((_) {
        isPlaying.value = false;
      });
    } catch (e) {
      isPlaying.value = false;
    }
  }

  void checkAnswer() {
    if (spokenText.value.isNotEmpty) {
      final normalizedSpoken = normalize(spokenText.value);
      final normalizedTarget = normalize(targetWord);

      isCorrect.value =
          normalizedSpoken == normalizedTarget ||
          (normalizedSpoken.contains(normalizedTarget) &&
              (normalizedSpoken.length - normalizedTarget.length).abs() <= 2);

      if (isCorrect.value) {
        stopListening();
        onCorrect();
      } else {
        stopListening();
      }
    }
  }

  Future<void> listen() async {
    if (isListening.value) {
      stopListening();
      return;
    }
    try {
      attemptsCount.value++;
      bool available = await speech.initialize(
        onError:
            (error) => Get.snackbar(
              'Speech Error',
              error.errorMsg,
              backgroundColor: Colors.red.withValues(alpha: 0.7),
              colorText: Colors.white,
            ),
        onStatus: (status) {
          if (status == 'done') isListening.value = false;
        },
      );

      if (available) {
        spokenText.value = '';
        isListening.value = true;
        speech.listen(
          onResult: (val) => spokenText.value = val.recognizedWords,
          localeId: 'ar-EG',
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.confirmation,
            partialResults: true,
          ),
        );
      } else {
        Get.snackbar(
          'Speech Recognition',
          'Speech recognition is not available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Speech Error',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.7),
        colorText: Colors.white,
      );
    }
  }

  void stopListening() {
    if (speech.isListening) {
      speech.stop();
    }
    isListening.value = false;
  }

  Future<void> onCorrect() async {
    final type = GameType.listen;

    int currentStars =
        attemptsCount.value <= 1
            ? 3
            : attemptsCount.value <= 3
            ? 2
            : 1;

    int savedStars = await GameProgress.getStarsForLevel(type, level);
    if (currentStars > savedStars) {
      await GameProgress.setStarsForLevel(type, level, currentStars);
    }

    int highestLevel = await GameProgress.getHighestLevel(type);
    if (level == highestLevel && level < 18) {
      await GameProgress.setHighestLevel(type, level + 1);
    }

    confettiController.play();
    try {
      await audioPlayer.play(AssetSource('audio/success.mp3'));
    } catch (_) {}

    const int maxLevels = 18;
    await Future.delayed(const Duration(milliseconds: 500));

    if (level < maxLevels) {
      Get.defaultDialog(
        title: "!أحسنت",
        middleText: "لقد أكملت المرحلة بنجاح",
        backgroundColor: Colors.deepPurple.shade50,
        titleStyle: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
        middleTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
        contentPadding: const EdgeInsets.all(20),
        titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ماذا تريد أن تفعل الآن؟',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Get.back();
                Get.offAll(
                  () => ListenAndSay(level: level + 1),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                );
              },
              child: const Text(
                'المرحلة التالية',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Get.back();
                Get.offAll(() => MainScaffold());
              },
              child: const Text(
                'الصفحة الرئيسية',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        radius: 15,
        barrierDismissible: false,
      );
    } else {
      Get.defaultDialog(
        title: '🎉 تهانينا',
        middleText: 'لقد أكملت جميع المراحل بنجاح!',
        backgroundColor: Colors.deepPurple.shade50,
        titleStyle: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        middleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18),
        contentPadding: const EdgeInsets.all(20),
        titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'لقد أتممت اللعبة ببراعة',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Get.back();
                Get.offAll(() => MainScaffold());
              },
              child: const Text(
                'الصفحة الرئيسية',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        radius: 15,
        barrierDismissible: false,
      );
    }
  }
}
