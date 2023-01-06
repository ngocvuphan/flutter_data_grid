import 'package:flutter/foundation.dart';

import 'data_grid_column.dart';
import 'data_grid_row.dart';

enum DataGridSortState {
  none,
  unsorted,
  ascending,
  descending;

  DataGridSortState next({bool resetState = false}) {
    if (resetState) {
      return DataGridSortState.ascending;
    } else {
      return this == DataGridSortState.ascending
          ? DataGridSortState.descending
          : DataGridSortState.ascending;
    }
  }
}

enum FilterOperator {
  and("And"),
  or("Or");

  const FilterOperator(this.description);
  final String description;
}

enum FilterConditionType {
  contains("Contains"),
  doesNotContain("Does Not Contain"),
  equals("Equals"),
  doesNotEqual("Does Not Equal"),
  beginsWith("Begins With"),
  doesNotBeginWith("Does Not Begin With"),
  endsWith("Ends With"),
  doesNotEndWith("Does Not End With"),
  greaterThan("Greater Than"),
  greaterThanOrEqual("Greater Than or Equal"),
  lessThan("Less Than"),
  lessThanOrEqual("Less Than or Equal");

  const FilterConditionType(this.description);
  final String description;

  static Iterable<FilterConditionType?> valuesPerDataType(FilterDataType type) {
    switch (type) {
      case FilterDataType.string:
        return <FilterConditionType?>[
          contains,
          doesNotContain,
          null,
          equals,
          doesNotEqual,
          null,
          beginsWith,
          doesNotBeginWith,
          endsWith,
          doesNotEndWith,
        ];
      case FilterDataType.number:
      case FilterDataType.date:
        return <FilterConditionType?>[
          equals,
          doesNotEqual,
          null,
          greaterThan,
          greaterThanOrEqual,
          lessThan,
          lessThanOrEqual,
        ];
    }
  }
}

enum FilterDataType { string, number, date }

class FilterCondition {
  FilterCondition({
    this.type = FilterConditionType.contains,
    this.value,
  });

  FilterConditionType type;
  String? value;

  @override
  bool operator ==(Object other) {
    return other is FilterCondition &&
        type == other.type &&
        value == other.value;
  }

  @override
  int get hashCode => Object.hashAll([type, value]);
}

class Filter {
  Filter({
    required this.column,
    this.conditions,
    this.operator = FilterOperator.and,
    this.dataType = FilterDataType.string,
  });

  final int column;
  List<FilterCondition>? conditions;
  FilterOperator operator;
  FilterDataType dataType;

  bool get isNotEmpty =>
      conditions != null &&
      conditions!.any((cond) => cond.value != null && cond.value!.isNotEmpty);

  @override
  bool operator ==(Object other) {
    return other is Filter &&
        column == other.column &&
        operator == other.operator &&
        listEquals(conditions, other.conditions) &&
        dataType == other.dataType;
  }

  @override
  int get hashCode => Object.hashAll([column, conditions, operator]);
}

abstract class DataGridSource extends ChangeNotifier {
  bool get isLoading;
  List<DataGridColumn> get columns;
  List<DataGridRow>? get rows;
  int get totalRowCount;
  int get sortColumnIndex;
  DataGridSortState get sortState;
  Future<void> fetch({required int startIndex, required int count});
  Future<void> sort(
      {required int columnIndex, required DataGridSortState state});
  Future<void> applyFilters(List<Filter?> filters);
}
