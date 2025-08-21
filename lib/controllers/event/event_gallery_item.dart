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

  Widget _buildDefaultImage() {
    return Image.asset(
      'assets/images/image_place_holder.png',
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: EdgeInsets.zero,

        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: event.thumbnailUrl != null
                  ? Image.network(
                      event.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
                    )
                  : _buildDefaultImage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
