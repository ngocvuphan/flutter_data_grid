import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DataGridTheme extends InheritedWidget {
  const DataGridTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final DataGridThemeData data;

  static DataGridThemeData of(BuildContext context) {
    final DataGridTheme? dataGridTheme = context.dependOnInheritedWidgetOfExactType<DataGridTheme>();
    return dataGridTheme?.data ?? const DataGridThemeData();
  }

  @override
  bool updateShouldNotify(covariant DataGridTheme oldWidget) => data != oldWidget.data;
}

@immutable
class DataGridThemeData with Diagnosticable {
  const DataGridThemeData({
    this.headingRowHeight,
    this.headingTextStyle,
    this.dataRowHeight,
    this.dataTextStyle,
    this.borderWidth,
    this.borderColor,
    this.horizontalMargin,
    this.resizeIndicatorColor,
    this.resizeIndicatorWidth,
    this.columnEdgeIndicatorColor,
    this.columnEdgeIndicatorIndent,
    this.columnEdgeIndicatorWidth,
    this.minColumnWidth,
  });

  final double? headingRowHeight;
  final TextStyle? headingTextStyle;
  final double? dataRowHeight;
  final TextStyle? dataTextStyle;
  final double? borderWidth;
  final Color? borderColor;
  final double? horizontalMargin;
  final Color? resizeIndicatorColor;
  final double? resizeIndicatorWidth;
  final Color? columnEdgeIndicatorColor;
  final double? columnEdgeIndicatorIndent;
  final double? columnEdgeIndicatorWidth;
  final double? minColumnWidth;

  @override
  int get hashCode => Object.hash(
        headingRowHeight,
        headingTextStyle,
        dataRowHeight,
        dataTextStyle,
        borderWidth,
        borderColor,
        horizontalMargin,
        resizeIndicatorColor,
        resizeIndicatorWidth,
        columnEdgeIndicatorColor,
        columnEdgeIndicatorIndent,
        columnEdgeIndicatorWidth,
        minColumnWidth,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DataGridThemeData &&
        other.headingRowHeight == headingRowHeight &&
        other.headingTextStyle == headingTextStyle &&
        other.dataRowHeight == dataRowHeight &&
        other.dataTextStyle == dataTextStyle &&
        other.borderWidth == borderWidth &&
        other.borderColor == borderColor &&
        other.horizontalMargin == horizontalMargin &&
        other.resizeIndicatorColor == resizeIndicatorColor &&
        other.resizeIndicatorWidth == resizeIndicatorWidth &&
        other.columnEdgeIndicatorColor == columnEdgeIndicatorColor &&
        other.columnEdgeIndicatorIndent == columnEdgeIndicatorIndent &&
        other.columnEdgeIndicatorWidth == columnEdgeIndicatorWidth &&
        other.minColumnWidth == minColumnWidth;
  }
}
