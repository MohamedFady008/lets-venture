import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/date/vr_card_data.dart';
import 'package:url_launcher/url_launcher.dart';

class VrDetail extends StatefulWidget {
  final int level;

  const VrDetail({super.key, required this.level});

  @override
  State<VrDetail> createState() => _VrDetailState();
}

class _VrDetailState extends State<VrDetail> with TickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;

  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double parallax(double intensity) => -_scrollOffset * intensity;
  double scaleFactor(double intensity) =>
      1.0 + min(_scrollOffset * intensity, 0.2);

  Future<void> _launchVR() async {
    final url = Uri.parse(urls[widget.level - 1]);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

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
    final index = widget.level - 1;

    final String title = titles[index];
    final String image = imageAssets[index];
    final Color bg = backgroundColors[index];

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Column(
            children: [
              Hero(
                tag: 'card_${title.tr}',
                child: Material(
                  color: bg,
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              image,
                              fit: BoxFit.cover,
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                            ),
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
                              title.tr,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        buildStaggered(
                          delay: 0.7,
                          child: Center(
                            child: ElevatedButton.icon(
                              onPressed: _launchVR,
                              icon: const Icon(Icons.ondemand_video),
                              label: Text("Join the Experience".tr),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 6,
                              ),
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
        ],
      ),
    );
  }
}
