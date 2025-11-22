import 'package:flutter/material.dart';

class BaseDashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const BaseDashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24), // Padding mặc định
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
