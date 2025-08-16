import 'package:flutter/material.dart';
import '../../models/event.dart';

class EventGalleryItem extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final double heightFactor;

  const EventGalleryItem({
    super.key,
    required this.event,
    this.onTap,
    this.heightFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final double baseHeight = 200;
    final double imageHeight = baseHeight * heightFactor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (event.thumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  event.thumbnailUrl!,
                  height: imageHeight,
                  width: 200,
                  fit: BoxFit.cover,
                  cacheWidth: 400, // adjust as needed
                  cacheHeight: (imageHeight * 1.2).toInt(),
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60),
                ),
              )
            else
              SizedBox(height: imageHeight * 0.6, child: const Icon(Icons.image, size: 60)),
            const SizedBox(height: 8), // Separation between image and title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                event.information?['title'] ?? 'No Title',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
