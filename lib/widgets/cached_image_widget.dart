import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImageWidget extends StatelessWidget {
  final String imageUrl;

  const CachedImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      // Show a placeholder while the image is loading
      placeholder: (context, url) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      // Show an error icon if the image fails to load
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.error_outline, color: Colors.redAccent),
      ),
    );
  }
}