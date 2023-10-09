import 'package:flexible_scrollable_table_view/src/arguments/table_build_arguments.dart';
import 'package:flexible_scrollable_table_view/src/flexible_table_column.dart';
import 'package:flutter/widgets.dart';

typedef BlankColumn<T> = EmptyFlexibleColumn<T>;
typedef SpacerColumn<T> = SpacerFlexibleColumn<T>;

///空白列，只有宽度，没有具体内容
final class EmptyFlexibleColumn<T> extends AbsFlexibleTableColumn<T> {
  const EmptyFlexibleColumn(super.id, this.width);

  final double width;

  @override
  Widget buildHeaderCell(TableBuildArgumentsMixin<T> arguments) {
    return SizedBox(width: width, height: 0);
  }

  @override
  Widget buildInfoCell(TableInfoRowArgumentsMixin<T> arguments) {
    return SizedBox(width: width, height: 0);
  }
}

///撑开，但没有内容的列
final class SpacerFlexibleColumn<T> extends AbsFlexibleTableColumn<T> {
  const SpacerFlexibleColumn(super.id, this.flex);

  final int flex;

  @override
  Widget buildHeaderCell(TableBuildArgumentsMixin<T> arguments) {
    return Spacer(flex: flex);
  }

  @override
  Widget buildInfoCell(TableInfoRowArgumentsMixin<T> arguments) {
    return Spacer(flex: flex);
  }
}
