import 'package:flutter/material.dart';

class MediaImageCard extends StatelessWidget {
  const MediaImageCard({
    required this.height,
    required this.imagePath,
    this.overlay,
    super.key,
  });

  final double height;
  final String imagePath;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            imagePath,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: overlay == null ? 0 : 0.18),
              ),
            ),
          ),
          ?overlay,
        ],
      ),
    );
  }
}
