import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class ScrollControllerHelper {
  ScrollControllerHelper() {
    _horizontalControllers = LinkedScrollControllerGroup();
    _horizontalHeaderController = _horizontalControllers.addAndGet();
    _horizontalRowsController = _horizontalControllers.addAndGet();
    _verticalControllers = LinkedScrollControllerGroup();
    _verticalLeftController = _verticalControllers.addAndGet();
    _verticalRightController = _verticalControllers.addAndGet();
  }

  late LinkedScrollControllerGroup _horizontalControllers;
  late LinkedScrollControllerGroup _verticalControllers;

  ScrollController? get horizontalHeaderController => _horizontalHeaderController;
  ScrollController? _horizontalHeaderController;

  ScrollController? get horizontalRowsController => _horizontalRowsController;
  ScrollController? _horizontalRowsController;

  ScrollController? get verticalLeftController => _verticalLeftController;
  ScrollController? _verticalLeftController;

  ScrollController? get verticalRightController => _verticalRightController;
  ScrollController? _verticalRightController;

  void dispose() {
    horizontalHeaderController?.dispose();
    horizontalRowsController?.dispose();
    verticalLeftController?.dispose();
    verticalRightController?.dispose();
  }
}
