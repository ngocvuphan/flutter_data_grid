import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../data_grid_border.dart';
import '../../helpers/grid_state_manager.dart';
import '../grid_row.dart';

class GridRowParentData extends ContainerBoxParentData<RenderBox> {}

class RenderGridRow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, GridRowParentData>
    implements MouseTrackerAnnotation {
  RenderGridRow({
    required GridRowType type,
    required GridStateManager stateManager,
    required int skipColumns,
    DataGridBorder? border,
    required double columnEdgeIndicatorIndent,
    required double columnEdgeIndicatorWidth,
    required Color columnEdgeIndicatorColor,
    required double resizeIndicatorWidth,
    required Color resizeIndicatorColor,
    ImageConfiguration configuration = ImageConfiguration.empty,
  })  : _type = type,
        _stateManager = stateManager,
        _skipColumns = skipColumns,
        _border = border,
        _columnEdgeIndicatorIndent = columnEdgeIndicatorIndent,
        _columnEdgeIndicatorWidth = columnEdgeIndicatorWidth,
        _columnEdgeIndicatorColor = columnEdgeIndicatorColor,
        _resizeIndicatorWidth = resizeIndicatorWidth,
        _resizeIndicatorColor = resizeIndicatorColor,
        _configuration = configuration {
    _stateManager.addListener(_handleGridStateChanged);
  }

  GridRowType get type => _type;
  GridRowType _type;
  set type(GridRowType value) {
    if (_type == value) {
      return;
    }
    _type = value;
    markNeedsPaint();
  }

  GridStateManager get stateManager => _stateManager;
  GridStateManager _stateManager;
  set stateManager(GridStateManager value) {
    if (_stateManager == value) {
      return;
    }
    _stateManager.removeListener(_handleGridStateChanged);
    _stateManager = value;
    _stateManager.addListener(_handleGridStateChanged);
  }

  int get skipColumns => _skipColumns;
  int _skipColumns;
  set skipColumns(int value) {
    if (_skipColumns == value) {
      return;
    }
    _skipColumns = value;
    markNeedsLayout();
  }

  DataGridBorder? get border => _border;
  DataGridBorder? _border;
  set border(DataGridBorder? value) {
    if (_border == value) {
      return;
    }
    _border = value;
    markNeedsLayout();
  }

  double get columnEdgeIndicatorIndent => _columnEdgeIndicatorIndent;
  double _columnEdgeIndicatorIndent;
  set columnEdgeIndicatorIndent(double value) {
    if (_columnEdgeIndicatorIndent == value) {
      return;
    }
    _columnEdgeIndicatorIndent = value;
    markNeedsPaint();
  }

  double get columnEdgeIndicatorWidth => _columnEdgeIndicatorWidth;
  double _columnEdgeIndicatorWidth;
  set columnEdgeIndicatorWidth(double value) {
    if (_columnEdgeIndicatorWidth == value) {
      return;
    }
    _columnEdgeIndicatorWidth = value;
    markNeedsPaint();
  }

  Color get columnEdgeIndicatorColor => _columnEdgeIndicatorColor;
  Color _columnEdgeIndicatorColor;
  set columnEdgeIndicatorColor(Color value) {
    if (_columnEdgeIndicatorColor == value) {
      return;
    }
    _columnEdgeIndicatorColor = value;
    markNeedsPaint();
  }

  double get resizeIndicatorWidth => _resizeIndicatorWidth;
  double _resizeIndicatorWidth;
  set resizeIndicatorWidth(double value) {
    if (_resizeIndicatorWidth == value) {
      return;
    }
    _resizeIndicatorWidth = value;
    markNeedsPaint();
  }

  Color get resizeIndicatorColor => _resizeIndicatorColor;
  Color _resizeIndicatorColor;
  set resizeIndicatorColor(Color value) {
    if (_resizeIndicatorColor == value) {
      return;
    }
    _resizeIndicatorColor = value;
    markNeedsPaint();
  }

  ImageConfiguration get configuration => _configuration;
  ImageConfiguration _configuration;
  set configuration(ImageConfiguration value) {
    if (value == _configuration) {
      return;
    }
    _configuration = value;
    markNeedsPaint();
  }

  late List<Rect?> _columnRightRects;
  static const kColumnRightRectWidth = 8.0;
  int _resizingColumn = -1;
  bool _isColumnResizing = false;
  bool _isHitChildrent = false;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! GridRowParentData) {
      child.parentData = GridRowParentData();
    }
  }

  Map<int, double> getIntrinsicColumnWidths() {
    final maxIntrinsicWidths = <int, double>{};
    int index = _skipColumns;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as GridRowParentData;
      if (stateManager.isIntrinsicWidthColumn(index)) {
        maxIntrinsicWidths[index] = child.getMaxIntrinsicWidth(double.infinity);
      }
      index++;
      child = childParentData.nextSibling;
    }
    return maxIntrinsicWidths;
  }

  @override
  void performLayout() {
    if (_type == GridRowType.footer) {
      assert(childCount == 1);
      _columnRightRects = [];
      firstChild?.layout(
          BoxConstraints.tightFor(width: _stateManager.gridWidth),
          parentUsesSize: true);
      size = firstChild?.size ?? Size.zero;
    } else {
      double width = 0, height = 0;
      int index = 0;
      RenderBox? child = firstChild;
      while (child != null) {
        final childParentData = child.parentData as GridRowParentData;
        double childWidth = stateManager.getColumnWidth(index + _skipColumns);
        if (childWidth > 0) {
          child.layout(BoxConstraints.tightFor(width: childWidth),
              parentUsesSize: true);
        } else {
          child.layout(BoxConstraints(maxHeight: constraints.maxHeight),
              parentUsesSize: true);
        }
        childParentData.offset = Offset(width, 0);
        width += child.size.width;
        height = math.max(height, child.size.height);
        index++;
        child = childParentData.nextSibling;
      }

      _columnRightRects = List<Rect?>.filled(childCount, null);
      index = 0;
      child = firstChild;
      while (child != null) {
        final childParentData = child.parentData as GridRowParentData;
        final right = childParentData.offset.dx + child.size.width;
        _columnRightRects[index] = Rect.fromLTRB(
            right - kColumnRightRectWidth / 2,
            0,
            right + kColumnRightRectWidth / 2,
            height);
        index++;
        child = childParentData.nextSibling;
      }

      size = constraints.constrain(Size(width, height));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (border != null) {
      _paintBorder(context.canvas, offset);
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as GridRowParentData;
      context.paintChild(child, childParentData.offset + offset);
      child = childParentData.nextSibling;
    }

    if (_type != GridRowType.footer && _stateManager.hasResizableColumn) {
      _paintColumnResizeIndicator(context.canvas, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      final childParentData = child.parentData as GridRowParentData;
      _isHitChildrent = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );
      if (_isHitChildrent) {
        return true;
      }
      child = childParentData.previousSibling;
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) {
    if (_isColumnResizing) {
      return true;
    }
    _resizingColumn = -1;
    if (type == GridRowType.header) {
      for (int x = 0; x < _columnRightRects.length; x++) {
        if (_stateManager.columnResizable(x + _skipColumns) &&
            _columnRightRects[x]!.contains(position)) {
          _resizingColumn = x;
          return true;
        }
      }
    }
    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (validForMouseTracker) {
      if (event is PointerDownEvent) {
        if (!_isHitChildrent) {
          _stateManager.onPointerDown(
              event,
              GridStateEventArg(
                  resizingColumn: _resizingColumn + _skipColumns));
        }
      } else if (event is PointerMoveEvent) {
        _stateManager.onPointerMove(event,
            GridStateEventArg(resizingColumn: _resizingColumn + _skipColumns));
      } else if (event is PointerUpEvent) {
        _stateManager.onPointerUp(event,
            GridStateEventArg(resizingColumn: _resizingColumn + _skipColumns));
      }
    }
  }

  @override
  MouseCursor get cursor => validForMouseTracker
      ? SystemMouseCursors.resizeColumn
      : SystemMouseCursors.basic;

  @override
  PointerEnterEventListener? get onEnter => _handlePointerEntered;

  @override
  PointerExitEventListener? get onExit => _handlePointerExit;

  @override
  bool get validForMouseTracker => _isColumnResizing || _resizingColumn != -1;

  @override
  void dispose() {
    _stateManager.removeListener(_handleGridStateChanged);
    super.dispose();
  }

  void _paintBorder(Canvas canvas, Offset offset) {
    final verticalInside = border!.verticalInside;
    final horizontalInside = border!.horizontalInside;
    final Paint paint = Paint();
    final Path path = Path();
    switch (verticalInside.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        paint
          ..color = verticalInside.color
          ..strokeWidth = verticalInside.width
          ..style = PaintingStyle.stroke;
        path.reset();
        for (int i = 0; i < _columnRightRects.length - 1; i++) {
          final origin = offset + _columnRightRects[i]!.topCenter;
          path.moveTo(origin.dx, origin.dy);
          path.lineTo(origin.dx, origin.dy + size.height);
        }
        canvas.drawPath(path, paint);
        break;
    }

    switch (horizontalInside.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        paint
          ..color = horizontalInside.color
          ..strokeWidth = horizontalInside.width
          ..style = PaintingStyle.stroke;
        path.reset();
        path.moveTo(offset.dx, offset.dy + size.height);
        path.lineTo(offset.dx + size.width, offset.dy + size.height);
        canvas.drawPath(path, paint);
        break;
    }
  }

  void _paintColumnResizeIndicator(Canvas canvas, Offset offset) {
    final Paint paint = Paint()..style = PaintingStyle.stroke;
    final Path path = Path();

    bool withIndicator = false;
    path.reset();
    for (int x = 0; x < _columnRightRects.length; x++) {
      if (border != null &&
          border!.verticalInside.style == BorderStyle.none &&
          _type == GridRowType.header &&
          _stateManager.columnResizable(x + _skipColumns)) {
        withIndicator = true;
        paint
          ..color = _columnEdgeIndicatorColor
          ..strokeWidth = _columnEdgeIndicatorWidth;
        final topCenter = offset + _columnRightRects[x]!.topCenter;
        path.moveTo(topCenter.dx, topCenter.dy + _columnEdgeIndicatorIndent);
        path.lineTo(topCenter.dx,
            topCenter.dy + size.height - _columnEdgeIndicatorIndent);
      }
    }
    if (withIndicator) {
      canvas.drawPath(path, paint);
    }

    if (_isColumnResizing && _resizingColumn != -1) {
      final topCenter = offset + _columnRightRects[_resizingColumn]!.topCenter;
      paint
        ..color = _resizeIndicatorColor
        ..strokeWidth = _resizeIndicatorWidth;
      path.reset();
      path.moveTo(topCenter.dx, topCenter.dy);
      path.lineTo(topCenter.dx, topCenter.dy + size.height);
      canvas.drawPath(path, paint);
    }
  }

  void _handleGridStateChanged() {
    switch (_stateManager.state) {
      case GridState.none:
        break;
      case GridState.columnResizeStart:
        _resizingColumn = _stateManager.resizingColumn - _skipColumns;
        _isColumnResizing =
            0 <= _resizingColumn && _resizingColumn < childCount;
        if (!_isColumnResizing) {
          _resizingColumn = -1;
        }
        markNeedsPaint();
        break;
      case GridState.columnResizing:
        markNeedsLayout();
        break;
      case GridState.columnResizeEnd:
        _isColumnResizing = false;
        _resizingColumn = -1;
        markNeedsPaint();
        break;
      case GridState.columnWidthsUpdated:
        if (_type != GridRowType.data) {
          markNeedsLayout();
        }
        break;
    }
  }

  void _handlePointerEntered(PointerEnterEvent event) {}

  void _handlePointerExit(PointerExitEvent event) {}
}
