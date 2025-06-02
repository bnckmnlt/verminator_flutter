import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/daily_records_cell.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/data_table_column.dart';

class DataTableSticky<T> extends StatelessWidget {
  final void Function(DailyRecordsCell) onShowDetails;
  final FocusNode tableFocusNode;
  final List<DataTableColumn> columns;
  final List<DailyRecordsCell> data;

  const DataTableSticky({
    super.key,
    required this.columns,
    required this.data,
    required this.tableFocusNode,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    final mutedTextStyle = TextStyle(
      color: Constants().textMutedFgDark,
      fontWeight: FontWeight.w500,
    );

    return DataTable2(
      headingTextStyle: mutedTextStyle,
      onSelectAll: (bool? item) {},
      columnSpacing: 12,
      dataRowHeight: 42,
      horizontalMargin: 24,
      headingRowHeight: 42,
      columns: columns
          .map((item) => DataColumn2(
                label: Text(item.label),
                size: ColumnSize.L,
              ))
          .toList(),
      rows: data
          .map(
            (row) => DataRow(
              cells: _mapRowToCells(context, row),
            ),
          )
          .toList(),
    );
  }

  List<DataCell> _mapRowToCells(BuildContext context, DailyRecordsCell row) {
    final fadedStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
    );

    return [
      DataCell(InkWell(
          onTap: () {
            onShowDetails(_onRowTap(context, row));
          },
          child: Text(row.day))),
      DataCell(InkWell(
          onTap: () {
            onShowDetails(_onRowTap(context, row));
          },
          child: _textWithUnit(row.temperature, " °C", fadedStyle))),
      DataCell(InkWell(
          onTap: () {
            onShowDetails(_onRowTap(context, row));
          },
          child: _textWithUnit(row.humidity, "%", fadedStyle))),
      DataCell(InkWell(
          onTap: () {
            onShowDetails(_onRowTap(context, row));
          },
          child: _textWithUnit(row.soilMoisture, "%", fadedStyle))),
      DataCell(InkWell(
          onTap: () {
            onShowDetails(_onRowTap(context, row));
          },
          child: _textWithUnit(row.nitrogen, "%", fadedStyle))),
      DataCell(InkWell(
          onTap: () {
            onShowDetails(_onRowTap(context, row));
          },
          child: _textWithUnit(row.phosphorus, "%", fadedStyle))),
      DataCell(InkWell(
          onTap: () {
            onShowDetails(_onRowTap(context, row));
          },
          child: _textWithUnit(row.potassium, "%", fadedStyle))),
      DataCell(InkWell(
          onTap: () {
            onShowDetails(_onRowTap(context, row));
          },
          child: Text(row.wormActivity))),
    ];
  }

  DailyRecordsCell _onRowTap(BuildContext context, DailyRecordsCell row) {
    return DailyRecordsCell(
      day: row.day,
      temperature: row.temperature,
      humidity: row.humidity,
      soilMoisture: row.soilMoisture,
      nitrogen: row.nitrogen,
      phosphorus: row.phosphorus,
      potassium: row.potassium,
      wormActivity: row.wormActivity,
    );
  }

  Widget _textWithUnit(String value, String unit, TextStyle fadedStyle) {
    return Row(
      children: [
        Text(value),
        Text(
          unit,
          style: fadedStyle,
        ),
      ],
    );
  }
}
