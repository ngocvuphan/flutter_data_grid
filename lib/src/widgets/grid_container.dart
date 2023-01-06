import 'package:flutter/widgets.dart';

import '../data_grid_border.dart';
import 'rendering/grid_container.dart';

class GridContainer extends MultiChildRenderObjectWidget {
  GridContainer({
    super.key,
    this.border,
    required List<GridChild> children,
  }) : super(children: children);

  /// Container outside (top, right, bottom, left) border
  final DataGridBorder? border;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderGridContainer(
      border: border,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    (renderObject as RenderGridContainer).border = border;
  }
}

enum GridRegion { freezeHeader, header, freezeBody, body, footer }

class GridChild extends ParentDataWidget<GridContainerParentData> {
  const GridChild({
    super.key,
    required this.region,
    this.border,
    required super.child,
  });

  final GridRegion region;

  /// Container outside (top, right, bottom, left) border
  final DataGridBorder? border;

  @override
  void applyParentData(RenderObject renderObject) {
    bool needsLayout = false;
    final parentData = renderObject.parentData! as GridContainerParentData;
    if (parentData.region != region) {
      parentData.region = region;
      needsLayout = true;
    }
    if (parentData.border != border) {
      parentData.border = border;
      needsLayout = true;
    }
    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => GridContainer;
}
