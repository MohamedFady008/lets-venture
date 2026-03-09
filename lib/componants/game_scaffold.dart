import 'package:flutter/material.dart';

class GameScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onPause;
  final Widget background;
  final Widget child;
  final Color? appBarForegroundColor;

  const GameScaffold({
    super.key,
    required this.title,
    required this.onPause,
    required this.background,
    required this.child,
    this.appBarForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: appBarForegroundColor ?? Colors.white,
        leading: IconButton(icon: const Icon(Icons.pause), onPressed: onPause),
      ),
      body: Stack(
        children: [Positioned.fill(child: background), SafeArea(child: child)],
      ),
    );
  }
}
