import 'dart:math' as math;
import 'package:flutter/rendering.dart';

import '../../data_grid_border.dart';
import '../grid_container.dart';

class GridContainerParentData extends ContainerBoxParentData<RenderBox> {
  GridRegion region = GridRegion.header;
  DataGridBorder? border;
}

class RenderGridContainer extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, GridContainerParentData> {
  RenderGridContainer({
    DataGridBorder? border,
  }) : _border = border;

  DataGridBorder? get border => _border;
  DataGridBorder? _border;
  set border(DataGridBorder? value) {
    if (_border == value) {
      return;
    }
    _border = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! GridContainerParentData) {
      child.parentData = GridContainerParentData();
    }
  }

  @override
  void performLayout() {
    assert(childCount < 6);
    double headerWidth = 0,
        headerHeight = 0,
        bodyWidth = 0,
        bodyHeight = 0,
        footerWidth = 0,
        footerHeight = 0;
    RenderBox? freezeHeaderChild,
        headerChild,
        freezeBodyChild,
        bodyChild,
        footerChild;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as GridContainerParentData;
      switch (childParentData.region) {
        case GridRegion.freezeHeader:
          freezeHeaderChild = child;
          break;
        case GridRegion.header:
          headerChild = child;
          break;
        case GridRegion.freezeBody:
          freezeBodyChild = child;
          break;
        case GridRegion.body:
          bodyChild = child;
          break;
        case GridRegion.footer:
          footerChild = child;
          break;
      }
      child = childParentData.nextSibling;
    }

    /// freezeHeader
    if (freezeHeaderChild != null) {
      freezeHeaderChild.layout(
          BoxConstraints(
              maxWidth: constraints.maxWidth, maxHeight: constraints.maxHeight),
          parentUsesSize: true);
      (freezeHeaderChild.parentData as GridContainerParentData).offset =
          const Offset(0, 0);
      headerWidth = freezeHeaderChild.size.width;
      headerHeight = freezeHeaderChild.size.height;
    }

    /// header
    if (headerChild != null) {
      headerChild.layout(
          BoxConstraints(
              maxWidth: constraints.maxWidth - headerWidth,
              maxHeight: constraints.maxHeight),
          parentUsesSize: true);
      (headerChild.parentData as GridContainerParentData).offset =
          Offset(headerWidth, 0);
      headerWidth += headerChild.size.width;
      headerHeight = math.max(headerHeight, headerChild.size.height);
    }
    // footer
    if (footerChild != null) {
      footerChild.layout(
          BoxConstraints(
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight - headerHeight),
          parentUsesSize: true);
      footerWidth = footerChild.size.width;
      footerHeight = footerChild.size.height;
    }
    // freezeBody
    if (freezeBodyChild != null) {
      freezeBodyChild.layout(
          BoxConstraints(
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight - headerHeight - footerHeight),
          parentUsesSize: true);
      (freezeBodyChild.parentData as GridContainerParentData).offset =
          Offset(0, headerHeight);
      bodyWidth = freezeBodyChild.size.width;
      bodyHeight = freezeBodyChild.size.height;
    }
    // body
    if (bodyChild != null) {
      bodyChild.layout(
          BoxConstraints(
              maxWidth: constraints.maxWidth - bodyWidth,
              maxHeight: constraints.maxHeight - headerHeight - footerHeight),
          parentUsesSize: true);
      (bodyChild.parentData as GridContainerParentData).offset =
          Offset(bodyWidth, headerHeight);
      bodyWidth += bodyChild.size.width;
      bodyHeight = math.max(bodyHeight, bodyChild.size.height);
    }
    // bottom offset
    if (footerChild != null) {
      (footerChild.parentData as GridContainerParentData).offset = Offset(
          0,
          math.max(
              headerHeight + bodyHeight, constraints.minHeight - footerHeight));
    }
    // Size
    size = constraints.constrainDimensions(
        math.max(math.max(headerWidth, bodyWidth), footerWidth),
        headerHeight + bodyHeight + footerHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (border != null) {
      _paintBorder(border!, context.canvas, offset & size);
    }
    _paintChildBorder(context.canvas, offset);

    /// Paint children
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as GridContainerParentData;
      context.paintChild(child, childParentData.offset + offset);
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      final childParentData = child.parentData! as GridContainerParentData;
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

  void _paintBorder(DataGridBorder border, Canvas canvas, Rect rect) {
    final top = border.top;
    final right = border.right;
    final bottom = border.bottom;
    final left = border.left;
    final Paint paint = Paint();
    final Path path = Path();

    switch (top.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        paint
          ..color = top.color
          ..strokeWidth = top.width
          ..style = PaintingStyle.stroke;
        path.reset();
        path.moveTo(rect.left, rect.top);
        path.lineTo(rect.right, rect.top);
        canvas.drawPath(path, paint);
        break;
    }

    switch (right.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        paint
          ..color = right.color
          ..strokeWidth = right.width
          ..style = PaintingStyle.stroke;
        path.reset();
        path.moveTo(rect.right, rect.top);
        path.lineTo(rect.right, rect.bottom);
        canvas.drawPath(path, paint);
        break;
    }

    switch (bottom.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        paint
          ..color = bottom.color
          ..strokeWidth = bottom.width
          ..style = PaintingStyle.stroke;
        path.reset();
        path.moveTo(rect.left, rect.bottom);
        path.lineTo(rect.right, rect.bottom);
        canvas.drawPath(path, paint);
        break;
    }

    switch (left.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        paint
          ..color = left.color
          ..strokeWidth = left.width
          ..style = PaintingStyle.stroke;
        path.reset();
        path.moveTo(rect.left, rect.top);
        path.lineTo(rect.left, rect.bottom);
        canvas.drawPath(path, paint);
        break;
    }
  }

  void _paintChildBorder(Canvas canvas, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as GridContainerParentData;
      if (childParentData.border != null) {
        _paintBorder(childParentData.border!, canvas,
            (offset + childParentData.offset) & child.size);
      }
      child = childParentData.nextSibling;
    }
  }
}
