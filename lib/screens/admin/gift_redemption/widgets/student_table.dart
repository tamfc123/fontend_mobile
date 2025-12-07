import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/screens/admin/gift_redemption/widgets/user_redemption_dialog.dart';

class StudentTable extends StatelessWidget {
  final List<UserModel> students;
  final double maxWidth;
  final Function(UserModel) onViewRedemptions;

  const StudentTable({
    super.key,
    required this.students,
    required this.maxWidth,
    required this.onViewRedemptions,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    final colWidths = {
      0: maxWidth * 0.20, // Tên
      1: maxWidth * 0.25, // Email
      2: maxWidth * 0.15, // SĐT
      3: maxWidth * 0.12, // Ngày sinh
      4: maxWidth * 0.10, // Xu
      5: maxWidth * 0.18, // Hành động
    };

    final colHeaders = [
      'Tên học viên',
      'Email',
      'SĐT',
      'Ngày sinh',
      'Số xu',
      'Hành động',
    ];

    final dataRows =
        students.map((student) {
          return TableRow(
            children: [
              CommonTableCell(
                student.name,
                bold: true,
                color: const Color(0xFF1E3A8A),
                align: TextAlign.center,
              ),
              CommonTableCell(student.email, align: TextAlign.center),
              CommonTableCell(student.phone, align: TextAlign.center),
              CommonTableCell(
                student.birthday != null
                    ? dateFormat.format(student.birthday!)
                    : '—',
                align: TextAlign.center,
              ),
              CommonTableCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${student.coins}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                align: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionIconButton(
                      icon: Icons.card_giftcard,
                      color: Colors.pink,
                      tooltip: 'Xem lịch sử đổi quà',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => UserRedemptionDialog(user: student),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList();

    return BaseAdminTable(
      columnWidths: colWidths.map((k, v) => MapEntry(k, FixedColumnWidth(v))),
      columnHeaders: colHeaders,
      dataRows: dataRows,
    );
  }
}
