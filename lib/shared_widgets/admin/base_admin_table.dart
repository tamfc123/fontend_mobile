import 'package:flutter/material.dart';

class BaseAdminTable extends StatefulWidget {
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
  State<BaseAdminTable> createState() => _BaseAdminTableState();
}

class _BaseAdminTableState extends State<BaseAdminTable> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Table(
              columnWidths: widget.columnWidths,
              border: TableBorder(
                bottom: const BorderSide(color: BaseAdminTable.surfaceBlue),
                horizontalInside: BorderSide(
                  color: Colors.grey.shade200,
                  width: 0.5,
                ),
              ),
              children: [
                // 1. Header Row (Tự động tạo)
                TableRow(
                  decoration: const BoxDecoration(
                    color: BaseAdminTable.surfaceBlue,
                  ),
                  children:
                      widget.columnHeaders
                          .map(
                            (title) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: BaseAdminTable.primaryBlue,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                          .toList(),
                ),
                // 2. Data Rows (Được truyền từ bên ngoài)
                ...widget.dataRows,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
