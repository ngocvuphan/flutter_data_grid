import 'package:flutter/material.dart';

@immutable
class DataGridRow {
  /// Creates the configuration for the row of [DataGrid]
  const DataGridRow({required this.children});

  /// The cells of row of [DataGrid]
  final List<Widget> children;
}
