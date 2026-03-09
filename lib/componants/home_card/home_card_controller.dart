import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/models/game_type.dart';
import 'package:lets_adventure/screens/level_selector.dart';
import 'package:lets_adventure/utils/game_progress.dart';

class HomeCardsController extends GetxController {
  final PageController pageController = PageController(viewportFraction: 0.8);
  final RxDouble currentPage = 0.0.obs;
  Timer? _searchDebounce;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<GameType, double> progressMap = <GameType, double>{}.obs;

  List<Map<String, dynamic>> get cards => [
    {
      "title": "homeCard1".tr,
      "progress": progressMap[GameType.journey] ?? 0.0,
      "files": 1,
      "description": "homeDescCard1".tr,
      "color": const Color(0xFF3BC0C3),
      "image": 'assets/journey_begins_here.png',
      "screen": GameLevelSelector(
        title: "homeCard1".tr,
        gameType: GameType.journey,
        maxLevels: 1,
      ),
    },
    {
      "title": "homeCard2".tr,
      "progress": progressMap[GameType.listen] ?? 0.0,
      "files": 18,
      "description": "homeDescCard2".tr,
      "color": const Color(0xFFFFA726),
      "image": 'assets/listen_and_say.png',
      "screen": GameLevelSelector(
        title: "homeCard2".tr,
        gameType: GameType.listen,
        maxLevels: 18,
      ),
    },
    {
      "title": "homeCard3".tr,
      "progress": progressMap[GameType.match] ?? 0.0,
      "files": 18,
      "description": "homeDescCard3".tr,
      "color": const Color(0xFF42A5F5),
      "image": 'assets/match_and_identify.png',
      "screen": GameLevelSelector(
        title: "homeCard3".tr,
        gameType: GameType.match,
        maxLevels: 18,
      ),
    },
    {
      "title": "homeCard4".tr,
      "progress": progressMap[GameType.puzzle] ?? 0.0,
      "files": 2,
      "description": "homeDescCard4".tr,
      "color": const Color(0xFF3BC0C3),
      "image": 'assets/puzzle_and_challenge.png',
      "screen": GameLevelSelector(
        title: "homeCard4".tr,
        gameType: GameType.puzzle,
        maxLevels: 2,
      ),
    },
    {
      "title": "homeCard5".tr,
      "progress": progressMap[GameType.colors] ?? 0.0,
      "files": 1,
      "description": "homeDescCard5".tr,
      "color": const Color(0xFFFFA726),
      "image": 'assets/colors_of_features.png',
      "screen": GameLevelSelector(
        title: "homeCard5".tr,
        gameType: GameType.colors,
        maxLevels: 1,
      ),
    },
  ];

  final RxList<Map<String, dynamic>> filteredCards =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(_onPageChanged);
    _updateFilteredCards();
    fetchAllProgress();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.onClose();
  }

  void _onPageChanged() {
    currentPage.value = pageController.page ?? 0.0;
  }

  void _updateFilteredCards() {
    filteredCards.value = cards;
  }

  // إضافة دالة لتحديث المحتوى عند تغيير اللغة
  void refreshContent() {
    _updateFilteredCards();
  }

  void search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        filteredCards.value = cards;
      } else {
        final searchLower = query.toLowerCase();
        filteredCards.value =
            cards.where((card) {
              return card['title'].toLowerCase().contains(searchLower) ||
                  card['description'].toLowerCase().contains(searchLower);
            }).toList();
      }

      if (filteredCards.isNotEmpty) {
        pageController.jumpToPage(0);
      }
    });
  }

  Future<void> fetchAllProgress() async {
    isLoading.value = true;
    error.value = '';
    try {
      for (final card in cards) {
        final GameType type = card['screen'].gameType;
        final int maxLevels = card['screen'].maxLevels;
        final starsMap = await GameProgress.loadAllStars(type, maxLevel: maxLevels);
        final totalStars = starsMap.values.fold<int>(0, (a, b) => a + b);
        final maxStars = maxLevels * 3; // assuming 3 stars per level
        progressMap[type] = maxStars == 0 ? 0 : totalStars / maxStars;
      }
      _updateFilteredCards();
    } catch (e) {
      error.value = 'Failed to load progress';
    } finally {
      isLoading.value = false;
    }
  }
}
