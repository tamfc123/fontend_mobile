import 'package:flutter/material.dart';

class LevelUpRewardDialog extends StatefulWidget {
  final int exp;
  final int coins;
  final String message; // Thêm message động
  final VoidCallback? onClose;

  const LevelUpRewardDialog({
    super.key,
    required this.exp,
    required this.coins,
    this.message = "Bạn đã làm rất tốt!",
    this.onClose,
  });

  @override
  State<LevelUpRewardDialog> createState() => _LevelUpRewardDialogState();
}

class _LevelUpRewardDialogState extends State<LevelUpRewardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Định nghĩa màu cục bộ nếu chưa có AppColors
  static const Color primaryColor = Color(0xFF3B82F6);
  static const Color primaryLightColor = Color(0xFFEFF6FF);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
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
              const Text("🎉", style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text(
                "Tuyệt vời!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Khung chứa XP và Coin
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: primaryLightColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Cột XP
                    Column(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "+${widget.exp} XP",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    // Cột Coin
                    Column(
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "+${widget.coins} Xu",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (widget.onClose != null) widget.onClose!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Tiếp tục"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
