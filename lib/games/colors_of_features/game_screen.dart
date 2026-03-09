import 'dart:math';
import 'package:flutter/material.dart';
import 'models/level.dart';
import 'utils/data_loader.dart';

class GameScreen extends StatelessWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: PixelArtDataLoader.loadFromJson(
        'assets/levels/egypt_$level.json',
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final pixelNumbers = snapshot.data!['pixelNumbers'] as List<int?>;
        final palette = snapshot.data!['palette'] as List<Color>;

        return _GameGrid(
          level: level,
          pixelNumbers: pixelNumbers,
          palette: palette,
        );
      },
    );
  }
}

class _GameGrid extends StatefulWidget {
  final int level;
  final List<int?> pixelNumbers;
  final List<Color> palette;

  const _GameGrid({
    required this.level,
    required this.pixelNumbers,
    required this.palette,
  });

  @override
  State<_GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<_GameGrid> {
  final TransformationController _controller = TransformationController();
  final GlobalKey _gridKey = GlobalKey();

  late List<int> userColors;
  int selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    userColors = List<int>.filled(widget.pixelNumbers.length, -1);
  }

  void _handleDrawing(Offset position) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final size = box.size;
    final gridSize = sqrt(widget.pixelNumbers.length).floor();
    final cellSize = size.width / gridSize;
    final x = (position.dx / cellSize).floor();
    final y = (position.dy / cellSize).floor();
    final index = y * gridSize + x;

    if (index >= 0 &&
        index < widget.pixelNumbers.length &&
        widget.pixelNumbers[index] != null &&
        userColors[index] != selectedColorIndex) {
      setState(() {
        userColors[index] = selectedColorIndex;
      });
    }
  }

  bool _isComplete() {
    for (int i = 0; i < widget.pixelNumbers.length; i++) {
      final target = widget.pixelNumbers[i];
      if (target != null && userColors[i] != target) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = sqrt(widget.pixelNumbers.length).floor();

    return Scaffold(
      appBar: AppBar(
        title: Text(levelList[widget.level].name),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_isComplete()) {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text('Completed!'),
                        content: Text(levelList[widget.level].description),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _controller,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 1,
            maxScale: 20,
            child: GestureDetector(
              onPanDown: (d) => _handleDrawing(d.localPosition),
              onPanUpdate: (d) => _handleDrawing(d.localPosition),
              child: Container(
                key: _gridKey,
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                  ),
                  itemCount: widget.pixelNumbers.length,
                  itemBuilder: (context, index) {
                    final colorIndex = userColors[index];
                    final pixelValue = widget.pixelNumbers[index];
                    if (pixelValue == null) return const SizedBox.shrink();

                    final cellColor =
                        colorIndex >= 0
                            ? widget.palette[colorIndex]
                            : Colors.white;

                    return Container(
                      margin: const EdgeInsets.all(0.25),
                      color: cellColor,
                      child:
                          colorIndex == -1
                              ? Center(
                                child: Text(
                                  '$pixelValue',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                              : null,
                    );
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 4,
                color: Colors.white.withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.palette.length, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedColorIndex = index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$index',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: widget.palette[index],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        selectedColorIndex == index
                                            ? Colors.black
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
