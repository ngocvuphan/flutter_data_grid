import 'package:flutter/widgets.dart';

import '../helpers/grid_state_manager.dart';
import 'grid_row.dart';
import 'rendering/grid_rows_container.dart';

class GridRowsContainer extends MultiChildRenderObjectWidget {
  GridRowsContainer({
    super.key,
    this.stateManager,
    required List<GridRow> children,
  }) : super(children: children);

  final GridStateManager? stateManager;

  @override
  MultiChildRenderObjectElement createElement() =>
      _ElementGridRowsContainer(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderGridRowsContainer(stateManager: stateManager);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    (renderObject as RenderGridRowsContainer).stateManager = stateManager;
  }
}

class _ElementGridRowsContainer extends MultiChildRenderObjectElement {
  _ElementGridRowsContainer(super.widget);

  @override
  void update(covariant MultiChildRenderObjectWidget newWidget) {
    super.update(newWidget);
    if (renderObject is RenderGridRowsContainer) {
      (renderObject as RenderGridRowsContainer).childrenUpdated();
    }
  }
}
