import 'package:flutter/material.dart';

class AppData {
  // Updated gentle color palette for posters
  static List<Color> get randomPosterBgColors => [
        // Light gradient colors (subtle, modern)
        const Color(0xFFE3F2FD), // Light Blue
        const Color(0xFFF3E5F5), // Light Purple
        const Color(0xFFE8F5E9), // Light Green
        const Color(0xFFFFF3E0), // Light Orange
        const Color(0xFFFCE4EC), // Light Pink
        const Color(0xFFF1F8E9), // Very Light Green
        const Color(0xFFE0F7FA), // Light Cyan
        const Color(0xFFEDE7F6), // Light Indigo
        const Color(0xFFFFEBEE), // Light Red
        const Color(0xFFE8F5E8), // Mint Green
        const Color(0xFFF5F5F5), // Light Gray
        const Color(0xFFF9FBE7), // Light Lime
      ];

  // Gentle gradient generators
  static LinearGradient getLightBlueGradient() {
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        const Color(0xFFE3F2FD).withOpacity(0.9),
        const Color(0xFFBBDEFB).withOpacity(0.7),
        const Color(0xFF90CAF9).withOpacity(0.5),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  static LinearGradient getLightPurpleGradient() {
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        const Color(0xFFF3E5F5).withOpacity(0.9),
        const Color(0xFFE1BEE7).withOpacity(0.7),
        const Color(0xFFCE93D8).withOpacity(0.5),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  static LinearGradient getLightGreenGradient() {
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        const Color(0xFFE8F5E9).withOpacity(0.9),
        const Color(0xFFC8E6C9).withOpacity(0.7),
        const Color(0xFFA5D6A7).withOpacity(0.5),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  static LinearGradient getLightOrangeGradient() {
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        const Color(0xFFFFF3E0).withOpacity(0.9),
        const Color(0xFFFFE0B2).withOpacity(0.7),
        const Color(0xFFFFCC80).withOpacity(0.5),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  static LinearGradient getRandomPosterGradient(int index) {
    final gradients = [
      getLightBlueGradient,
      getLightPurpleGradient,
      getLightGreenGradient,
      getLightOrangeGradient,
    ];
    return gradients[index % gradients.length]();
  }

  // Wave-like gradient (diagonal wave effect)
  static LinearGradient getWaveGradient(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        baseColor.withOpacity(0.9),
        baseColor.withOpacity(0.7),
        baseColor.withOpacity(0.5),
        baseColor.withOpacity(0.3),
        baseColor.withOpacity(0.5),
        baseColor.withOpacity(0.7),
      ],
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
    );
  }

  // Modern color combinations - Fixed to return List<List<Color>>
  static List<List<Color>> get modernColorPairs => [
        [const Color(0xFFE3F2FD), const Color(0xFF64B5F6)], // Blue pair
        [const Color(0xFFF3E5F5), const Color(0xFFBA68C8)], // Purple pair
        [const Color(0xFFE8F5E9), const Color(0xFF81C784)], // Green pair
        [const Color(0xFFFFF3E0), const Color(0xFFFFB74D)], // Orange pair
        [const Color(0xFFFCE4EC), const Color(0xFFF06292)], // Pink pair
      ];

  // Get a random gentle gradient
  static LinearGradient getRandomGentleGradient() {
    final gentleColors = [
      const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFE8F5E9), // Light Green
      const Color(0xFFFFF3E0), // Light Orange
      const Color(0xFFFCE4EC), // Light Pink
    ];

    final baseColor =
        gentleColors[DateTime.now().millisecond % gentleColors.length];

    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        baseColor,
        baseColor.withOpacity(0.8),
        baseColor.withOpacity(0.6),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // Get poster background based on index
  static BoxDecoration getPosterDecoration(int index) {
    final gradients = [
      getLightBlueGradient(),
      getLightPurpleGradient(),
      getLightGreenGradient(),
      getLightOrangeGradient(),
      getWaveGradient(const Color(0xFFFCE4EC)), // Pink wave
      getWaveGradient(const Color(0xFFE0F7FA)), // Cyan wave
    ];

    return BoxDecoration(
      gradient: gradients[index % gradients.length],
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
