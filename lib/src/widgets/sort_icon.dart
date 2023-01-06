import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../vph_data_grid.dart';

class SortIcon extends StatefulWidget {
  const SortIcon({
    super.key,
    required this.state,
  });

  final DataGridSortState state;

  @override
  State<SortIcon> createState() => _SortIconState();
}

class _SortIconState extends State<SortIcon> with TickerProviderStateMixin {
  late AnimationController _orientationController;
  late Animation<double> _orientationAnimation;
  double _orientationOffset = 0.0;

  static final Animatable<double> _turnTween = Tween<double>(begin: 0.0, end: math.pi).chain(CurveTween(curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _orientationController = AnimationController(duration: kSortIconAnimationDuration, vsync: this);
    _orientationAnimation = _orientationController.drive(_turnTween)
      ..addListener(_rebuild)
      ..addStatusListener(_resetOrientationAnimation);
    _orientationOffset = widget.state == DataGridSortState.ascending ? 0.0 : math.pi;
  }

  @override
  void didUpdateWidget(covariant SortIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      if (_orientationController.status == AnimationStatus.dismissed) {
        _orientationController.forward();
      } else {
        _orientationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _orientationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.rotationZ(_orientationOffset + _orientationAnimation.value),
      alignment: Alignment.center,
      child: const Icon(Icons.south, size: 16),
    );
  }

  void _rebuild() {
    setState(() {});
  }

  void _resetOrientationAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _orientationOffset += math.pi;
      _orientationController.value = 0.0;
    }
  }
}
