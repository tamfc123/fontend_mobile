import 'package:flutter/material.dart';

class BaseDashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding; // Make nullable to allow responsive override

  const BaseDashboardCard({
    super.key,
    required this.child,
    this.padding, // Remove default, will be set in build
  });

  @override
  Widget build(BuildContext context) {
    // Responsive default padding
    final defaultPadding =
        MediaQuery.of(context).size.width < 600
            ? const EdgeInsets.all(16) // Mobile
            : const EdgeInsets.all(24); // Desktop/Tablet

    return Container(
      width: double.infinity,
      padding: padding ?? defaultPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width < 600 ? 12 : 16,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
