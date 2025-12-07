import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';

class ConfirmToggleStatusDialog extends StatefulWidget {
  final UserModel user;

  const ConfirmToggleStatusDialog({super.key, required this.user});

  @override
  State<ConfirmToggleStatusDialog> createState() =>
      _ConfirmToggleStatusDialogState();
}

class _ConfirmToggleStatusDialogState extends State<ConfirmToggleStatusDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    setState(() => _isProcessing = true);

    // Delay nhỏ để hiển thị loading
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  double _getTitleFontSize(BuildContext context) {
    return _isMobile(context) ? 18.0 : 20.0;
  }

  double _getContentFontSize(BuildContext context) {
    return _isMobile(context) ? 15.0 : 16.0;
  }

  double _getPadding(BuildContext context) {
    return _isMobile(context) ? 20.0 : 24.0;
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.user.isActive;
    final action = isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản';
    final actionVerb = isActive ? 'khóa' : 'mở khóa';
    final color = isActive ? Colors.orange : Colors.green;
    final icon = isActive ? Icons.lock_outline : Icons.lock_open_rounded;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: BoxConstraints(
                  maxWidth: _isMobile(context) ? 400 : 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header với màu gradient
                    Container(
                      padding: EdgeInsets.all(_getPadding(context)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.shade400, color.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(icon, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  action,
                                  style: TextStyle(
                                    fontSize: _getTitleFontSize(context),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Xác nhận thay đổi trạng thái',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(_getPadding(context)),
                      child: Column(
                        children: [
                          // Icon lớn
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(icon, size: 48, color: color.shade400),
                          ),
                          const SizedBox(height: 20),

                          // Content text
                          Text(
                            'Bạn có chắc muốn $actionVerb tài khoản này?',
                            style: TextStyle(
                              fontSize: _getContentFontSize(context),
                              color: const Color(0xFF424242),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          // User info
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F7FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFF1976D2,
                                ).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 20,
                                  color: const Color(0xFF1976D2),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.user.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1976D2),
                                        ),
                                      ),
                                      Text(
                                        widget.user.email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(
                                            0xFF1976D2,
                                          ).withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Warning message
                          if (isActive) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Người dùng sẽ không thể đăng nhập sau khi bị khóa',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Action buttons
                    Container(
                      padding: EdgeInsets.all(_getPadding(context)),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFBFF),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  _isProcessing
                                      ? null
                                      : () => Navigator.pop(context, false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: Color(0xFF1976D2),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Hủy',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : _handleConfirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isProcessing
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
                                      : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(icon, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            actionVerb
                                                    .substring(0, 1)
                                                    .toUpperCase() +
                                                actionVerb.substring(1),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
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

// Helper function to show the dialog
Future<bool?> showToggleUserDialog({
  required BuildContext context,
  required UserModel user,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => ConfirmToggleStatusDialog(user: user),
  );
}
