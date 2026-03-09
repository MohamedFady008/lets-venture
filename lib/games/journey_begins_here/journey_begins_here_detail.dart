import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lets_adventure/games/journey_begins_here/models/animal_model.dart';
import 'package:lets_adventure/games/journey_begins_here/widgets/cinematic_video_player.dart';
import 'package:video_player/video_player.dart';

class JourneyBeginsHereDetail extends StatefulWidget {
  final int level;

  const JourneyBeginsHereDetail({super.key, required this.level});

  @override
  State<JourneyBeginsHereDetail> createState() =>
      _JourneyBeginsHereDetailState();
}

class _JourneyBeginsHereDetailState extends State<JourneyBeginsHereDetail>
    with TickerProviderStateMixin {
  late Animal animal;
  late AnimationController _controller;
  late ScrollController _scrollController;
  late VideoPlayerController _videoController;

  int _currentVideoIndex = 0;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    animal = animals[widget.level - 1];

    _scrollController =
        ScrollController()..addListener(() {
          setState(() {
            _scrollOffset = _scrollController.offset;
          });
        });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _loadVideo();
    _controller.forward();
  }

  void _loadVideo() {
    final url = animal.videoUrls[_currentVideoIndex];
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(url))
          ..setLooping(true)
          ..setVolume(0)
          ..initialize().then((_) {
            setState(() {});
            _videoController.play();
          });
  }

  void _changeVideo(int direction) {
    final nextIndex = _currentVideoIndex + direction;
    if (nextIndex >= 0 && nextIndex < animal.videoUrls.length) {
      _videoController.pause();
      _videoController.dispose();
      setState(() => _currentVideoIndex = nextIndex);
      _loadVideo();
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double parallax(double intensity) => -_scrollOffset * intensity;
  double scaleFactor(double intensity) =>
      1.0 + min(_scrollOffset * intensity, 0.2);

  Widget buildStaggered({
    required double delay,
    required Widget child,
    Offset beginOffset = const Offset(0, 0.2),
  }) {
    final animation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, delay + 0.3, curve: Curves.easeOutBack),
      ),
    );

    final fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, delay + 0.3, curve: Curves.easeIn),
    );

    return SlideTransition(
      position: animation,
      child: FadeTransition(opacity: fade, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fact = animal.facts[_currentVideoIndex];

    return Scaffold(
      backgroundColor: animal.color,
      body: Stack(
        children: [
          Column(
            children: [
              Hero(
                tag: 'card_${animal.name}',
                child: Material(
                  color: animal.color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(0, parallax(0.3)),
                        child: Transform.scale(
                          scale: scaleFactor(0.001),
                          child: CinematicVideoPlayer(
                            controller: _videoController,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildStaggered(
                          delay: 0.1,
                          child: Transform.translate(
                            offset: Offset(0, parallax(0.15)),
                            child: Text(
                              animal.name,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildStaggered(
                          delay: 0.3,
                          child: Transform.translate(
                            offset: Offset(0, parallax(0.1)),
                            child: Text(
                              fact,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        buildStaggered(
                          delay: 0.5,
                          child: Transform.translate(
                            offset: Offset(0, parallax(0.08)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    "Lifespan",
                                    animal.lifespan,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildStatCard("Speed", animal.speed),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                _controller.reverse().then((_) => Navigator.pop(context));
              },
            ),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentVideoIndex > 0)
            _circleButton(
              Icons.arrow_back,
              () => _changeVideo(-1),
              Colors.white,
              Colors.black87,
            )
          else
            const SizedBox(width: 140),
          _currentVideoIndex < animal.videoUrls.length - 1
              ? _circleButton(
                Icons.arrow_forward,
                () => _changeVideo(1),
                Colors.black87,
                Colors.white,
              )
              : _circleButton(
                Icons.check,
                () => Navigator.pop(context),
                Colors.green.shade600,
                Colors.white,
              ),
        ],
      ),
    );
  }

  Widget _circleButton(
    IconData icon,
    VoidCallback onPressed,
    Color bgColor,
    Color fgColor,
  ) {
    return SizedBox(
      height: 60,
      width: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 6,
        ),
        child: Icon(icon),
      ),
    );
  }
}
