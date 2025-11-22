import 'package:flutter/material.dart';

class BaseAdminTable extends StatelessWidget {
  // Màu sắc
  static const Color primaryBlue = Colors.blue;
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  final Map<int, FixedColumnWidth> columnWidths;
  final List<String> columnHeaders;
  final List<TableRow> dataRows;

  const BaseAdminTable({
    super.key,
    required this.columnWidths,
    required this.columnHeaders,
    required this.dataRows,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: IntrinsicWidth(
        child: Table(
          columnWidths: columnWidths,
          border: TableBorder(
            bottom: BorderSide(color: surfaceBlue),
            horizontalInside: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          children: [
            // 1. Header Row (Tự động tạo)
            TableRow(
              decoration: BoxDecoration(color: surfaceBlue),
              children:
                  columnHeaders
                      .map(
                        (title) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      .toList(),
            ),
            // 2. Data Rows (Được truyền từ bên ngoài)
            ...dataRows,
          ],
        ),
      ),
    );
  }
}
