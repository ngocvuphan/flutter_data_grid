## DataGrid for Flutter

[![Pub.Dev](https://img.shields.io/pub/v/vph_data_grid?color=blue&style=flat-square)](https://pub.dev/packages/vph_data_grid)
[![Demo Web](https://img.shields.io/badge/demo-web-green?style=flat-square)](https://ngocvuphan.github.io/demo_data_grid/)

### Features

* Column sizing
* Column resizing
* Column sorting
* Column filtering
* Localization

    Register new Localization class which extends DataGridLocalizations in your main():
    ```dart
    void main() {
        DataGridLocalizations.registerLocalization(DataGridLocalizationsVi());
        runApp(const MyApp());
    }
    ```
    Add flutter localizations delegates and locales in your MaterialApp:
    ```dart
    MaterialApp(
        localizationsDelegates: const [
            DataGridLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
            Locale('en'),
            Locale('vi'),
        ],
        ...
    )
    ```