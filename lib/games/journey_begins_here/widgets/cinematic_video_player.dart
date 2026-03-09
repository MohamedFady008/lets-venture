import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CinematicVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const CinematicVideoPlayer({super.key, required this.controller});

  @override
  State<CinematicVideoPlayer> createState() => _CinematicVideoPlayerState();
}

class _CinematicVideoPlayerState extends State<CinematicVideoPlayer> {
  bool _showOverlay = false;
  bool _muted = true;
  bool _playing = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.setVolume(0);
    _playing = widget.controller.value.isPlaying;
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = true);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showOverlay = false);
    });
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    widget.controller.setVolume(_muted ? 0 : 1);
  }

  void _togglePlayPause() {
    setState(() => _playing = !_playing);
    _playing ? widget.controller.play() : widget.controller.pause();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(position.inMinutes.remainder(60));
    final seconds = twoDigits(position.inSeconds.remainder(60));
    return "${twoDigits(position.inHours)}:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.controller;

    return GestureDetector(
      onTap: () {
        _togglePlayPause();
        _toggleOverlay();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child:
                  video.value.isInitialized
                      ? AspectRatio(
                        aspectRatio: video.value.aspectRatio,
                        child: VideoPlayer(video),
                      )
                      : const Center(child: CircularProgressIndicator()),
            ),
            if (video.value.isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showOverlay ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black45,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            VideoProgressIndicator(
                              video,
                              allowScrubbing: true,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              colors: VideoProgressColors(
                                playedColor: Colors.amber,
                                backgroundColor: Colors.white30,
                                bufferedColor: Colors.white60,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(video.value.position),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _muted
                                            ? Icons.volume_off
                                            : Icons.volume_up,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        _toggleMute();
                                        _toggleOverlay();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _playing
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        _togglePlayPause();
                                        _toggleOverlay();
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  _formatDuration(video.value.duration),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
}
