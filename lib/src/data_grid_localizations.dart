import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'data_grid_source.dart';

abstract class DataGridLocalizations {
  const DataGridLocalizations(this.locale);

  final Locale locale;

  static DataGridLocalizations of(BuildContext context) =>
      Localizations.of<DataGridLocalizations>(context, DataGridLocalizations) ??
      _supportedLocalizations.values.first;

  static const LocalizationsDelegate<DataGridLocalizations> delegate =
      _DataGridLocalizationsDelegate();

  static final Map<String, DataGridLocalizations> _supportedLocalizations = {
    "en": const DataGridLocalizationsDefaultEn()
  };

  static void registerLocalization(DataGridLocalizations localization) =>
      _supportedLocalizations[localization.locale.toString()] = localization;

  static bool isSupported(Locale locale) =>
      _supportedLocalizations.keys.contains(locale.toString());

  static DataGridLocalizations load(Locale locale) =>
      _supportedLocalizations[locale.toString()] ??
      _supportedLocalizations.values.first;

  String? filterConditionTypeDescription(FilterConditionType type);
  String? dataGridSortStateDescription(DataGridSortState state);
  String get filterDialogSortTitle;
  String get filterDialogFilterTitle;
  String get filterDialogApplyFilterLabel;
  String get filterDialogClearFilterLabel;
  String get paginationItemsInfoTitle;
  String get paginationItemsPerPageTitle;
}

class DataGridLocalizationsDefaultEn extends DataGridLocalizations {
  const DataGridLocalizationsDefaultEn() : super(const Locale("en"));

  @override
  String? filterConditionTypeDescription(FilterConditionType type) {
    return const {
      "contains": "Contains",
      "doesNotContain": "Does Not Contain",
      "equals": "Equals",
      "doesNotEqual": "Does Not Equal",
      "beginsWith": "Begins With",
      "doesNotBeginWith": "Does Not Begin With",
      "endsWith": "Ends With",
      "doesNotEndWith": "Does Not End With",
      "greaterThan": "Greater Than",
      "greaterThanOrEqual": "Greater Than or Equal",
      "lessThan": "Less Than",
      "lessThanOrEqual": "Less Than or Equal",
    }[type.name];
  }

  @override
  String? dataGridSortStateDescription(DataGridSortState state) {
    return const {
      "none": "None",
      "unsorted": "Unsorted",
      "ascending": "Ascending",
      "descending": "Descending",
    }[state.name];
  }

  @override
  String get filterDialogSortTitle => "Sort";

  @override
  String get filterDialogFilterTitle => "Filter";

  @override
  String get filterDialogApplyFilterLabel => "Apply Filter";

  @override
  String get filterDialogClearFilterLabel => "Clear Filter";

  @override
  String get paginationItemsInfoTitle =>
      r"Showing $firstItem - $lastItem of $itemCount";

  @override
  String get paginationItemsPerPageTitle => "Items per page";
}

class _DataGridLocalizationsDelegate
    extends LocalizationsDelegate<DataGridLocalizations> {
  const _DataGridLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => DataGridLocalizations.isSupported(locale);

  @override
  Future<DataGridLocalizations> load(Locale locale) {
    return SynchronousFuture<DataGridLocalizations>(
        DataGridLocalizations.load(locale));
  }

  @override
  bool shouldReload(
          covariant LocalizationsDelegate<DataGridLocalizations> old) =>
      false;
}
