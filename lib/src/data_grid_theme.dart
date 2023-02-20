import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DataGridTheme extends InheritedWidget {
  /// Define the [DataGrid] theme
  const DataGridTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final DataGridThemeData data;

  static DataGridThemeData of(BuildContext context) {
    final DataGridTheme? dataGridTheme =
        context.dependOnInheritedWidgetOfExactType<DataGridTheme>();
    return dataGridTheme?.data ?? const DataGridThemeData();
  }

  @override
  bool updateShouldNotify(covariant DataGridTheme oldWidget) =>
      data != oldWidget.data;
}

@immutable
class DataGridThemeData with Diagnosticable {
  /// Define the [DataGrid] theme data
  const DataGridThemeData({
    this.headingRowHeight,
    this.headingTextStyle,
    this.dataRowHeight,
    this.dataTextStyle,
    this.borderWidth,
    this.borderColor,
    this.horizontalPadding,
    this.resizeIndicatorColor,
    this.resizeIndicatorWidth,
    this.columnEdgeIndicatorColor,
    this.columnEdgeIndicatorIndent,
    this.columnEdgeIndicatorWidth,
    this.minColumnWidth,
  });

  /// Define the heading row height. Default is 56.0
  final double? headingRowHeight;

  /// Define the heading text style. Default is titleSmall
  final TextStyle? headingTextStyle;

  /// Define the data row height. Default is 48.0
  final double? dataRowHeight;

  /// Define the data row text style. Default is bodyMedium
  final TextStyle? dataTextStyle;

  /// Define the border width. Default is 1.0
  final double? borderWidth;

  /// Define the border color. Default is onSurface.withOpacity(0.12)
  final Color? borderColor;

  /// Define the horizontal padding of header and rows. Default is 24.0
  final double? horizontalPadding;

  /// Define the color of resize indicator. Default is primary
  final Color? resizeIndicatorColor;

  /// Define the width of resize indicator. Default is 2.0
  final double? resizeIndicatorWidth;

  /// Define the color of column edge indicator in the case non vertical border. Default is onSurface.withOpacity(0.12)
  final Color? columnEdgeIndicatorColor;

  /// Define the indent of column edge indicator in the case non vertical border. Default is 16.0
  final double? columnEdgeIndicatorIndent;

  /// Define the width of column edge indicator in the case non vertical border. Default is 1.0
  final double? columnEdgeIndicatorWidth;

  /// Define the minimum width of column
  final double? minColumnWidth;

  @override
  int get hashCode => Object.hash(
        headingRowHeight,
        headingTextStyle,
        dataRowHeight,
        dataTextStyle,
        borderWidth,
        borderColor,
        horizontalPadding,
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
        other.horizontalPadding == horizontalPadding &&
        other.resizeIndicatorColor == resizeIndicatorColor &&
        other.resizeIndicatorWidth == resizeIndicatorWidth &&
        other.columnEdgeIndicatorColor == columnEdgeIndicatorColor &&
        other.columnEdgeIndicatorIndent == columnEdgeIndicatorIndent &&
        other.columnEdgeIndicatorWidth == columnEdgeIndicatorWidth &&
        other.minColumnWidth == minColumnWidth;
  }
}
