import 'package:flutter/material.dart';

import '../data_grid_localizations.dart';
import '../data_grid_source.dart';

const _kTitleHeight = 48.0;
const _kItemSpacing = 8.0;
const _kHorizontalPadding = 16.0;
const _kVerticalPadding = 16.0;
const _kItemPadding = EdgeInsets.symmetric(vertical: _kItemSpacing / 2, horizontal: _kHorizontalPadding);
const _kFixedButtonSize = Size(140, 48);

class FilterDialog extends StatefulWidget {
  const FilterDialog({
    super.key,
    required this.filter,
    this.title,
    this.onSort,
    this.onApplyFilter,
  });

  final Filter filter;
  final String? title;
  final void Function(DataGridSortState state)? onSort;
  final void Function(Filter? filter)? onApplyFilter;

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterOperator _operator;
  late List<FilterCondition> _conditions;

  @override
  void initState() {
    super.initState();
    _setFilter();
  }

  @override
  void didUpdateWidget(covariant FilterDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _setFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localezation = DataGridLocalizations.of(context);
    final filterConditionTypeItems = FilterConditionType.valuesPerDataType(widget.filter.dataType).map((e) {
      if (e != null) {
        return DropdownMenuItem<FilterConditionType>(value: e, child: Text(localezation.filterConditionTypeDescription(e) ?? e.name));
      } else {
        return DropdownMenuItemSeparator<FilterConditionType>();
      }
    }).toList();
    final inputBorder = OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    final inputDecoration = InputDecoration(enabledBorder: inputBorder, border: inputBorder);

    final children = <Widget>[
      if (widget.title != null) ...[
        Container(
          height: _kTitleHeight,
          alignment: Alignment.center,
          child: Text(widget.title!, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const Padding(padding: EdgeInsets.only(bottom: _kItemSpacing / 2), child: Divider(thickness: 1.0, height: 1.0)),
      ],
      Padding(
        padding: widget.title != null
            ? _kItemPadding
            : const EdgeInsets.only(
                left: _kHorizontalPadding,
                top: _kVerticalPadding,
                right: _kHorizontalPadding,
                bottom: _kItemSpacing / 2,
              ),
        child: Text(localezation.filterDialogSortTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: _kItemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () => widget.onSort?.call(DataGridSortState.ascending),
              style: OutlinedButton.styleFrom(fixedSize: _kFixedButtonSize, foregroundColor: theme.textTheme.button?.color ?? Colors.black),
              icon: const Icon(Icons.south, size: 20),
              label: Text(localezation.dataGridSortStateDescription(DataGridSortState.ascending) ?? "Ascending"),
            ),
            OutlinedButton.icon(
              onPressed: () => widget.onSort?.call(DataGridSortState.descending),
              style: OutlinedButton.styleFrom(fixedSize: _kFixedButtonSize, foregroundColor: theme.textTheme.button?.color ?? Colors.black),
              icon: const Icon(Icons.north, size: 20),
              label: Text(localezation.dataGridSortStateDescription(DataGridSortState.descending) ?? "Descending"),
            ),
          ],
        ),
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: _kItemSpacing / 2), child: Divider(thickness: 1.0, height: 1.0)),
      Padding(
        padding: _kItemPadding,
        child: Text(localezation.filterDialogFilterTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: _kItemPadding,
        child: DropdownButtonFormField<FilterConditionType>(
          decoration: inputDecoration,
          items: filterConditionTypeItems,
          value: _conditions[0].type,
          onChanged: (value) => _handleTypeDropdownChanged(0, value),
        ),
      ),
      Padding(
        padding: _kItemPadding,
        child: TextField(
          controller: TextEditingController(text: _conditions[0].value),
          decoration: inputDecoration,
          onChanged: (value) => _handleTextFieldChanged(0, value),
        ),
      ),
      Padding(
        padding: _kItemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: FilterOperator.values
              .map(
                (e) => Row(
                  children: [
                    Radio<FilterOperator>(
                      value: e,
                      groupValue: _operator,
                      onChanged: _handleOperatorChanged,
                    ),
                    Text(e.name),
                  ],
                ),
              )
              .toList(),
        ),
      ),
      Padding(
        padding: _kItemPadding,
        child: DropdownButtonFormField<FilterConditionType>(
          decoration: inputDecoration,
          items: filterConditionTypeItems,
          value: _conditions[1].type,
          onChanged: (value) => _handleTypeDropdownChanged(1, value),
        ),
      ),
      Padding(
        padding: _kItemPadding,
        child: TextField(
          controller: TextEditingController(text: _conditions[1].value),
          decoration: inputDecoration,
          onChanged: (value) => _handleTextFieldChanged(1, value),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: _kHorizontalPadding, top: _kItemSpacing, right: _kHorizontalPadding, bottom: _kVerticalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () => _handleApplyPressed(Navigator.of(context).pop),
              style: ElevatedButton.styleFrom(fixedSize: _kFixedButtonSize),
              child: Text(localezation.filterDialogApplyFilterLabel),
            ),
            const SizedBox(width: _kItemSpacing),
            OutlinedButton(
              onPressed: () => _handleClearPressed(Navigator.of(context).pop),
              style: OutlinedButton.styleFrom(fixedSize: _kFixedButtonSize),
              child: Text(localezation.filterDialogClearFilterLabel),
            ),
          ],
        ),
      ),
    ];

    return ListBody(children: children);
  }

  void _handleTypeDropdownChanged(int index, FilterConditionType? type) {
    if (type != null) {
      _conditions[index].type = type;
    }
  }

  void _handleOperatorChanged(FilterOperator? value) {
    if (value != null) {
      setState(() {
        _operator = value;
      });
    }
  }

  void _handleTextFieldChanged(int index, String value) {
    _conditions[index].value = value;
  }

  void _handleApplyPressed(void Function([dynamic result]) dismiss) {
    widget.onApplyFilter?.call(
      Filter(
        column: widget.filter.column,
        conditions: _conditions.where((cond) => cond.value != null && cond.value!.isNotEmpty).toList(),
        operator: _operator,
      ),
    );
    dismiss();
  }

  void _handleClearPressed(void Function([dynamic result]) dismiss) {
    for (final cond in _conditions) {
      cond.value = null;
    }
    widget.onApplyFilter?.call(Filter(column: widget.filter.column));
    dismiss();
  }

  void _setFilter() {
    _operator = widget.filter.operator;
    _conditions = widget.filter.conditions ?? [];
    for (int i = _conditions.length; i < 2; i++) {
      _conditions.add(FilterCondition());
    }
  }
}

class DropdownMenuItemSeparator<T> extends DropdownMenuItem<T> {
  DropdownMenuItemSeparator({super.key}) : super(enabled: false, child: Container());
  @override
  Widget build(BuildContext context) {
    return const Divider(thickness: 1.0, height: 1.0);
  }
}
