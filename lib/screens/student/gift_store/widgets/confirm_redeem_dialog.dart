import 'package:flutter/material.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/screens/student/gift_store/student_gift_view_model.dart';
import 'package:mobile/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class ConfirmRedeemDialog extends StatefulWidget {
  final GiftModel gift;

  const ConfirmRedeemDialog({super.key, required this.gift});

  @override
  State<ConfirmRedeemDialog> createState() => _ConfirmRedeemDialogState();
}

class _ConfirmRedeemDialogState extends State<ConfirmRedeemDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isRedeeming = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 600;

  double get _getTitleFontSize => _isMobile ? 20 : 24;
  double get _getContentFontSize => _isMobile ? 14 : 16;

  Future<void> _handleRedeem() async {
    setState(() => _isRedeeming = true);

    try {
      final success = await context.read<StudentGiftViewModel>().redeemGift(
        widget.gift.id,
      );

      if (success && mounted) {
        // Cập nhật số dư coins
        await context.read<AuthService>().fetchCurrentUser();

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Đổi quà thành công! Hãy đến quầy lễ tân để nhận quà.',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isRedeeming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: _isMobile ? double.infinity : 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header với gradient
                    Container(
                      padding: EdgeInsets.all(_isMobile ? 20 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.card_giftcard,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Xác nhận đổi quà',
                              style: TextStyle(
                                fontSize: _getTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(_isMobile ? 20 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gift info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bạn muốn dùng ${widget.gift.coinPrice} xu để đổi:',
                                        style: TextStyle(
                                          fontSize: _getContentFontSize - 2,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.gift.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: _getContentFontSize + 2,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Warning note
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Lưu ý: Sau khi đổi, hãy đến quầy lễ tân và đọc tên/email để nhận quà.',
                                    style: TextStyle(
                                      fontSize: _getContentFontSize - 2,
                                      color: Colors.blue.shade700,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        _isMobile ? 20 : 24,
                        0,
                        _isMobile ? 20 : 24,
                        _isMobile ? 20 : 24,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  _isRedeeming
                                      ? null
                                      : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: _getContentFontSize,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isRedeeming ? null : _handleRedeem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isRedeeming
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Đổi ngay',
                                        style: TextStyle(
                                          fontSize: _getContentFontSize,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Helper function to show the dialog
Future<bool?> showRedeemGiftDialog(BuildContext context, GiftModel gift) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ConfirmRedeemDialog(gift: gift),
  );
}
