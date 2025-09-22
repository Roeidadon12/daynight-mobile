import 'package:day_night/models/events_response.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

class EventGalleryItem extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const EventGalleryItem({
    super.key,
    required this.event,
    this.onTap,
    this.width = 300,
    this.height = 200,
  });

  Widget _buildDefaultImage() {
    return Image.asset(
      kDefaultEventImage,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              SizedBox(
                width: width,
                height: height,
                child: Image.network(
                  event.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return _buildDefaultImage();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
