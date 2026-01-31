/// Template for the Table component source file.
const tableTemplate = '''
import 'package:flutter/material.dart';

@immutable
class FladTableTheme extends ThemeExtension<FladTableTheme> {
  final Color headerBackground;
  final Color headerText;
  final Color rowBackground;
  final Color rowAltBackground;
  final Color border;
  final Color cellText;
  final double borderWidth;

  const FladTableTheme({
    required this.headerBackground,
    required this.headerText,
    required this.rowBackground,
    required this.rowAltBackground,
    required this.border,
    required this.cellText,
    required this.borderWidth,
  });

  factory FladTableTheme.fromScheme(ColorScheme scheme) {
    return FladTableTheme(
      headerBackground: scheme.surface,
      headerText: scheme.onSurface,
      rowBackground: scheme.surface,
      rowAltBackground: scheme.surfaceVariant,
      border: scheme.outlineVariant,
      cellText: scheme.onSurface,
      borderWidth: 1,
    );
  }

  @override
  FladTableTheme copyWith({
    Color? headerBackground,
    Color? headerText,
    Color? rowBackground,
    Color? rowAltBackground,
    Color? border,
    Color? cellText,
    double? borderWidth,
  }) {
    return FladTableTheme(
      headerBackground: headerBackground ?? this.headerBackground,
      headerText: headerText ?? this.headerText,
      rowBackground: rowBackground ?? this.rowBackground,
      rowAltBackground: rowAltBackground ?? this.rowAltBackground,
      border: border ?? this.border,
      cellText: cellText ?? this.cellText,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  FladTableTheme lerp(ThemeExtension<FladTableTheme>? other, double t) {
    if (other is! FladTableTheme) return this;
    return FladTableTheme(
      headerBackground: Color.lerp(headerBackground, other.headerBackground, t)!,
      headerText: Color.lerp(headerText, other.headerText, t)!,
      rowBackground: Color.lerp(rowBackground, other.rowBackground, t)!,
      rowAltBackground:
          Color.lerp(rowAltBackground, other.rowAltBackground, t)!,
      border: Color.lerp(border, other.border, t)!,
      cellText: Color.lerp(cellText, other.cellText, t)!,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
    );
  }
}

class FladTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final EdgeInsetsGeometry cellPadding;
  final Map<int, TableColumnWidth>? columnWidths;
  final bool striped;

  const FladTable({
    super.key,
    required this.headers,
    required this.rows,
    this.cellPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.columnWidths,
    this.striped = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FladTableTheme>() ??
        FladTableTheme.fromScheme(theme.colorScheme);

    final borderSide = BorderSide(color: tokens.border, width: tokens.borderWidth);

    final headerRow = TableRow(
      decoration: BoxDecoration(color: tokens.headerBackground),
      children: [
        for (final header in headers)
          Padding(
            padding: cellPadding,
            child: Text(
              header,
              style: TextStyle(
                color: tokens.headerText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );

    final bodyRows = <TableRow>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final bg = striped && i.isOdd ? tokens.rowAltBackground : tokens.rowBackground;
      bodyRows.add(
        TableRow(
          decoration: BoxDecoration(color: bg),
          children: [
            for (final cell in row)
              Padding(
                padding: cellPadding,
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.cellText),
                  child: cell,
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(borderSide),
      ),
      child: Table(
        columnWidths: columnWidths,
        border: TableBorder(
          horizontalInside: borderSide,
          verticalInside: borderSide,
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [headerRow, ...bodyRows],
      ),
    );
  }
}
''';
