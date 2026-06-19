import 'package:flutter/material.dart';

class MediaImageCard extends StatelessWidget {
  const MediaImageCard({
    required this.height,
    required this.imagePath,
    this.imageUrl,
    this.overlay,
    super.key,
  });

  final double height;
  final String imagePath;
  final String? imageUrl;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (url != null && url.isNotEmpty)
            Image.network(
              url,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  _AssetImageFallback(height: height, imagePath: imagePath),
            )
          else
            _AssetImageFallback(height: height, imagePath: imagePath),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: overlay == null ? 0 : 0.18,
                ),
              ),
            ),
          ),
          ?overlay,
        ],
      ),
    );
  }
}

class _AssetImageFallback extends StatelessWidget {
  const _AssetImageFallback({required this.height, required this.imagePath});

  final double height;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
