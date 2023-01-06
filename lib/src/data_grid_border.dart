import 'package:flutter/material.dart';

enum DataGridBorderStyle {
  none,
  all,
  outside,
  inside,
  horizontal,
  vertical,
  outsideAndHorizontal,
}

@immutable
class DataGridBorder {
  const DataGridBorder({
    this.top = BorderSide.none,
    this.right = BorderSide.none,
    this.bottom = BorderSide.none,
    this.left = BorderSide.none,
    this.horizontalInside = BorderSide.none,
    this.verticalInside = BorderSide.none,
  });

  factory DataGridBorder.withStyle(
      {required DataGridBorderStyle style, required BorderSide borderSide}) {
    switch (style) {
      case DataGridBorderStyle.none:
        return const DataGridBorder();
      case DataGridBorderStyle.all:
        return DataGridBorder(
            top: borderSide,
            right: borderSide,
            bottom: borderSide,
            left: borderSide,
            horizontalInside: borderSide,
            verticalInside: borderSide);
      case DataGridBorderStyle.outside:
        return DataGridBorder(
            top: borderSide,
            right: borderSide,
            bottom: borderSide,
            left: borderSide);
      case DataGridBorderStyle.inside:
        return DataGridBorder(
            horizontalInside: borderSide, verticalInside: borderSide);
      case DataGridBorderStyle.horizontal:
        return DataGridBorder(horizontalInside: borderSide);
      case DataGridBorderStyle.vertical:
        return DataGridBorder(verticalInside: borderSide);
      case DataGridBorderStyle.outsideAndHorizontal:
        return DataGridBorder(
            top: borderSide,
            right: borderSide,
            bottom: borderSide,
            left: borderSide,
            horizontalInside: borderSide);
    }
  }

  final BorderSide top;
  final BorderSide right;
  final BorderSide bottom;
  final BorderSide left;
  final BorderSide horizontalInside;
  final BorderSide verticalInside;

  DataGridBorder copyWith({
    BorderSide? top,
    BorderSide? right,
    BorderSide? bottom,
    BorderSide? left,
    BorderSide? horizontalInside,
    BorderSide? verticalInside,
  }) {
    return DataGridBorder(
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
      horizontalInside: horizontalInside ?? this.horizontalInside,
      verticalInside: verticalInside ?? this.verticalInside,
    );
  }
}
