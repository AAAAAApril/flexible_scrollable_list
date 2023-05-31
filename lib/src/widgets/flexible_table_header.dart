import 'package:flexible_scrollable_table_view/src/animation/flexible_table_animations.dart';
import 'package:flexible_scrollable_table_view/src/animation/table_constraint_animation_wrapper.dart';
import 'package:flexible_scrollable_table_view/src/decoration/flexible_table_decorations.dart';
import 'package:flexible_scrollable_table_view/src/flexible_column.dart';
import 'package:flexible_scrollable_table_view/src/flexible_table_configurations.dart';
import 'package:flexible_scrollable_table_view/src/flexible_table_controller.dart';
import 'package:flexible_scrollable_table_view/src/scrollable/horizontal_scroll_controller_builder.dart';
import 'package:flexible_scrollable_table_view/src/widgets/table_column_header_widget.dart';
import 'package:flutter/widgets.dart';

///表头（行）
class FlexibleTableHeader<T> extends StatelessWidget {
  const FlexibleTableHeader(
    this.controller, {
    super.key,
    required this.configurations,
    this.decorations,
    this.animations,
    this.physics,
  });

  final FlexibleTableController<T> controller;
  final AbsFlexibleTableConfigurations<T> configurations;
  final AbsFlexibleTableDecorations<T>? decorations;
  final AbsFlexibleTableAnimations<T>? animations;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => TableHeaderRowConstraintAnimationWrapper<T>(
        controller,
        constraints: BoxConstraints.tight(
          Size(
            constraints.maxWidth,
            configurations.rowHeight.headerRowHeight,
          ),
        ),
        animations: animations,
        child: _FlexibleTableHeader<T>(
          controller,
          configurations: configurations,
          decorations: decorations,
          animations: animations,
          parentWidth: constraints.maxWidth,
          physics: physics,
        ),
      ),
    );
  }
}

class _FlexibleTableHeader<T> extends StatelessWidget {
  const _FlexibleTableHeader(
    this.controller, {
    super.key,
    required this.configurations,
    this.decorations,
    this.animations,
    required this.parentWidth,
    this.physics,
  });

  final FlexibleTableController<T> controller;
  final AbsFlexibleTableConfigurations<T> configurations;
  final AbsFlexibleTableDecorations<T>? decorations;
  final AbsFlexibleTableAnimations<T>? animations;
  final double parentWidth;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final Widget pinned = PinnedTableHeaderRow<T>(
      controller,
      configurations: configurations,
      animations: animations,
      decorations: decorations,
      parentWidth: parentWidth,
    );
    final Widget scrollable = ScrollableTableHeaderRow<T>(
      controller,
      configurations: configurations,
      decorations: decorations,
      parentWidth: parentWidth,
      physics: physics,
    );
    final Widget child;
    if (configurations.pinnedColumns.isNotEmpty && configurations.scrollableColumns.isNotEmpty) {
      child = Row(children: [
        pinned,
        Expanded(child: scrollable),
      ]);
    } else {
      if (configurations.scrollableColumns.isEmpty) {
        child = pinned;
      } else {
        child = scrollable;
      }
    }
    return decorations?.headerRowDecorationBuilder?.call(
          controller,
          configurations,
          child,
        ) ??
        child;
  }
}

///表头行固定区域
class PinnedTableHeaderRow<T> extends StatelessWidget {
  const PinnedTableHeaderRow(
    this.controller, {
    super.key,
    required this.configurations,
    this.animations,
    this.decorations,
    required this.parentWidth,
  });

  final FlexibleTableController<T> controller;
  final AbsFlexibleTableConfigurations<T> configurations;
  final AbsFlexibleTableAnimations<T>? animations;
  final AbsFlexibleTableDecorations<T>? decorations;
  final double parentWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: configurations.pinnedColumns
          .map<Widget>(
            (e) => TableColumnHeaderWidget<T>(
              controller,
              configurations: configurations,
              animations: animations,
              decorations: decorations,
              column: e,
              parentWidth: parentWidth,
              height: configurations.rowHeight.headerRowHeight,
            ),
          )
          .toList(growable: false),
    );
  }
}

///表头行滚动区域
class ScrollableTableHeaderRow<T> extends StatelessWidget {
  const ScrollableTableHeaderRow(
    this.controller, {
    super.key,
    required this.configurations,
    this.decorations,
    required this.parentWidth,
    this.physics,
  });

  final FlexibleTableController<T> controller;
  final AbsFlexibleTableConfigurations<T> configurations;
  final AbsFlexibleTableDecorations<T>? decorations;
  final double parentWidth;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final List<AbsFlexibleColumn<T>> columns = configurations.scrollableColumns.toList(growable: false);
    return HorizontalScrollControllerBuilder<T>(
      controller,
      builder: (context, scrollController) => ListView.builder(
        controller: scrollController,
        itemCount: columns.length,
        scrollDirection: Axis.horizontal,
        primary: false,
        padding: EdgeInsets.zero,
        physics: physics,
        itemBuilder: (context, index) => TableColumnHeaderWidget<T>(
          controller,
          configurations: configurations,
          decorations: decorations,
          column: columns[index],
          parentWidth: parentWidth,
          height: configurations.rowHeight.headerRowHeight,
        ),
      ),
    );
  }
}
