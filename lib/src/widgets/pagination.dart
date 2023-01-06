import 'dart:math' as math;
import 'package:flutter/material.dart';

const _kPageNumberIndicatorSize = 36.0;
const _kPageNumberIndicatorMargin = 4.0;
const _kPageNumberIndicatorExtendSize = (_kPageNumberIndicatorSize + _kPageNumberIndicatorMargin);
const _kPageNumbersPerList = 5;
const _kPageNumbersListMaxWidth = _kPageNumberIndicatorExtendSize * _kPageNumbersPerList;
const _kPageControlIconSize = 20.0;
const _kDisabledControlOpacity = 0.2;
const _kItemSpacing = 16.0;

class Pagination extends StatefulWidget {
  const Pagination({
    super.key,
    this.textStyle,
    required this.totalItems,
    this.itemsPerPage = 10,
    this.initialPage = 0,
    this.availableItemsPerPage = const <int>[10, 15, 20, 25, 50],
    this.onChanged,
  });

  final TextStyle? textStyle;
  final int totalItems;
  final int itemsPerPage;
  final int initialPage;
  final List<int> availableItemsPerPage;
  final Future<void> Function(int pageIndex, int itemsPerPage)? onChanged;

  @override
  State<Pagination> createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  late ScrollController _scrollController;

  late int _itemsPerPage;
  late int _numberOfPages;
  late int _currentPage;
  late bool _enableFirstPageCtrl;
  late bool _enableLastPageCtrl;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _updateState(itemsPerPage: widget.itemsPerPage, currentPage: widget.initialPage);
  }

  @override
  void didUpdateWidget(covariant Pagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemsPerPage != widget.itemsPerPage || oldWidget.totalItems != widget.totalItems) {
      _updateState(itemsPerPage: widget.itemsPerPage);
    }
  }

  void _updateState({int? itemsPerPage, int? currentPage}) {
    if (itemsPerPage != null) {
      _itemsPerPage = itemsPerPage;
      _numberOfPages = (widget.totalItems / _itemsPerPage).ceil();
    }

    _currentPage = math.min(currentPage ?? _currentPage, _numberOfPages > 0 ? _numberOfPages - 1 : 0);
    _enableFirstPageCtrl = _currentPage != 0;
    _enableLastPageCtrl = _currentPage != _numberOfPages - 1;
  }

  Future<void> _scrollTo(int pageIndex) async {
    double pos = 0;
    if (pageIndex < 0) {
      pos = _scrollController.position.maxScrollExtent;
    } else if (pageIndex > 0) {
      final midPos = ((_kPageNumbersPerList / 2).ceil()) * _kPageNumberIndicatorExtendSize;
      pos = pageIndex * _kPageNumberIndicatorExtendSize;
      if ((_scrollController.offset + _kPageNumbersListMaxWidth) <= pos) {
        pos = _scrollController.offset + midPos;
      } else if (pos < _scrollController.offset) {
        pos = _scrollController.offset - midPos;
      } else {
        pos = -1;
      }
    }
    if (pos != -1) {
      _scrollController.animateTo(pos, duration: const Duration(milliseconds: 250), curve: Curves.linear);
    }
  }

  void _gotoPage(int index) {
    _scrollTo(index);
    if (index == -1) {
      index = _numberOfPages - 1;
    }
    setState(() => _updateState(currentPage: index));
    if (widget.onChanged != null) {
      widget.onChanged!(_currentPage, _itemsPerPage);
    }
  }

  void _setItemsPerPage(int? value) {
    setState(() => _updateState(itemsPerPage: value));
    if (widget.onChanged != null) {
      widget.onChanged!(_currentPage, _itemsPerPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const margin = EdgeInsets.symmetric(horizontal: _kPageNumberIndicatorMargin / 2);

    final firstItemIndex = _numberOfPages > 0 ? _currentPage * _itemsPerPage + 1 : 0;
    final lastItemIndex = math.min((_currentPage + 1) * _itemsPerPage, widget.totalItems);

    final children = <Widget>[];

    if (_numberOfPages > 1) {
      /// Goto First page
      if (_numberOfPages > _kPageNumbersPerList) {
        children.add(
          Container(
            width: _kPageNumberIndicatorSize,
            height: _kPageNumberIndicatorSize,
            margin: margin,
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(_kPageNumberIndicatorSize),
              textStyle: widget.textStyle,
              child: InkWell(
                onTap: _enableFirstPageCtrl ? () => _gotoPage(0) : null,
                child: Center(
                  child: Icon(
                    Icons.first_page,
                    size: _kPageControlIconSize,
                    color: widget.textStyle?.color?.withOpacity(_enableFirstPageCtrl ? 1.0 : _kDisabledControlOpacity),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      children.addAll([
        /// Goto previous page
        Container(
          width: _kPageNumberIndicatorSize,
          height: _kPageNumberIndicatorSize,
          margin: margin,
          child: Material(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(_kPageNumberIndicatorSize),
            textStyle: widget.textStyle,
            child: InkWell(
              onTap: _enableFirstPageCtrl ? () => _gotoPage(_currentPage - 1) : null,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_left,
                  size: _kPageControlIconSize,
                  color: widget.textStyle?.color?.withOpacity(_enableFirstPageCtrl ? 1.0 : _kDisabledControlOpacity),
                ),
              ),
            ),
          ),
        ),

        /// Pages list
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kPageNumbersListMaxWidth),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              controller: _scrollController,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  _numberOfPages,
                  (index) => Container(
                    width: _kPageNumberIndicatorSize,
                    height: _kPageNumberIndicatorSize,
                    margin: margin,
                    child: Material(
                      color: _currentPage == index ? theme.colorScheme.primary : null,
                      textStyle: widget.textStyle,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(_kPageNumberIndicatorSize),
                      child: InkWell(
                        onTap: () => _gotoPage(index),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(color: _currentPage == index ? theme.colorScheme.onPrimary : null),
                          ),
                        ),
                      ),
                    ),
                  ),
                  growable: false,
                ),
              ),
            ),
          ),
        ),

        /// Goto next page
        Container(
          width: _kPageNumberIndicatorSize,
          height: _kPageNumberIndicatorSize,
          margin: margin,
          child: Material(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(_kPageNumberIndicatorSize),
            textStyle: widget.textStyle,
            child: InkWell(
              onTap: _enableLastPageCtrl ? () => _gotoPage(_currentPage + 1) : null,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_right,
                  size: _kPageControlIconSize,
                  color: widget.textStyle?.color?.withOpacity(_enableLastPageCtrl ? 1.0 : _kDisabledControlOpacity),
                ),
              ),
            ),
          ),
        ),
      ]);

      /// Goto last page
      if (_numberOfPages > _kPageNumbersPerList) {
        children.add(
          Container(
            width: _kPageNumberIndicatorSize,
            height: _kPageNumberIndicatorSize,
            margin: margin,
            child: Material(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(_kPageNumberIndicatorSize),
              textStyle: widget.textStyle,
              child: InkWell(
                onTap: _enableLastPageCtrl ? () => _gotoPage(-1) : null,
                child: Center(
                  child: Icon(
                    Icons.last_page,
                    size: _kPageControlIconSize,
                    color: widget.textStyle?.color?.withOpacity(_enableLastPageCtrl ? 1.0 : _kDisabledControlOpacity),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      children.add(
        const SizedBox(width: _kItemSpacing),
      );
    }

    children.addAll([
      /// Text
      Text("$firstItemIndex - $lastItemIndex of ${widget.totalItems}", style: widget.textStyle),
      const Spacer(),

      /// Dropdown
      const SizedBox(width: _kItemSpacing),
      const Text("Items per page"),
      const SizedBox(width: _kItemSpacing),
      DropdownButton<int>(
        value: _itemsPerPage,
        items: widget.availableItemsPerPage
            .map(
              (e) => DropdownMenuItem<int>(
                value: e,
                child: Text(e.toString()),
              ),
            )
            .toList(),
        onChanged: _setItemsPerPage,
      ),
    ]);

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
