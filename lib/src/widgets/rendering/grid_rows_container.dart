import 'dart:math' as math;
import 'package:flutter/rendering.dart';

import '../../helpers/grid_state_manager.dart';
import 'grid_row.dart';

class _GridRowParentData extends ContainerBoxParentData<RenderGridRow> {}

class RenderGridRowsContainer extends RenderBox with ContainerRenderObjectMixin<RenderGridRow, _GridRowParentData> {
  RenderGridRowsContainer({
    bool isDirty = true,
    GridStateManager? stateManager,
  })  : _isDirty = isDirty,
        _stateManager = stateManager;

  bool get isDirty => _isDirty;
  bool _isDirty;

  GridStateManager? get stateManager => _stateManager;
  GridStateManager? _stateManager;
  set stateManager(GridStateManager? value) {
    if (_stateManager != value) {
      return;
    }
    _stateManager = value;
  }

  void childrenUpdated() {
    //print("RenderGridRowsContainer.childrenUpdated()");
    _isDirty = true;
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _GridRowParentData) {
      child.parentData = _GridRowParentData();
    }
  }

  @override
  void performLayout() {
    RenderGridRow? child;
    if (_isDirty && _stateManager != null) {
      final intrinsicWidths = <Map<int, double>>[];
      child = firstChild;
      while (child != null) {
        final childParentData = child.parentData as _GridRowParentData;
        intrinsicWidths.add(child.getIntrinsicColumnWidths());
        child = childParentData.nextSibling;
      }
      _stateManager?.computeColumnWidths(intrinsicWidths: intrinsicWidths);
    }
    _isDirty = false;

    double width = 0, height = 0;
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as _GridRowParentData;
      child.layout(constraints, parentUsesSize: true);
      childParentData.offset = Offset(0, height);
      width = math.max(width, child.size.width);
      height += child.size.height;
      child = childParentData.nextSibling;
    }
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderGridRow? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as _GridRowParentData;
      context.paintChild(child, childParentData.offset + offset);
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderGridRow? child = lastChild;
    while (child != null) {
      final childParentData = child.parentData as _GridRowParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = childParentData.previousSibling;
    }
    return false;
  }
}
