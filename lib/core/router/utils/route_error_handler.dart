import 'package:flutter/material.dart';

/// Centralized error handler for routing errors
class RouteErrorHandler {
  /// Creates an error screen for missing data
  static Widget buildMissingDataError(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lỗi'), backgroundColor: Colors.red),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Lỗi dữ liệu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Builder(
                builder:
                    (context) => ElevatedButton.icon(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Validates that the extra data is not null and is of the expected type
  static T? validateExtra<T>(Object? extra, String errorMessage) {
    if (extra == null) {
      return null;
    }
    if (extra is T) {
      return extra as T;
    }
    return null;
  }

  /// Creates an error screen with a custom widget
  static Widget buildCustomError({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.error_outline,
    Color color = Colors.red,
    VoidCallback? onBackPressed,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: color),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 64),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed:
                    onBackPressed ??
                    () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
