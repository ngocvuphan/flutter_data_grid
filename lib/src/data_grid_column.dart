import 'package:flutter/material.dart';

@immutable
class DataGridColumn {
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

  final String name;
  final String? displayName;
  final Widget? label;
  final DataGridColumnWidth columnWidth;
  final AlignmentDirectional alignment;
  final EdgeInsetsGeometry? padding;
  final bool resizable;
  final bool sortable;
  final bool filterable;
  final bool isNumber;
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
  const FlexDataGridColumnWidth({double flex = 1.0, this.minWidth = 0.0, this.maxWidth = double.infinity}) : super(flex);
  final double minWidth;
  final double maxWidth;
}

class IntrinsicDataGridColumnWidth extends DataGridColumnWidth {
  const IntrinsicDataGridColumnWidth({this.minWidth = 0.0, this.maxWidth = double.infinity}) : super(minWidth);
  final double minWidth;
  final double maxWidth;
}
