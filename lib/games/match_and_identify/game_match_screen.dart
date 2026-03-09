import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lets_adventure/componants/pause_dialog.dart';
import 'package:lets_adventure/componants/game_scaffold.dart';
import 'package:lets_adventure/screens/level_selector.dart';
import 'package:lets_adventure/utils/page_transitions.dart';
import 'package:lets_adventure/utils/timer_handler.dart';
import 'package:lets_adventure/utils/game_progress.dart';
import 'package:lets_adventure/models/game_type.dart' as types;
import 'package:lets_adventure/games/match_and_identify/widgets/card_widget.dart';
import 'package:lets_adventure/screens/level_complete_screen.dart';

class MatchGameScreen extends StatefulWidget {
  final int level;
  const MatchGameScreen({super.key, required this.level});

  @override
  State<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends State<MatchGameScreen>
    with TimerHandler<MatchGameScreen> {
  late List<String> cards;
  late List<bool> revealed;
  late List<bool> hinted;
  int? firstSelectedIndex;
  bool wait = false;
  final AudioPlayer _player = AudioPlayer();

  int revealPowerUps = 0;
  int freezePowerUps = 0;
  Timer? freezeTimer;
  bool _dataLoaded = false;
  final _pendingSaves = <Future<void>>[];

  List<String> imageAssets = List.generate(
    18,
    (i) => 'assets/match${i + 1}.png',
  );

  int get gridSize =>
      widget.level <= 5
          ? 2
          : widget.level <= 12
          ? 4
          : 6;

  int get totalCards => gridSize * gridSize;
  bool get isBossLevel => widget.level > 12;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() async {
    prepareCards();
    revealed = List.generate(totalCards, (_) => true);
    hinted = List.generate(totalCards, (_) => false);
    setState(() {});

    await Future.delayed(const Duration(seconds: 2));
    setState(() => revealed = List.generate(totalCards, (_) => false));

    startTimer(onTick: () {});
    _player.setReleaseMode(ReleaseMode.loop);
    _player.play(AssetSource('sounds/background.mp3'));
    await setupPowerUps();
  }

  Future<void> setupPowerUps() async {
    if (_dataLoaded) return;

    final powerUpsLoaded = Future.wait([
      GameProgress.getRevealPowerUps(),
      GameProgress.getFreezePowerUps(),
    ]);

    final results = await powerUpsLoaded;
    revealPowerUps = results[0];
    freezePowerUps = results[1];
    _dataLoaded = true;

    setState(() {});
  }

  void prepareCards() {
    List<String> items = imageAssets.take(totalCards ~/ 2).toList();
    cards = [...items, ...items]..shuffle(Random());
  }

  void onCardTap(int index) {
    if (wait || revealed[index] || isPaused) return;
    setState(() {
      revealed[index] = true;
      hinted[index] = false;
    });

    if (firstSelectedIndex == null) {
      firstSelectedIndex = index;
    } else if (cards[firstSelectedIndex!] == cards[index]) {
      firstSelectedIndex = null;
      checkLevelComplete();
    } else {
      wait = true;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          revealed[firstSelectedIndex!] = false;
          revealed[index] = false;
          firstSelectedIndex = null;
          wait = false;
        });
      });
    }
  }

  Future<void> _saveLevelData(int stars) async {
    final type = types.GameType.match;
    final futures = <Future<void>>[];
    final updatedReveal =
        revealPowerUps + (isBossLevel ? 3 : (stars == 3 ? 1 : 0));
    final updatedFreeze =
        freezePowerUps + (isBossLevel ? 3 : (stars == 3 ? 1 : 0));

    futures.add(GameProgress.setRevealPowerUps(updatedReveal));
    futures.add(GameProgress.setFreezePowerUps(updatedFreeze));

    final highestFuture = GameProgress.getHighestLevel(type);
    final highest = await highestFuture;

    if (widget.level == highest && widget.level < 18) {
      futures.add(GameProgress.setHighestLevel(type, widget.level + 1));
    }

    final starsFuture = GameProgress.getStarsForLevel(type, widget.level);
    final previous = await starsFuture;

    if (stars > previous) {
      futures.add(GameProgress.setStarsForLevel(type, widget.level, stars));
    }

    await Future.wait(futures);
  }

  void checkLevelComplete() async {
    if (revealed.every((e) => e)) {
      pauseTimer();
      _player.stop();

      int stars = calculateStars(elapsedSeconds);

      final saveDataFuture = _saveLevelData(stars);
      _pendingSaves.add(saveDataFuture);

      setState(() {
        revealPowerUps += isBossLevel ? 3 : (stars == 3 ? 1 : 0);
        freezePowerUps += isBossLevel ? 3 : (stars == 3 ? 1 : 0);
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          FadeRoute(
            page: LevelCompleteScreen(
              level: widget.level,
              stars: stars,
              gameType: types.GameType.match,
            ),
          ),
        );
      });
    }
  }

  int calculateStars(int seconds) =>
      seconds <= 30
          ? 3
          : seconds <= 60
          ? 2
          : 1;

  void useRevealPowerUp() {
    if (revealPowerUps <= 0) return;
    setState(() => revealPowerUps--);

    final saveFuture = GameProgress.setRevealPowerUps(revealPowerUps);
    _pendingSaves.add(saveFuture);

    flashRevealHint();
  }

  void flashRevealHint() async {
    List<int> hidden = [
      for (int i = 0; i < revealed.length; i++)
        if (!revealed[i] && !hinted[i]) i,
    ]..shuffle();

    if (hidden.isEmpty) return;

    final hintCount = min(3, hidden.length);
    List<int> hintNow = hidden.take(hintCount).toList();

    setState(() => hintNow.forEach((i) => hinted[i] = true));
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => hintNow.forEach((i) => hinted[i] = true));
  }

  void useFreezePowerUp() {
    if (freezePowerUps <= 0 || timeFrozen) return;
    setState(() {
      freezePowerUps--;
      timeFrozen = true;
    });

    final saveFuture = GameProgress.setFreezePowerUps(freezePowerUps);
    _pendingSaves.add(saveFuture);

    freezeTimer?.cancel();
    freezeTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => timeFrozen = false);
    });
  }

  void pauseGame() {
    pauseTimer();
    PauseDialog.show(
      context: context,
      levelLabel: "level".tr.replaceAll('@number', widget.level.toString()),
      onResume: resumeTimer,
      onRestart: () {
        Navigator.pushReplacement(
          context,
          FadeRoute(page: MatchGameScreen(level: widget.level)),
        );
      },
      onHome: () {
        Navigator.pushReplacement(
          context,
          FadeRoute(
            page: GameLevelSelector(
              title: "homeCard3".tr,
              gameType: types.GameType.match,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    disposeTimer();
    freezeTimer?.cancel();
    _player.dispose();

    Future.wait(_pendingSaves).then((_) => null);

    super.dispose();
  }

  Widget powerUpButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.5 - 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? color : Colors.grey,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardSize = Get.width / gridSize - 12;

    return GameScaffold(
      title: '',
      onPause: pauseGame,
      background: const Image(
        image: AssetImage("assets/match_back.png"),
        fit: BoxFit.cover,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "game_time".tr.replaceAll('@time', elapsedSeconds.toString()),
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: totalCards,
              itemBuilder: (context, index) {
                return CardWidget(
                  revealed: revealed[index] || hinted[index],
                  label: cards[index],
                  size: cardSize,
                  onTap: () => onCardTap(index),
                  faded: hinted[index] && !revealed[index],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              powerUpButton(
                icon: Icons.visibility,
                label: "game_reveal".tr.replaceAll(
                  '@count',
                  revealPowerUps.toString(),
                ),
                color: Colors.amber,
                onPressed: useRevealPowerUp,
                enabled: revealPowerUps > 0,
              ),
              const SizedBox(width: 20),
              powerUpButton(
                icon: Icons.ac_unit,
                label: "game_freeze".tr.replaceAll(
                  '@count',
                  freezePowerUps.toString(),
                ),
                color: Colors.lightBlue,
                onPressed: useFreezePowerUp,
                enabled: freezePowerUps > 0,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
