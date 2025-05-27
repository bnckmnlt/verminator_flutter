import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';

class DataTableSticky extends StatelessWidget {
  final List<DataTableColumn> columns;
  final List<DataTableCell> data;

  const DataTableSticky({
    super.key,
    required this.columns,
    required this.data,
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

  List<DataCell> _mapRowToCells(BuildContext context, DataTableCell row) {
    final fadedStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
    );
    return [
      DataCell(Text(row.day)),
      DataCell(
        Row(
          children: [
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              row.condition.toString().split('.').last.firstLetterUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        placeholder: true,
      ),
      DataCell(_textWithUnit(row.temperature, " °C", fadedStyle)),
      DataCell(_textWithUnit(row.humidity, "%", fadedStyle)),
      DataCell(_textWithUnit(row.soilMoisture, "%", fadedStyle)),
      DataCell(_textWithUnit(row.nitrogen, "%", fadedStyle)),
      DataCell(_textWithUnit(row.phosphorus, "%", fadedStyle)),
      DataCell(_textWithUnit(row.potassium, "%", fadedStyle)),
      DataCell(Text(row.wormActivity)),
    ];
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

class DataTableColumn {
  final String label;
  final IconData? icon;
  final Color? color;

  DataTableColumn({
    required this.label,
    this.icon,
    this.color,
  });
}

class DataTableCell {
  final String day;
  final SensorStatus condition;
  final String temperature;
  final String humidity;
  final String soilMoisture;
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String wormActivity;

  DataTableCell({
    required this.day,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.wormActivity,
  });
}
