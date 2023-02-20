import 'package:flutter/material.dart';

import '../data_grid_theme.dart';

class DataGridThemeHelper {
  static DataGridThemeData of(BuildContext context) {
    final theme = Theme.of(context);
    final data = DataGridTheme.of(context);
    return DataGridThemeData(
      headingTextStyle: data.headingTextStyle ?? theme.textTheme.titleSmall,
      headingRowHeight: data.headingRowHeight ?? 56.0,
      dataRowHeight: data.dataRowHeight ?? kMinInteractiveDimension,
      dataTextStyle: data.dataTextStyle ?? theme.textTheme.bodyMedium,
      borderWidth: data.borderWidth ?? 1.0,
      borderColor: data.borderColor ?? theme.colorScheme.onSurface.withOpacity(0.12),
      horizontalMargin: data.horizontalMargin ?? 24.0,
      resizeIndicatorColor: data.resizeIndicatorColor ?? theme.colorScheme.primary,
      resizeIndicatorWidth: data.resizeIndicatorWidth ?? 2.0,
      columnEdgeIndicatorColor: data.columnEdgeIndicatorColor ?? data.borderColor ?? theme.colorScheme.onSurface.withOpacity(0.12),
      columnEdgeIndicatorIndent: data.columnEdgeIndicatorIndent ?? 16.0,
      columnEdgeIndicatorWidth: data.columnEdgeIndicatorWidth ?? 1.0,
      minColumnWidth: data.minColumnWidth ?? 72,
    );
  }
}
