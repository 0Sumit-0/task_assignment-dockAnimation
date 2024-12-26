import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



enum dimensionDock{
  dockWidth,
  dockHeight
}


class Dock extends StatefulWidget {
  const Dock({super.key, required this.items});

  final List<IconData> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;
  late List<MaterialColor> _colors;
  late int? hoveredIndex;
  late bool hoveredValue;
  late double baseItemHeight;
  late double baseItemWidth;
  late double spacing;
  late double baseDockDiff;
  late double baseTranslationY;
  late int? draggedIndex;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _colors= List.from(Colors.primaries);
    hoveredIndex = null;
    hoveredValue=false;
    baseItemHeight = 48.0;
    baseItemWidth = 55.0;
    baseDockDiff= 15;
    spacing = 12;
    baseTranslationY = 0.0;
    draggedIndex=null;
  }



  double getDockScaledSize(dimensionDock value) {
    if (hoveredIndex == null) {
      if (value==dimensionDock.dockWidth) {
        return baseItemWidth+10;
      }else{
        return baseItemHeight+10;
      }

    }

    double height=baseItemHeight+baseDockDiff+10;
    double width=(_items.length * (baseItemWidth+10)) + ((_items.length - 1) * spacing)+ baseDockDiff;

    if (value==dimensionDock.dockWidth) {
      return width;
    }else{
      return height;
    }

  }


  double getScaledSize(int index) {
    return getPropertyValue(
      index: index,
      baseValue: baseItemHeight,
      maxValue: 55.0,
      nonHoveredMaxValue: 50.0,
    );
  }

  double getTranslationY(int index) {
    return getPropertyValue(
      index: index,
      baseValue: baseTranslationY,
      maxValue: -11.0,
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

  double getShiftOffset(int currentIndex) {
    if (draggedIndex == null || hoveredIndex == null) return 0;

    if (draggedIndex! < hoveredIndex!) {
      // Dragging forward
      if (currentIndex > draggedIndex! && currentIndex <= hoveredIndex!) {
        return -getScaledSize(currentIndex);
      }
    } else if (draggedIndex! > hoveredIndex!) {
      // Dragging backward
      if (currentIndex < draggedIndex! && currentIndex >= hoveredIndex!) {
        return getScaledSize(currentIndex);
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hoveredValue = true;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredValue = false;
          hoveredIndex=null;

        });
      },
      child: Container(
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
                  onWillAcceptWithDetails: (droppedItem) {
                    final draggedIndex = droppedItem.data;
                    setState(() {
                      hoveredIndex = index;
                      this.draggedIndex = draggedIndex;
                    });
                    return true;
                  },
                  onLeave: (_) {
                    setState(() {
                      hoveredIndex = null;
                      draggedIndex = null;
                    });
                  },
                  onAcceptWithDetails: (draggedIndex) {
                    setState(() {
                      final draggedItem = _items.removeAt(draggedIndex.data);
                      final indexColor = _colors.removeAt(draggedIndex.data);
                      _items.insert(index, draggedItem);
                      _colors.insert(index, indexColor);
                      this.draggedIndex = null;
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
                          if (!hoveredValue) {
                            hoveredIndex = null;
                          }
                        });
                      },
                      child: Draggable<int>(
                        data: index,
                        onDragStarted: () {
                          setState(() {
                            draggedIndex = index;
                          });
                        },
                        feedback: _buildAnimatedContainer(index),
                        childWhenDragging: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.slowMiddle,
                          height: hoveredValue?getScaledSize(index):getScaledSize(index)-baseDockDiff-30,
                          width: hoveredValue?getScaledSize(index):getScaledSize(index)-baseDockDiff-30,
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: _buildAnimatedContainer(index),
                        onDragCompleted: () {
                          setState(() {
                            draggedIndex = null;
                            hoveredIndex = null;
                          });
                        },
                        onDraggableCanceled: (velocity, offset) {
                          setState(() {
                            draggedIndex = null;
                            hoveredIndex = null;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildAnimatedContainer(int index) {

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.fastEaseInToSlowEaseOut,
      transform: Matrix4.identity()
        ..translate(
          getShiftOffset(index),
          getTranslationY(index),
          0.0,
        ),
      height: getScaledSize(index),
      width: getScaledSize(index),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: _colors[index % _colors.length],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(
        _items[index],
        color: Colors.white,
      ),
    );
  }

}
