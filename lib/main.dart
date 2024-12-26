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

enum dimensionDock{
  dockWidth,
  dockHeight
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
  late List<MaterialColor> _colors;
  late int? hoveredIndex;
  late bool hoveredValue;
  late double baseItemHeight;
  late double baseItemWidth;
  late double spacing;
  late double baseDockDiff;
  late double baseTranslationY;
  late bool _isDragging;
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
    _isDragging=false;
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
      maxValue: -10.0,
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

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.black12,
  //       borderRadius: BorderRadius.circular(12.0),
  //     ),
  //     padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
  //     child: IntrinsicHeight(
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: List.generate(
  //           _items.length,
  //               (index) {
  //             return DragTarget<int>(
  //               onWillAcceptWithDetails: (data) => true,
  //               onAcceptWithDetails: (draggedIndex) {
  //                 setState(() {
  //                   final draggedItem = _items.removeAt(draggedIndex.data);
  //                   _items.insert(index, draggedItem);
  //                 });
  //               },
  //               builder: (context, candidateData, rejectedData) {
  //                 return MouseRegion(
  //                   key: ValueKey(_items[index]),
  //                   cursor: SystemMouseCursors.click,
  //                   onEnter: (_) {
  //                     setState(() {
  //                       hoveredIndex = index;
  //                       print(hoveredIndex);
  //                     });
  //                   },
  //                   onExit: (_) {
  //                     setState(() {
  //                       hoveredIndex = null;
  //                       print('end....................');
  //                     });
  //                   },
  //                   child: Draggable<int>(
  //                     data: index,
  //                     onDragStarted: (){
  //
  //                     },
  //                     feedback: _buildAnimatedContainer(index),
  //                     childWhenDragging: const SizedBox.shrink(),
  //                     child: _buildAnimatedContainer(index),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  //

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hoveredValue = true;
          print(hoveredValue.toString()+'//////////////////');
        });
      },
      onExit: (_) {
        setState(() {
          hoveredValue = false;
          hoveredIndex=null;
          print('////////////////////.');
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
                            _isDragging = true;
                            draggedIndex = index;
                          });
                        },
                        feedback: _buildAnimatedContainer(index),

                        childWhenDragging: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: getScaledSize(index),
                          width: getScaledSize(index),
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
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
                        ),
                        onDragCompleted: () {
                          setState(() {
                            _isDragging = false;
                            draggedIndex = null;
                            hoveredIndex = null;
                          });
                        },
                        onDraggableCanceled: (velocity, offset) {
                          setState(() {
                            _isDragging = false;
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
