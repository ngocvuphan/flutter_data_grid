import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data_grid_column.dart';

enum GridState {
  none,
  columnResizeStart,
  columnResizing,
  columnResizeEnd,
  columnWidthsUpdated,
}

@immutable
class GridStateEventArg {
  const GridStateEventArg({this.resizingColumn = -1});

  final int resizingColumn;
}

class GridStateManager extends ChangeNotifier {
  GridStateManager({
    required this.columns,
  }) : _columnWidths = List<double>.filled(columns.length, 0);

  GridState get state => _state;
  GridState _state = GridState.none;

  double _minColumnWidth = 64;

  final List<DataGridColumn> columns;
  bool isIntrinsicWidthColumn(int index) => columns[index].columnWidth is IntrinsicDataGridColumnWidth;

  bool get hasResizableColumn => columns.any((c) => c.resizable);
  bool columnResizable(index) => columns[index].resizable;

  final List<double> _columnWidths;
  double _maxWidth = double.infinity;
  double get gridWidth => math.min(_maxWidth, _columnWidths.fold(0.0, (p, v) => p + v));

  double getColumnWidth(int index) => index < _columnWidths.length ? _columnWidths[index] : _minColumnWidth;

  int get resizingColumn => _resizingColumn;
  int _resizingColumn = -1;

  void setConfiguration({BoxConstraints? constraints, double? minColumnWidth}) {
    if (constraints != null) {
      _maxWidth = constraints.maxWidth;
    }
    if (_maxWidth < double.infinity) {
      computeColumnWidths();
    }
    if (minColumnWidth != null) {
      _minColumnWidth = minColumnWidth;
    }
  }

  void computeColumnWidths({List<Map<int, double>>? intrinsicWidths}) {
    //print("GridStateManager.computeColumnWidths($intrinsicWidths)");
    double totalFlex = 0, allocatedWidth = 0;
    for (int x = 0; x < columns.length; x++) {
      final column = columns[x];
      if (column.columnWidth is FixedDataGridColumnWidth) {
        allocatedWidth += _columnWidths[x] = _columnWidths[x] > _minColumnWidth ? _columnWidths[x] : column.columnWidth.value;
      } else if (column.columnWidth is FlexDataGridColumnWidth) {
        totalFlex += column.columnWidth.value;
      } else if (column.columnWidth is IntrinsicDataGridColumnWidth) {
        final columnWidth = column.columnWidth as IntrinsicDataGridColumnWidth;
        double width = intrinsicWidths == null ? math.max(columnWidth.minWidth, _columnWidths[x]) : intrinsicWidths.map((e) => e[x] ?? 0.0).reduce(math.max);
        if (width < columnWidth.minWidth) {
          width = columnWidth.minWidth;
        } else if (width > columnWidth.maxWidth) {
          width = columnWidth.maxWidth;
        }
        allocatedWidth += _columnWidths[x] = width;
      }
    }
    if (totalFlex > 0) {
      final widthPerFlex = math.max((_maxWidth - allocatedWidth) / totalFlex, _minColumnWidth);
      for (int x = 0; x < columns.length; x++) {
        final column = columns[x];
        if (column.columnWidth is FlexDataGridColumnWidth) {
          final columnWidth = column.columnWidth as FlexDataGridColumnWidth;
          double width = column.columnWidth.value * widthPerFlex;
          if (width < columnWidth.minWidth) {
            width = columnWidth.minWidth;
          } else if (width > columnWidth.maxWidth) {
            width = columnWidth.maxWidth;
          }
          _columnWidths[x] = width;
        }
      }
    }
    // Fire event
    _state = GridState.columnWidthsUpdated;
    Future<void>.delayed(Duration.zero, notifyListeners);
  }

  void onPointerDown(PointerEvent event, GridStateEventArg arg) {
    if (arg.resizingColumn != -1) {
      _state = GridState.columnResizeStart;
      _updateColumnWidths(arg.resizingColumn, event.localDelta.dx);
      notifyListeners();
    }
  }

  void onPointerMove(PointerEvent event, GridStateEventArg arg) {
    if (arg.resizingColumn != -1) {
      _state = GridState.columnResizing;
      _updateColumnWidths(arg.resizingColumn, event.localDelta.dx);
      notifyListeners();
    }
  }

  void onPointerUp(PointerEvent event, GridStateEventArg arg) {
    if (arg.resizingColumn != -1) {
      _state = GridState.columnResizeEnd;
      _updateColumnWidths(arg.resizingColumn, event.localDelta.dx);
      notifyListeners();
    }
  }

  void _updateColumnWidths(int column, double delta) {
    if (column < _columnWidths.length) {
      _resizingColumn = column;
      _columnWidths[column] = math.max(_minColumnWidth, _columnWidths[column] + delta);
      // Fill last column
      final lastWidth = _maxWidth - _columnWidths.fold(-_columnWidths.last, (p, v) => p + v);
      if (lastWidth > _minColumnWidth) {
        _columnWidths.last = lastWidth;
      }
    }
  }
}
