import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/componants/progressheader.dart';
import 'package:lets_adventure/componants/generic_level_card.dart';
import 'package:lets_adventure/date/vr_card_data.dart';
import 'package:lets_adventure/models/game_type.dart';
import 'package:lets_adventure/utils/game_progress.dart';
import 'package:lets_adventure/componants/card.dart';

class GameLevelSelector extends StatefulWidget {
  final String title;
  final GameType gameType;
  final int maxLevels;
  final ImageProvider backgroundImage;

  const GameLevelSelector({
    super.key,
    required this.title,
    required this.gameType,
    this.maxLevels = 18,
    this.backgroundImage = const AssetImage('assets/settings_back.png'),
  });

  @override
  State<GameLevelSelector> createState() => _GameLevelSelectorState();
}

class _GameLevelSelectorState extends State<GameLevelSelector> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  bool _isLoading = true;
  double _lastOffset = 0;
  double _scrollDirection = 1;
  int highestLevel = 1;
  Map<int, int> levelStars = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _detectScrollDirection();
      _onScrollStart();
      _onScrollEnd();
    });
    _loadProgress();
  }

  @override
  void didUpdateWidget(covariant GameLevelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameType != widget.gameType) {
      _loadProgress();
    }
  }

  void _detectScrollDirection() {
    final current = _scrollController.offset;
    _scrollDirection = current > _lastOffset ? 1 : -1;
    _lastOffset = current;
  }

  void _onScrollStart() {
    if (!_isScrolling) {
      setState(() => _isScrolling = true);
    }
  }

  void _onScrollEnd() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && !_scrollController.position.isScrollingNotifier.value) {
        setState(() => _isScrolling = false);
      }
    });
  }

  Future<void> _loadProgress() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // تحميل البيانات بشكل متوازي لتحسين الأداء
      final futures = await Future.wait([
        GameProgress.loadAllStars(widget.gameType, maxLevel: widget.maxLevels),
        widget.gameType == GameType.vr
            ? Future.value(titles.length)
            : GameProgress.getHighestLevel(widget.gameType),
      ]);

      if (!mounted) return;

      setState(() {
        levelStars = futures[0] as Map<int, int>;
        highestLevel = futures[1] as int;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          levelStars = {for (int i = 1; i <= widget.maxLevels; i++) i: 0};
          highestLevel = 1;
          _isLoading = false;
        });
      }
    }
  }

  // دالة لإعادة تحميل البيانات عند الحاجة
  Future<void> _refreshData() async {
    await GameProgress.syncAllData();
    await _loadProgress();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = Get.height;

    if (_isLoading) {
      return _buildLoadingScreen();
    }

    final progress =
        widget.maxLevels > 0 ? highestLevel / widget.maxLevels : 0.0;
    final totalStars = levelStars.values.fold(0, (a, b) => a + b);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image(image: widget.backgroundImage, fit: BoxFit.cover),
            ),
            ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: widget.maxLevels + 1,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, child) {
                    double offset = 0;
                    if (_scrollController.hasClients) {
                      final itemOffset = index * 150.0;
                      final scrollOffset = _scrollController.offset;
                      offset = (itemOffset -
                              scrollOffset -
                              screenHeight / 2 +
                              50)
                          .clamp(-300.0, 300.0);
                    }

                    final angle = offset / 300 * pi / 6;
                    final rotation =
                        _isScrolling ? angle * _scrollDirection : 0.0;

                    return Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.002)
                            ..rotateX(rotation),
                      child:
                          index == 0
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  widget.gameType != GameType.vr
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      )
                                      : const SizedBox.shrink(),
                                  ProgressHeader(
                                    title: widget.title.tr,
                                    progress: progress,
                                    stars: totalStars,
                                    highestLevel: highestLevel,
                                    maxLevels: widget.maxLevels,
                                  ),
                                ],
                              )
                              : widget.gameType == GameType.vr
                              ? CardItem(
                                index: index - 1,
                                title: titles[index - 1].tr,
                                description: descriptions[index - 1].tr,
                                backgroundColor: backgroundColors[index - 1],
                                imageAsset: imageAssets[index - 1],
                                url: urls[index - 1],
                                gameType: widget.gameType,
                                onCompleted: _loadProgress,
                              )
                              : GenericLevelCard(
                                index: index - 1,
                                gameType: widget.gameType,
                                highestLevel: highestLevel,
                                levelStars: levelStars,
                                isScrolling: _isScrolling,
                                scrollOffset: _scrollController.offset,
                                scrollDirection: _scrollDirection,
                                screenHeight: screenHeight,
                                onCompleted: _loadProgress,
                                backgroundImageAsset:
                                    'assets/card_background_1040.png',
                              ),
                    );
                  },
                );
              },
            ),
            // إضافة مؤشر للتحديث
            if (_isLoading)
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 16,
                        children: [
                          const CircularProgressIndicator(),
                          Text('Loading progress...'.tr),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image(image: widget.backgroundImage, fit: BoxFit.cover),
          ),
          Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    const CircularProgressIndicator(),
                    Text(
                      'Loading game progress...'.tr,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
