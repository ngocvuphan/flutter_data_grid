import 'dart:convert';

import 'package:data_grid/data_grid.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataGrid Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter DataGrid Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late _DataSource _dataSource;

  @override
  void initState() {
    super.initState();

    _dataSource = _DataSource();
    _dataSource.fetch(startIndex: 0, count: 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DataGridTheme(
        data: const DataGridThemeData(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: DataGrid(
                  borderStyle: DataGridBorderStyle.all,
                  //freezeColumns: 1,
                  source: _dataSource,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataSource extends DataGridSource {
  final _sampleData = <List<String>>[];
  // final _sampleData = <List<String>>[
  //   <String>["AdoptAPet", "Resource to help get pets adopted", "apiKey", "true", "yes", "Animals", "https://www.adoptapet.com/public/apis/pet_list.html"],
  //   <String>["Axolotl", "Collection of axolotl pictures and facts", "", "true", "no", "Animals", "https://theaxolotlapi.netlify.app/"],
  //   <String>["Cat Facts", "Daily cat facts", "", "true", "no", "Animals", "https://alexwohlbruck.github.io/cat-facts/"],
  //   <String>["Cataas", "Cat as a service (cats pictures and gifs)", "", "true", "no", "Animals", "https://cataas.com/"],
  //   <String>["Cats", "Pictures of cats from Tumblr", "apiKey", "true", "no", "Animals", "https://docs.thecatapi.com/"],
  // ];

  @override
  bool get isLoading => _isLoading;
  // ignore: prefer_final_fields
  bool _isLoading = true;

  List<DataGridRow>? _rows;
  int _startIndex = 0;
  int _count = 0;
  List<Filter?>? _filters;

  @override
  List<DataGridColumn> get columns {
    return const [
      DataGridColumn(
        name: "API",
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
        columnWidth: FlexDataGridColumnWidth(),
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

    _localDataToRow(sort: (a, b) {
      final compare = a[columnIndex].toLowerCase().compareTo(b[columnIndex].toLowerCase());
      if (state == DataGridSortState.ascending) {
        return compare;
      } else {
        return -compare;
      }
    });

    _sortColumnIndex = columnIndex;
    _sortState = state;
    _isLoading = false;
    notifyListeners();
  }

  @override
  int get sortColumnIndex => _sortColumnIndex;
  int _sortColumnIndex = -1;

  @override
  DataGridSortState get sortState => _sortState;
  DataGridSortState _sortState = DataGridSortState.unsorted;

  @override
  Future<void> applyFilters(List<Filter?> filters) async {
    _filters = filters;
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

  void _localDataToRow({int Function(List<String>, List<String>)? sort}) {
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

    if (sort != null) {
      data = data.toList()..sort(sort);
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
