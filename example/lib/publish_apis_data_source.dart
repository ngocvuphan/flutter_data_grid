import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vph_data_grid/vph_data_grid.dart';

class PublishAPIsDataSource extends DataGridSource {
  final _sampleData = <List<String>>[];

  @override
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  List<DataGridRow>? _rows;
  int _startIndex = 0;
  int _count = 0;
  List<Filter?>? _filters;
  int Function(List<String>, List<String>)? _sortFunction;

  @override
  List<DataGridColumn> get columns {
    return const [
      DataGridColumn(
        name: "API",
        displayName: "API",
        columnWidth: FixedDataGridColumnWidth(120),
        resizable: true,
        filterable: true,
      ),
      DataGridColumn(
        name: "Description",
        columnWidth: FixedDataGridColumnWidth(200),
        // resizable: true,
      ),
      DataGridColumn(
        name: "Auth",
        columnWidth: FixedDataGridColumnWidth(120),
        resizable: true,
        sortable: true,
      ),
      DataGridColumn(
        name: "HTTPS",
        columnWidth: FixedDataGridColumnWidth(120),
        // resizable: true,
      ),
      DataGridColumn(
        name: "Cors",
        columnWidth: FixedDataGridColumnWidth(120),
        // resizable: true,
      ),
      DataGridColumn(
        name: "Category",
        columnWidth: FixedDataGridColumnWidth(120),
        // resizable: true,
      ),
      DataGridColumn(
        name: "Link",
        columnWidth: FlexDataGridColumnWidth(minWidth: 100),
        // resizable: true,
        filterable: true,
      ),
    ];
  }

  @override
  int get totalRowCount => _totalRowCount;
  int _totalRowCount = 0;

  @override
  List<DataGridRow>? get rows => _rows != null ? List.unmodifiable(_rows!) : null;

  @override
  Future<void> fetch({required int startIndex, required int count}) async {
    _isLoading = true;
    notifyListeners();

    if (_sampleData.isEmpty) {
      final response = await http.get(Uri.parse("https://api.publicapis.org/entries"));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        for (final result in json['entries']) {
          _sampleData.add(<String>[
            result['API'].toString(),
            result['Description'].toString(),
            result['Auth'].toString(),
            result['HTTPS'].toString(),
            result['Cors'].toString(),
            result['Category'].toString(),
            result['Link'].toString(),
          ]);
        }
      }
    }
    _startIndex = startIndex;
    _count = count;

    _localDataToRow();

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> sort({required int columnIndex, required DataGridSortState state}) async {
    _isLoading = true;
    notifyListeners();

    _sortFunction = (a, b) {
      final compare = a[columnIndex].toLowerCase().compareTo(b[columnIndex].toLowerCase());
      return (state == DataGridSortState.ascending) ? compare : -compare;
    };

    _localDataToRow();

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> applyFilters(List<Filter?> filters) async {
    _filters = filters;
    _startIndex = 0;
    _localDataToRow();
    notifyListeners();
  }

  List<bool> _compareString(String str, List<FilterCondition> conditions) {
    final results = <bool>[];
    for (final cond in conditions) {
      if (cond.value != null) {
        final value = cond.value!.toLowerCase();
        switch (cond.type) {
          case FilterConditionType.contains:
            results.add(str.contains(value));
            break;
          case FilterConditionType.doesNotContain:
            results.add(!str.contains(value));
            break;
          case FilterConditionType.equals:
            results.add(str == value);
            break;
          case FilterConditionType.doesNotEqual:
            results.add(str != value);
            break;
          case FilterConditionType.beginsWith:
            results.add(str.startsWith(value));
            break;
          case FilterConditionType.doesNotBeginWith:
            results.add(!str.startsWith(value));
            break;
          case FilterConditionType.endsWith:
            results.add(str.endsWith(value));
            break;
          case FilterConditionType.doesNotEndWith:
            results.add(!str.endsWith(value));
            break;
          case FilterConditionType.greaterThan:
          case FilterConditionType.greaterThanOrEqual:
          case FilterConditionType.lessThan:
          case FilterConditionType.lessThanOrEqual:
            break;
        }
      }
    }
    return results;
  }

  void _localDataToRow() {
    Iterable<List<String>> data = _sampleData;
    if (_filters != null) {
      for (final filter in _filters!) {
        if (filter != null && filter.isNotEmpty) {
          data = data.where((d) {
            final results = _compareString(d[filter.column].toLowerCase(), filter.conditions!);
            if (filter.operator == FilterOperator.or) {
              return results.any((e) => e);
            } else {
              return results.every((e) => e);
            }
          });
        }
      }
    }

    if (_sortFunction != null) {
      data = data.toList()..sort(_sortFunction);
    }

    _totalRowCount = data.length;
    _rows = data
        .skip(_startIndex)
        .take(_count)
        .map<DataGridRow>((e) => DataGridRow(
              children: [
                Text(e[0], overflow: TextOverflow.ellipsis),
                Text(e[1], overflow: TextOverflow.ellipsis),
                Text(e[2], overflow: TextOverflow.ellipsis),
                Text(e[3], overflow: TextOverflow.ellipsis),
                Text(e[4], overflow: TextOverflow.ellipsis),
                Text(e[5], overflow: TextOverflow.ellipsis),
                TextButton(onPressed: () {}, child: Text(e[6], overflow: TextOverflow.ellipsis)),
              ],
            ))
        .toList();
  }
}
