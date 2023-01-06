import 'package:flutter/material.dart';

import '../data_grid_border.dart';
import '../helpers/grid_state_manager.dart';
import 'rendering/grid_row.dart';

enum GridRowType { header, data, footer }

class GridRow extends MultiChildRenderObjectWidget {
  GridRow({
    super.key,
    super.children,
    this.type = GridRowType.data,
    required this.stateManager,
    this.skipColumns = 0,
    this.border,
    this.columnEdgeIndicatorIndent = 16.0,
    this.columnEdgeIndicatorWidth = 1.0,
    this.columnEdgeIndicatorColor = Colors.black12,
    this.resizeIndicatorWidth = 2.0,
    this.resizeIndicatorColor = Colors.red,
  });

  final GridRowType type;
  final GridStateManager stateManager;
  final int skipColumns;

  /// Border (verticalInside, horizontalInside=bottom)
  final DataGridBorder? border;
  final double columnEdgeIndicatorIndent;
  final double columnEdgeIndicatorWidth;
  final Color columnEdgeIndicatorColor;
  final double resizeIndicatorWidth;
  final Color resizeIndicatorColor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderGridRow(
      type: type,
      stateManager: stateManager,
      skipColumns: skipColumns,
      border: border,
      columnEdgeIndicatorIndent: columnEdgeIndicatorIndent,
      columnEdgeIndicatorWidth: columnEdgeIndicatorWidth,
      columnEdgeIndicatorColor: columnEdgeIndicatorColor,
      resizeIndicatorWidth: resizeIndicatorWidth,
      resizeIndicatorColor: resizeIndicatorColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    (renderObject as RenderGridRow)
      ..type = type
      ..stateManager = stateManager
      ..skipColumns = skipColumns
      ..border = border
      ..columnEdgeIndicatorIndent = columnEdgeIndicatorIndent
      ..columnEdgeIndicatorWidth = columnEdgeIndicatorWidth
      ..columnEdgeIndicatorColor = columnEdgeIndicatorColor
      ..resizeIndicatorWidth = resizeIndicatorWidth
      ..resizeIndicatorColor = resizeIndicatorColor;
  }
}
