import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/screens/admin/manage_account/widgets/comfirm_toggle_status.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/screens/admin/manage_account/widgets/user_redemption_dialog.dart';

class AccountTable extends StatelessWidget {
  final List<UserModel> users;
  final double maxWidth;
  final Function(UserModel) onEdit;
  final Function(UserModel) onToggleStatus;

  const AccountTable({
    super.key,
    required this.users,
    required this.maxWidth,
    required this.onEdit,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    final colWidths = {
      0: maxWidth * 0.16,
      1: maxWidth * 0.20,
      2: maxWidth * 0.14,
      3: maxWidth * 0.11,
      4: maxWidth * 0.10,
      5: maxWidth * 0.11,
      6: maxWidth * 0.18,
    };
    final colHeaders = [
      'Tên',
      'Email',
      'SĐT',
      'Ngày sinh',
      'Vai trò',
      'Trạng thái',
      'Hành động',
    ];

    final dataRows =
        users.map((user) {
          return TableRow(
            children: [
              CommonTableCell(
                user.name,
                bold: true,
                color: const Color(0xFF1E3A8A),
                align: TextAlign.center,
              ),
              CommonTableCell(user.email, align: TextAlign.center),
              CommonTableCell(user.phone, align: TextAlign.center),
              CommonTableCell(
                user.birthday != null ? dateFormat.format(user.birthday!) : '—',
                align: TextAlign.center,
              ),
              CommonTableCell(
                user.role,
                color:
                    user.role == 'admin'
                        ? Colors.red.shade700
                        : user.role == 'teacher'
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                align: TextAlign.center,
              ),
              CommonTableCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      user.isActive ? Icons.check_circle : Icons.block,
                      size: 16,
                      color: user.isActive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        user.isActive ? 'Hoạt động' : 'Bị khóa',
                        style: TextStyle(
                          color:
                              user.isActive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                          fontSize: 13, // Giảm font size một chút
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
                      icon: Icons.edit_note_rounded,
                      color: Colors.blue.shade600,
                      tooltip: 'Sửa',
                      onPressed: () => onEdit(user),
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon:
                          user.isActive ? Icons.lock_outline : Icons.lock_open,
                      color: Colors.orange.shade600,
                      tooltip: user.isActive ? 'Khóa tài khoản' : 'Mở khóa',
                      onPressed: () async {
                        final confirmed = await showToggleUserDialog(
                          context: context,
                          user: user,
                        );
                        if (confirmed == true) {
                          onToggleStatus(user);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionIconButton(
                      icon: Icons.card_giftcard,
                      color: Colors.pink,
                      tooltip: 'Trao quà',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => UserRedemptionDialog(user: user),
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
