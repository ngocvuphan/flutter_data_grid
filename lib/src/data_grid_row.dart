import 'package:flutter/material.dart';

@immutable
class DataGridRow {
  const DataGridRow({required this.children});

  final List<Widget> children;
}
