import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vph_data_grid/vph_data_grid.dart';
import 'package:flutter/material.dart';

import 'data_grid_localizations_vi.dart';
import 'publish_apis_data_source.dart';

void main() {
  DataGridLocalizations.registerLocalization(DataGridLocalizationsVi());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Locale> _supportedLocales = const [
    Locale('en'),
    Locale('vi'),
  ];
  late Locale _selectedLocale;
  late PublishAPIsDataSource _dataSource;

  @override
  void initState() {
    super.initState();

    _selectedLocale = _supportedLocales[0];
    _dataSource = PublishAPIsDataSource();
    _dataSource.fetch(startIndex: 0, count: 10);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        DataGridLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: _supportedLocales,
      locale: _selectedLocale,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.appTitle),
            actions: [
              PopupMenuButton<Locale>(
                initialValue: _selectedLocale,
                onSelected: (value) {
                  if (value != _selectedLocale) {
                    setState(() {
                      _selectedLocale = value;
                    });
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: Locale("en"),
                      child: ListTile(
                          leading: Text("🇺🇸", style: TextStyle(fontSize: 28)),
                          title: Text("English")),
                    ),
                    PopupMenuItem(
                      value: Locale("vi"),
                      child: ListTile(
                          leading: Text("🇻🇳", style: TextStyle(fontSize: 28)),
                          title: Text("Tiếng Việt")),
                    ),
                  ];
                },
                icon: const Icon(Icons.language),
              ),
            ],
          ),
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
      }),
    );
  }
}
