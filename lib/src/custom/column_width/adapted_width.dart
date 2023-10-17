import 'dart:math';

import 'package:flexible_scrollable_table_view/src/arguments/table_build_arguments.dart';
import 'package:flexible_scrollable_table_view/src/custom/column_width/appointed_column_width.dart';
import 'package:flexible_scrollable_table_view/src/custom/widgets/zero_box.dart';
import 'package:flutter/widgets.dart';

///自适应列宽
final class AdaptedWidth<T> extends AppointedColumnWidth<T> {
  const AdaptedWidth(this.group);

  final AdaptedGroup group;

  @override
  Widget constrainWidth(TableBuildArgumentsMixin<T> arguments, Widget columnCell) {
    //用 -1 表示表头行
    final index = (arguments as TableInfoRowArgumentsMixin?)?.dataIndex ?? -1;
    return AdaptedChild(
      index,
      key: ValueKey<String>('${hashCode}_$index'),
      group: group,
      child: columnCell,
    );
  }
}

final class AdaptedGroup with ChangeNotifier {
  AdaptedGroup({
    this.minWidth = 0,
    this.maxWidth = double.infinity,
  });

  ///允许的最小宽度
  final double minWidth;

  ///允许的最大宽度
  final double maxWidth;

  ///每个下标的宽度缓存
  final Map<int, double> _widthCache = <int, double>{};

  Map<int, double> get widthCache => Map.of(_widthCache);

  ///列的必须宽度
  double _width = 0;

  double get width => _width;

  void _resetWidth(int index, double width) {
    final cache = _widthCache[index];
    if (cache == width) {
      return;
    }
    _widthCache[index] = width;
    notifyListeners();
  }

  void _removeWidth(int index) {
    _widthCache.remove(index);
    notifyListeners();
  }

  @override
  void dispose() {
    _widthCache.clear();
    super.dispose();
  }

  bool _locked = false;

  @override
  void notifyListeners() {
    if (_locked) {
      return;
    }
    _locked = true;
    Future.delayed(Duration.zero, () {
      _width = min<double>(
        maxWidth,
        _widthCache.values.fold(
          minWidth,
          (previousValue, element) {
            return max<double>(previousValue, element);
          },
        ),
      );
      _locked = false;
      super.notifyListeners();
    });
  }
}

final class AdaptedChild extends StatefulWidget {
  const AdaptedChild(
    this.index, {
    super.key,
    required this.group,
    required this.child,
  });

  final int index;
  final AdaptedGroup group;
  final Widget child;

  @override
  State<AdaptedChild> createState() => _AdaptedChildState();
}

class _AdaptedChildState extends State<AdaptedChild> {
  ///组件展示宽度
  late double childWidth;

  ///组件所需宽度
  double? realWidth;

  @override
  void initState() {
    super.initState();
    childWidth = widget.group._width;
    realWidth = widget.group._widthCache[widget.index];
    widget.group.addListener(onWidthChanged);
  }

  @override
  void didUpdateWidget(covariant AdaptedChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    childWidth = widget.group._width;
    realWidth = widget.group._widthCache[widget.index];
    if (oldWidget.group != widget.group) {
      oldWidget.group.removeListener(onWidthChanged);
      widget.group.addListener(onWidthChanged);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.group.removeListener(onWidthChanged);
    widget.group._removeWidth(widget.index);
  }

  void onWidthChanged() {
    final newChildWidth = widget.group._width;
    final newRealWidth = widget.group._widthCache[widget.index];
    if (!mounted || (newChildWidth == childWidth && newRealWidth == realWidth)) {
      return;
    }
    setState(() {
      childWidth = newChildWidth;
      realWidth == newRealWidth;
    });
  }

  ///获取了真实大小
  void onRealSizeCallback(Size size) {
    widget.group._resetWidth(widget.index, size.width);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: childWidth,
      height: double.infinity,
      child: Stack(children: [
        ZeroBox(
          onRealSizeCallback: onRealSizeCallback,
          child: widget.child,
        ),
        if (realWidth != null) widget.child,
      ]),
    );
  }
}
