import 'package:flutter/material.dart';

import 'data_grid_localizations.dart';
import 'data_grid_row.dart';
import 'data_grid_theme.dart';
import 'data_grid_border.dart';
import 'data_grid_source.dart';
import 'data_grid_column.dart';
import 'helpers/data_grid_theme_helper.dart';
import 'helpers/scroll_controller_helper.dart';
import 'widgets/filter_dialog.dart';
import 'widgets/grid_container.dart';
import 'widgets/grid_row.dart';
import 'widgets/grid_rows_container.dart';
import 'widgets/pagination.dart';
import 'helpers/grid_state_manager.dart';
import 'widgets/popup_dialog.dart';
import 'widgets/sort_icon.dart';

const Duration kSortIconAnimationDuration = Duration(milliseconds: 150);

class DataGrid extends StatefulWidget {
  const DataGrid({
    super.key,
    required this.source,
    this.border,
    this.borderStyle = DataGridBorderStyle.horizontal,
    this.freezeColumns = 0,
    this.empty,
  });

  final DataGridSource source;
  final DataGridBorder? border;
  final DataGridBorderStyle borderStyle;
  final int freezeColumns;
  final Widget? empty;

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  late ScrollControllerHelper _controllers;
  late GridStateManager _stateManager;
  late List<DataGridColumn> _columns;
  late List<Filter?> _filters;

  int _rowsPerPage = 10;
  int _sortColumnIndex = -1;
  DataGridSortState _sortState = DataGridSortState.none;

  @override
  void initState() {
    super.initState();

    _controllers = ScrollControllerHelper();
    _columns = widget.source.columns;
    _filters = _columns
        .map<Filter?>((e) => e.filterable
            ? Filter(
                column: _columns.indexOf(e),
                dataType: e.isDate
                    ? FilterDataType.date
                    : e.isNumber
                        ? FilterDataType.number
                        : FilterDataType.string,
              )
            : null)
        .toList();
    _stateManager = GridStateManager(columns: _columns);

    widget.source.addListener(_handleDataSourceChanged);
    _handleDataSourceChanged();
  }

  @override
  void didUpdateWidget(covariant DataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      oldWidget.source.removeListener(_handleDataSourceChanged);
      widget.source.addListener(_handleDataSourceChanged);
      _columns = widget.source.columns;
      _filters = _columns
          .map<Filter?>((e) => e.filterable
              ? Filter(
                  column: _columns.indexOf(e),
                  dataType: e.isDate
                      ? FilterDataType.date
                      : e.isNumber
                          ? FilterDataType.number
                          : FilterDataType.string,
                )
              : null)
          .toList();
      _handleDataSourceChanged();
    }
  }

  @override
  void dispose() {
    widget.source.removeListener(_handleDataSourceChanged);
    _controllers.dispose();
    super.dispose();
  }

  void _handleDataSourceChanged() => setState(() {});

  Future<void> _handlePageChanged(int pageIndex, int itemsPerPage) async {
    widget.source.fetch(startIndex: pageIndex * itemsPerPage, count: itemsPerPage);
    setState(() {
      _rowsPerPage = itemsPerPage;
    });
  }

  void _handleSort(int columnIndex, [DataGridSortState? nextState]) {
    nextState ??= _sortState.next(resetState: _sortColumnIndex != columnIndex);

    widget.source.sort(columnIndex: columnIndex, state: nextState);

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortState = nextState!;
    });
  }

  void _handleFilter(int columnIndex, Filter? filter) {
    if (_filters[columnIndex] != filter) {
      _filters[columnIndex] = filter;
      widget.source.applyFilters(_filters);
    }
  }

  void _addHeader(
    List<GridChild> children, {
    required GridStateManager stateManager,
    required DataGridThemeData dataGridTheme,
    required DataGridLocalizations localization,
    required DataGridBorder? border,
    required EdgeInsetsGeometry? defaultPadding,
  }) {
    Widget buildHeadingCell(DataGridColumn column) {
      final index = _columns.indexOf(column);
      final alignment = column.alignment;
      final padding = column.padding ?? defaultPadding;
      final sortState = (column.sortable || column.filterable) && _sortColumnIndex == index ? _sortState : DataGridSortState.none;
      final isNotEmptyFilter = _filters[index] != null && _filters[index]!.isNotEmpty;
      Widget label = column.label ?? Text(column.displayName ?? column.name, overflow: TextOverflow.ellipsis);

      label = Row(
        children: [
          label,
          if (sortState != DataGridSortState.none || isNotEmptyFilter) const Spacer(),
          if (sortState != DataGridSortState.none) SortIcon(state: sortState),
          if (isNotEmptyFilter) const Icon(Icons.filter_alt_outlined, size: 20),
        ],
      );

      label = Container(
        height: dataGridTheme.headingRowHeight!,
        alignment: alignment,
        padding: padding,
        child: AnimatedDefaultTextStyle(
          style: dataGridTheme.headingTextStyle!,
          softWrap: false,
          duration: kSortIconAnimationDuration,
          child: label,
        ),
      );

      if (column.sortable) {
        label = InkWell(
          onTap: () => _handleSort(index),
          child: label,
        );
      } else if (column.filterable) {
        label = PopupDialog(
          dialogBuilder: (context) => FilterDialog(
            filter: _filters[index]!,
            title: column.displayName,
            onSort: (state) => _handleSort(index, state),
            onApplyFilter: (filter) => _handleFilter(index, filter),
          ),
          child: label,
        );
      }

      return label;
    }

    if (widget.freezeColumns > 0) {
      children.add(
        GridChild(
          region: GridRegion.freezeHeader,
          border: DataGridBorder(right: border?.verticalInside ?? BorderSide.none),
          child: Padding(
            padding: EdgeInsets.only(right: (border?.verticalInside.width ?? 0.0), bottom: (border?.horizontalInside.width ?? 0.0) / 2),
            child: GridRow(
              type: GridRowType.header,
              stateManager: stateManager,
              border: border,
              columnEdgeIndicatorIndent: dataGridTheme.columnEdgeIndicatorIndent!,
              columnEdgeIndicatorWidth: dataGridTheme.columnEdgeIndicatorWidth!,
              columnEdgeIndicatorColor: dataGridTheme.columnEdgeIndicatorColor!,
              resizeIndicatorWidth: dataGridTheme.resizeIndicatorWidth!,
              resizeIndicatorColor: dataGridTheme.resizeIndicatorColor!,
              children: _columns.take(widget.freezeColumns).map(buildHeadingCell).toList(),
            ),
          ),
        ),
      );
    }

    children.add(
      GridChild(
        region: GridRegion.header,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _controllers.horizontalHeaderController,
            child: Padding(
              padding: EdgeInsets.only(bottom: (border?.horizontalInside.width ?? 0.0) / 2),
              child: GridRow(
                type: GridRowType.header,
                stateManager: stateManager,
                skipColumns: widget.freezeColumns,
                border: border,
                columnEdgeIndicatorIndent: dataGridTheme.columnEdgeIndicatorIndent!,
                columnEdgeIndicatorWidth: dataGridTheme.columnEdgeIndicatorWidth!,
                columnEdgeIndicatorColor: dataGridTheme.columnEdgeIndicatorColor!,
                resizeIndicatorWidth: dataGridTheme.resizeIndicatorWidth!,
                resizeIndicatorColor: dataGridTheme.resizeIndicatorColor!,
                children: _columns.skip(widget.freezeColumns).map(buildHeadingCell).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addRows(
    List<GridChild> children, {
    required GridStateManager stateManager,
    required DataGridThemeData dataGridTheme,
    required DataGridLocalizations localization,
    required DataGridBorder? border,
    required EdgeInsetsGeometry? defaultPadding,
  }) {
    Widget buildDataCell({
      required DataGridRow row,
      required int index,
    }) {
      final cell = row.children[index];
      final column = _columns[index];
      final alignment = column.alignment;
      final padding = column.padding ?? defaultPadding;

      Widget label = Container(
        height: dataGridTheme.dataRowHeight!,
        alignment: alignment,
        padding: padding,
        child: DefaultTextStyle(style: dataGridTheme.dataTextStyle!, child: cell),
      );
      return label;
    }

    final rows = widget.source.rows ?? [];

    if (widget.source.isLoading) {
      children.add(
        GridChild(
          region: GridRegion.body,
          border: DataGridBorder(bottom: border?.horizontalInside ?? BorderSide.none),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    } else if (rows.isEmpty) {
      children.add(
        GridChild(
          region: GridRegion.body,
          border: DataGridBorder(bottom: border?.horizontalInside ?? BorderSide.none),
          child: widget.empty ?? Center(child: Text(localization.noDataLabel)),
        ),
      );
    } else {
      if (widget.freezeColumns > 0) {
        final leftRows = List.generate(rows.length, (rowIdx) {
          final row = rows[rowIdx];
          final isLastRow = rowIdx == rows.length - 1;
          return GridRow(
            stateManager: stateManager,
            border: isLastRow ? border?.copyWith(horizontalInside: BorderSide.none) : border,
            columnEdgeIndicatorIndent: dataGridTheme.columnEdgeIndicatorIndent!,
            columnEdgeIndicatorWidth: dataGridTheme.columnEdgeIndicatorWidth!,
            columnEdgeIndicatorColor: dataGridTheme.columnEdgeIndicatorColor!,
            resizeIndicatorWidth: dataGridTheme.resizeIndicatorWidth!,
            resizeIndicatorColor: dataGridTheme.resizeIndicatorColor!,
            children: List.generate(widget.freezeColumns, (index) => buildDataCell(row: row, index: index)),
          );
        });
        children.add(
          GridChild(
            region: GridRegion.freezeBody,
            border: DataGridBorder(
              right: border?.verticalInside ?? BorderSide.none,
              bottom: border?.horizontalInside ?? BorderSide.none,
            ),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: _controllers.verticalLeftController,
                child: Padding(
                  padding: EdgeInsets.only(right: (border?.verticalInside.width ?? 0.0)),
                  child: GridRowsContainer(stateManager: stateManager, children: leftRows),
                ),
              ),
            ),
          ),
        );
      }

      final rightRows = List.generate(rows.length, (rowIdx) {
        final row = rows[rowIdx];
        final isLastRow = rowIdx == rows.length - 1;
        return GridRow(
          stateManager: stateManager,
          skipColumns: widget.freezeColumns,
          border: isLastRow ? border?.copyWith(horizontalInside: BorderSide.none) : border,
          columnEdgeIndicatorIndent: dataGridTheme.columnEdgeIndicatorIndent!,
          columnEdgeIndicatorWidth: dataGridTheme.columnEdgeIndicatorWidth!,
          columnEdgeIndicatorColor: dataGridTheme.columnEdgeIndicatorColor!,
          resizeIndicatorWidth: dataGridTheme.resizeIndicatorWidth!,
          resizeIndicatorColor: dataGridTheme.resizeIndicatorColor!,
          children: List.generate(row.children.length - widget.freezeColumns, (index) => buildDataCell(row: row, index: index + widget.freezeColumns)),
        );
      });

      children.add(
        GridChild(
          region: GridRegion.body,
          border: DataGridBorder(bottom: border?.horizontalInside ?? BorderSide.none),
          child: Scrollbar(
            controller: _controllers.horizontalRowsController,
            notificationPredicate: (notification) => notification.depth == 0,
            child: Scrollbar(
              controller: _controllers.verticalRightController,
              notificationPredicate: (notification) => notification.depth == 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _controllers.horizontalRowsController,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _controllers.verticalRightController,
                  child: GridRowsContainer(stateManager: stateManager, children: rightRows),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  void _addFooter(
    List<GridChild> children, {
    required GridStateManager stateManager,
    required DataGridThemeData dataGridTheme,
    required DataGridBorder? border,
    required EdgeInsetsGeometry? defaultPadding,
  }) {
    if (widget.source.totalRowCount > _rowsPerPage) {
      children.add(
        GridChild(
          region: GridRegion.footer,
          child: GridRow(
            type: GridRowType.footer,
            stateManager: stateManager,
            children: [
              Container(
                height: dataGridTheme.headingRowHeight!,
                padding: EdgeInsets.symmetric(horizontal: dataGridTheme.horizontalMargin!),
                alignment: Alignment.centerLeft,
                child: Pagination(
                  textStyle: dataGridTheme.dataTextStyle!,
                  totalItems: widget.source.totalRowCount,
                  itemsPerPage: _rowsPerPage,
                  onChanged: _handlePageChanged,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final dataGridTheme = DataGridThemeHelper.of(context);
      final localization = DataGridLocalizations.of(context);
      final borderSide = Divider.createBorderSide(context, color: dataGridTheme.borderColor, width: dataGridTheme.borderWidth!);
      final border = widget.border ?? DataGridBorder.withStyle(style: widget.borderStyle, borderSide: borderSide);
      final defaultPadding = EdgeInsets.symmetric(horizontal: dataGridTheme.horizontalMargin!);
      final children = <GridChild>[];

      _stateManager.setConfiguration(
        constraints: constraints,
        minColumnWidth: dataGridTheme.minColumnWidth,
      );

      _addHeader(
        children,
        stateManager: _stateManager,
        dataGridTheme: dataGridTheme,
        localization: localization,
        border: border,
        defaultPadding: defaultPadding,
      );

      _addRows(
        children,
        stateManager: _stateManager,
        dataGridTheme: dataGridTheme,
        localization: localization,
        border: border,
        defaultPadding: defaultPadding,
      );

      _addFooter(
        children,
        stateManager: _stateManager,
        dataGridTheme: dataGridTheme,
        border: border,
        defaultPadding: defaultPadding,
      );

      return GridContainer(border: border, children: children);
    });
  }
}
