import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/screens/admin/gift_redemption/user_redemption_view_model.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:provider/provider.dart';

class UserRedemptionDialog extends StatefulWidget {
  final UserModel user;

  const UserRedemptionDialog({super.key, required this.user});

  @override
  State<UserRedemptionDialog> createState() => _UserRedemptionDialogState();
}

class _UserRedemptionDialogState extends State<UserRedemptionDialog> {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color backgroundBlue = Color(0xFFF3F8FF);

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

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            decoration: BoxDecoration(
              color: backgroundBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.card_giftcard,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Kho quà: ${widget.user.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user.email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child:
                        isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryBlue,
                              ),
                            )
                            : list.isEmpty
                            ? const CommonEmptyState(
                              title: 'Chưa có quà nào',
                              subtitle: 'Học viên này chưa đổi quà lần nào.',
                              icon: Icons.history,
                            )
                            : ListView.separated(
                              itemCount: list.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = list[index];
                                final isPending = item.status == "PENDING";

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          isPending
                                              ? Colors.amber.shade200
                                              : Colors.green.shade200,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isPending
                                                ? Colors.amber
                                                : Colors.green)
                                            .withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Status Icon
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors:
                                                  isPending
                                                      ? [
                                                        Colors.amber.shade400,
                                                        Colors.amber.shade600,
                                                      ]
                                                      : [
                                                        Colors.green.shade400,
                                                        Colors.green.shade600,
                                                      ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            isPending
                                                ? Icons.pending_actions
                                                : Icons.check_circle,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Gift Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.giftName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E3A8A),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      'Đổi: ${DateFormat('dd/MM/yyyy HH:mm').format(item.redeemedAt)}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey[600],
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (item.completedAt != null) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      size: 14,
                                                      color: Colors.green[700],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        'Trao: ${DateFormat('dd/MM/yyyy HH:mm').format(item.completedAt!)}',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.green[700],
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),

                                        // Action Button
                                        if (isPending)
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryBlue,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              viewModel.confirmRedemption(
                                                item.id,
                                                widget.user.id,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.card_giftcard,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Trao quà',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.green.shade50,
                                                  Colors.green.shade100,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.green.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 16,
                                                  color: Colors.green[800],
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Đã nhận',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.green[800],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: primaryBlue.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
