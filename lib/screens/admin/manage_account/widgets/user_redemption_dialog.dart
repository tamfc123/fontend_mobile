import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/screens/admin/manage_account/user_redemption_view_model.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:provider/provider.dart';

class UserRedemptionDialog extends StatefulWidget {
  final UserModel user;

  const UserRedemptionDialog({super.key, required this.user});

  @override
  State<UserRedemptionDialog> createState() => _UserRedemptionDialogState();
}

class _UserRedemptionDialogState extends State<UserRedemptionDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserRedemptionViewModel>().fetchUserRedemptions(
        widget.user.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRedemptionViewModel>(
      builder: (context, viewModel, child) {
        final list = viewModel.redemptions;
        final isLoading = viewModel.isLoading;

        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kho quà: ${widget.user.name}',
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500, // Độ rộng cố định cho đẹp trên Web
            height: 400,
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : list.isEmpty
                    ? const CommonEmptyState(
                      title: 'Chưa có quà nào',
                      subtitle: 'Học viên này chưa đổi quà lần nào.',
                      icon: Icons.history,
                    )
                    : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final isPending = item.status == "PENDING";

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isPending
                                      ? Colors.amber.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isPending
                                  ? Icons.pending_actions
                                  : Icons.check_circle,
                              color:
                                  isPending ? Colors.amber[800] : Colors.green,
                            ),
                          ),
                          title: Text(
                            item.giftName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đổi: ${DateFormat('dd/MM/yyyy HH:mm').format(item.redeemedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (item.completedAt != null)
                                Text(
                                  'Trao: ${DateFormat('dd/MM/yyyy HH:mm').format(item.completedAt!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                  ),
                                ),
                            ],
                          ),
                          trailing:
                              isPending
                                  ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      // Gọi xác nhận trao quà
                                      viewModel.confirmRedemption(
                                        item.id,
                                        widget.user.id,
                                      );
                                    },
                                    child: const Text('Trao quà'),
                                  )
                                  : Chip(
                                    label: const Text(
                                      'Đã nhận',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    backgroundColor: Colors.green[50],
                                    labelStyle: TextStyle(
                                      color: Colors.green[800],
                                    ),
                                  ),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
