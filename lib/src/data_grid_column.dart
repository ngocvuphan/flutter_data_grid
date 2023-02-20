import 'package:flutter/material.dart';

@immutable
class DataGridColumn {
  /// Creates the configuration for the a column of [DataGrid]
  const DataGridColumn({
    required this.name,
    this.displayName,
    this.label,
    this.columnWidth = const FlexDataGridColumnWidth(),
    this.alignment = AlignmentDirectional.centerStart,
    this.padding,
    this.resizable = false,
    this.sortable = false,
    this.filterable = false,
    this.isNumber = false,
    this.isDate = false,
  });

  /// The column name. This is required argument
  final String name;

  /// The column display name which is displayed on the header as a [Text] widget
  final String? displayName;

  /// The column label which is displayed on the header
  final Widget? label;

  /// The column width. Default is [FlexDataGridColumnWidth]
  final DataGridColumnWidth columnWidth;

  /// The column alignment. Default is [AlignmentDirectional.centerStart]
  final AlignmentDirectional alignment;

  /// The column padding. Default is defined in [DataGridThemeData.horizontalPadding]
  final EdgeInsetsGeometry? padding;

  /// The column is resizable. Default is false
  final bool resizable;

  /// The column is sortable. Default is false
  final bool sortable;

  /// The column is filterable. Default is false
  final bool filterable;

  /// The column is number data type. Default is false or [String] data type
  final bool isNumber;

  /// The column is [DateTime] data type. Default is false or [String] data type
  final bool isDate;
}

@immutable
class DataGridColumnWidth {
  const DataGridColumnWidth(this.value);
  final double value;
}

class FixedDataGridColumnWidth extends DataGridColumnWidth {
  const FixedDataGridColumnWidth(double width) : super(width);
}

class FlexDataGridColumnWidth extends DataGridColumnWidth {
  const FlexDataGridColumnWidth(
      {double flex = 1.0, this.minWidth = 0.0, this.maxWidth = double.infinity})
      : super(flex);
  final double minWidth;
  final double maxWidth;
}

class IntrinsicDataGridColumnWidth extends DataGridColumnWidth {
  const IntrinsicDataGridColumnWidth(
      {this.minWidth = 0.0, this.maxWidth = double.infinity})
      : super(minWidth);
  final double minWidth;
  final double maxWidth;
}
