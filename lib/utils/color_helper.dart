import 'package:flutter/material.dart';

class ColorHelper {
  // Level configuration
  Map<String, dynamic> getLevelConfig(int level) {
    switch (level) {
      case 1:
        return {
          'name': 'Sơ Cấp', // Beginner
          'color': Colors.teal,
          'gradient': [Colors.teal.shade400, Colors.teal.shade600],
          'icon': Icons.sentiment_satisfied_alt,
        };

      case 2:
        return {
          'name': 'Mới Học', // Elementary
          'color': Colors.green,
          'gradient': [Colors.green.shade400, Colors.green.shade600],
          'icon': Icons.psychology_alt,
        };

      case 3:
        return {
          'name': 'Trung Cấp', // Intermediate
          'color': Colors.blue,
          'gradient': [Colors.blue.shade400, Colors.blue.shade600],
          'icon': Icons.school,
        };

      case 4:
        return {
          'name': 'Trung Cấp Cao', // Upper-Intermediate
          'color': Colors.purple,
          'gradient': [Colors.purple.shade400, Colors.purple.shade600],
          'icon': Icons.emoji_events,
        };

      case 5:
        return {
          'name': 'Nâng Cao', // Advanced
          'color': Colors.orange,
          'gradient': [Colors.orange.shade400, Colors.orange.shade600],
          'icon': Icons.workspace_premium,
        };

      case 6:
        return {
          'name': 'Thành Thạo', // Master
          'color': Colors.amber,
          'gradient': [Colors.amber.shade400, Colors.amber.shade700],
          'icon': Icons.military_tech,
        };

      default:
        return {
          'name': 'Sơ Cấp',
          'color': Colors.grey,
          'gradient': [Colors.grey.shade400, Colors.grey.shade600],
          'icon': Icons.sentiment_satisfied_alt,
        };
    }
  }

  // Calculate XP needed for next level
  int getExpNeededForLevel(int level) {
    switch (level) {
      case 1:
        return 100;
      case 2:
        return 250;
      case 3:
        return 500;
      case 4:
        return 1000;
      case 5:
        return 2000;
      case 6:
        return 0; // Max level
      default:
        return 100;
    }
  }
}
