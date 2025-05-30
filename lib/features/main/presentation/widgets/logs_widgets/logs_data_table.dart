import 'package:data_table_2/data_table_2.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/data_table_sticky.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/logs/domain/entity/log_entity.dart';
import 'package:google_fonts/google_fonts.dart';

class LogsDataTable extends StatelessWidget {
  final List<DataTableColumn> columns;
  final List<LogDataTableCell> data;
  final double deviceHeight;

  const LogsDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.deviceHeight,
  });

  @override
  Widget build(BuildContext context) {
    final dataSource = LogDataTableSource(data, context);

    final mutedTextStyle = TextStyle(
      color: Constants().textMutedFgDark,
      fontWeight: FontWeight.w500,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44),
        child: SizedBox(
          height: deviceHeight * 0.75,
          child: PaginatedDataTable2(
            empty: EmptyDisplayWidget(
              icon: FluentIcons.table_search_20_regular,
              title: "No results found",
              description: "Try another search or adjust the filters",
            ),
            border: TableBorder.symmetric(
              borderRadius: BorderRadius.circular(0),
              outside: BorderSide(
                width: 1,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
            ),
            rowsPerPage: 15,
            source: dataSource,
            headingTextStyle: mutedTextStyle,
            columnSpacing: 12,
            dataRowHeight: 42,
            horizontalMargin: 24,
            headingRowHeight: 42,
            headingRowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.shadow.withOpacity(0.3)),
            columns: columns
                .map((item) => DataColumn2(
                      label: Text(item.label),
                      size: ColumnSize.L,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

Widget getLogSeverityWidget(LogSeverity severity) {
  IconData icon;
  String label;
  Color color;

  switch (severity) {
    case LogSeverity.info:
      icon = FluentIcons.info_24_regular;
      label = "INFO";
      color = Colors.blueAccent;
      break;
    case LogSeverity.warn:
      icon = FluentIcons.warning_24_regular;
      label = "WARN";
      color = Colors.amberAccent;
      break;
    case LogSeverity.error:
      icon = FluentIcons.error_circle_24_regular;
      label = "ERROR";
      color = Colors.redAccent;
      break;
    case LogSeverity.fatal:
      icon = FluentIcons.error_circle_12_regular;
      label = "FATAL";
      color = Colors.indigoAccent;
      break;
  }

  return Container(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: color.withAlpha(64),
        width: 1,
      ),
      color: color.withAlpha(12),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class LogDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<LogDataTableCell> data;

  LogDataTableSource(this.data, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final row = data[index];
    return DataRow2.byIndex(
      color: WidgetStateProperty.all(Theme.of(context).colorScheme.shadow),
      index: index,
      cells: [
        DataCell(
          getLogSeverityWidget(row.logSeverity),
        ),
        DataCell(
          Text(
            row.createdAt,
            style: GoogleFonts.spaceMono(
              color: Constants().textMutedFgDark,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.025,
            ),
          ),
        ),
        DataCell(Text(
          row.message,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.025,
          ),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

class LogDataTableCell {
  final LogSeverity logSeverity;
  final String message;
  final String createdAt;

  LogDataTableCell({
    required this.logSeverity,
    required this.message,
    required this.createdAt,
  });
}
