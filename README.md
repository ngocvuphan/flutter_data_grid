## DataGrid for Flutter

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

### [Demo Web](https://ngocvuphan.github.io/demo_data_grid/)

### [Pub.Dev](https://pub.dev/packages/vph_data_grid )

