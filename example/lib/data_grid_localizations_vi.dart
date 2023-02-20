import 'package:flutter/material.dart';
import 'package:vph_data_grid/vph_data_grid.dart';

class DataGridLocalizationsVi extends DataGridLocalizations {
  DataGridLocalizationsVi() : super(const Locale("vi"));

  @override
  String? filterConditionTypeDescription(FilterConditionType type) {
    return const {
      "contains": "Bao gồm",
      "doesNotContain": "Không bao gồm",
      "equals": "Bằng",
      "doesNotEqual": "Không bằng",
      "beginsWith": "Bắt đầu bằng",
      "doesNotBeginWith": "Không bắt đầu bằng",
      "endsWith": "Kết thúc bằng",
      "doesNotEndWith": "Không kết thúc bằng",
      "greaterThan": "Lớn hơn",
      "greaterThanOrEqual": "Lớn hơn hoặc bằng",
      "lessThan": "Nhỏ hơn",
      "lessThanOrEqual": "Nhỏ hơn hoặc bằng",
    }[type.name];
  }

  @override
  String? dataGridSortStateDescription(DataGridSortState state) {
    return const {
      "none": "None",
      "unsorted": "Không sắp xếp",
      "ascending": "Tăng dần",
      "descending": "Giảm dần",
    }[state.name];
  }

  @override
  String get filterDialogSortTitle => "Sắp xếp";

  @override
  String get filterDialogFilterTitle => "Lọc";

  @override
  String get filterDialogApplyFilterLabel => "Áp dụng bộ lọc";

  @override
  String get filterDialogClearFilterLabel => "Xóa bộ lọc";

  @override
  String get paginationItemsInfoTitle =>
      r"Hiển thị $firstItem - $lastItem trong tổng số $itemCount";

  @override
  String get paginationShortItemsInfoTitle =>
      r"$firstItem - $lastItem / $itemCount";

  @override
  String get paginationItemsPerPageTitle => "Mục trên mỗi trang";

  @override
  String get noDataLabel => "Không có dữ liệu";
}
