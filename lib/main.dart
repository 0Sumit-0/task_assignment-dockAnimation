import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({super.key, required this.items});

  // No longer final, as it will be modified locally
  final List<IconData> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;
  late int? hoveredIndex;
  late double baseItemHeight;
  late double baseTranslationY;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    hoveredIndex = null;
    baseItemHeight = 48.0;
    baseTranslationY = 0.0;
  }

  double getScaledSize(int index) {
    return getPropertyValue(
      index: index,
      baseValue: baseItemHeight,
      maxValue: 70.0,
      nonHoveredMaxValue: 55.0,
    );
  }

  double getTranslationY(int index) {
    return getPropertyValue(
      index: index,
      baseValue: baseTranslationY,
      maxValue: -20.0,
      nonHoveredMaxValue: -8.0,
    );
  }

  double getPropertyValue({
    required int index,
    required double baseValue,
    required double maxValue,
    required double nonHoveredMaxValue,
  }) {
    if (hoveredIndex == null) {
      return baseValue;
    }

    final difference = (hoveredIndex! - index).abs();
    final itemsAffected = _items.length;

    if (difference == 0) {
      return maxValue;
    } else if (difference <= itemsAffected) {
      final ratio = (itemsAffected - difference) / itemsAffected;
      return lerpDouble(baseValue, nonHoveredMaxValue, ratio)!;
    } else {
      return baseValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            _items.length,
                (index) {
              return DragTarget<int>(
                onWillAcceptWithDetails: (data) => true,
                onAcceptWithDetails: (draggedIndex) {
                  setState(() {
                    final draggedItem = _items.removeAt(draggedIndex.data);
                    _items.insert(index, draggedItem);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return MouseRegion(
                    key: ValueKey(_items[index]),
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) {
                      setState(() {
                        hoveredIndex = index;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        hoveredIndex = null;
                      });
                    },
                    child: Draggable<int>(
                      data: index,
                      feedback: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.identity()
                          ..translate(
                            0.0,
                            getTranslationY(index),
                            0.0,
                          ),
                        height: getScaledSize(index),
                        width: getScaledSize(index),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.primaries[index % Colors.primaries.length],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          _items[index],
                          color: Colors.white,
                        ),
                      ),
                      childWhenDragging: const SizedBox.shrink(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.identity()
                          ..translate(
                            0.0,
                            getTranslationY(index),
                            0.0,
                          ),
                        height: getScaledSize(index),
                        width: getScaledSize(index),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.primaries[index % Colors.primaries.length],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          _items[index],
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
