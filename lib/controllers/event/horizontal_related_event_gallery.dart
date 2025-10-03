import 'package:day_night/models/related_event.dart';
import 'package:flutter/material.dart';
import 'package:day_night/constants.dart';
import '../shared/event_empty_state.dart';
import '../shared/horizontal_refresh_indicator.dart';
import '../../app_localizations.dart';

class HorizontalRelatedEventGallery extends StatefulWidget {
  final List<RelatedEvent> events;
  final void Function(RelatedEvent event)? onEventTap;
  final double itemSize;  // Single dimension for square aspect ratio
  final String? title; 
  final String? subtitle;
  final String? emptyStateMessage;
  final String? emptyStateTitle;
  final Future<void> Function()? onRefresh;

  const HorizontalRelatedEventGallery({
    super.key,
    required this.events,
    this.onEventTap,
    required this.itemSize,  // Default square size
    this.title, 
    this.subtitle,
    this.emptyStateMessage,
    this.emptyStateTitle,
    this.onRefresh,
  });

  @override
  State<HorizontalRelatedEventGallery> createState() => _HorizontalRelatedEventGalleryState();
}


class _HorizontalRelatedEventGalleryState extends State<HorizontalRelatedEventGallery> {
  late final PageController _pageController;

  //bool _isAtFirstPage = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.55);
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    // Remove unnecessary setState call - this was causing performance issues
    // The page change is handled by the child widget's own state management
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Container dimensions based on item size plus padding
    final containerHeight = (widget.itemSize * 1.3) + 30;  // Accommodate taller items
    final containerWidth = MediaQuery.of(context).size.width;  // Full width of the screen

    if (widget.events.isEmpty) {
      return SizedBox(
        height: containerHeight,
        width: containerWidth,
        child: EventEmptyState(
          message: widget.emptyStateMessage ?? AppLocalizations.of(context).get('no-events-available'),
          title: widget.emptyStateTitle,
        ),
      );
    }
    
    Widget content = _HorizontalEventGalleryWithDots(
      events: widget.events,
      onEventTap: widget.onEventTap,
      size: widget.itemSize,
      pageController: _pageController,
    );

    if (widget.onRefresh != null) {
      content = HorizontalRefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: kBrandPrimary,
        child: content,
      );
    }

    return SizedBox(
      height: containerHeight,
      width: containerWidth,
      child: content,
    );
  }
}

class _HorizontalEventGalleryWithDots extends StatefulWidget {
  final List<RelatedEvent> events;
  final void Function(RelatedEvent event)? onEventTap;
  final double size;
  final PageController pageController;

  const _HorizontalEventGalleryWithDots({
    required this.events,
    this.onEventTap,
    required this.size,
    required this.pageController,
  });

  @override
  State<_HorizontalEventGalleryWithDots> createState() => _HorizontalEventGalleryWithDotsState();
}

class _HorizontalEventGalleryWithDotsState extends State<_HorizontalEventGalleryWithDots> {
  int _currentPage = 0;

  // Performance optimized event card builder
  Widget _buildEventCard(RelatedEvent event, double size) {
    return SizedBox(
      width: size,
      height: size * 1.5, // Make item 30% taller
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image container at top center - keeping original size
          AspectRatio(
            aspectRatio: 1.0, // Ensure perfect square
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51), // 0.2 * 255 ≈ 51
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Optimized image loading
                    Image.network(
                      event.thumbnail,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withAlpha(179)], // 0.7 * 255 ≈ 179
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
          
          // Extra space below the image
          Expanded(
            child: Container(
              width: size,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Additional content can be added here
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.country != null && event.country != '') ...[
                    const SizedBox(height: 4),
                    Text(
                      event.country,
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



@override
void didUpdateWidget(covariant _HorizontalEventGalleryWithDots oldWidget) {
  super.didUpdateWidget(oldWidget);

  // If events list changed, try to reset current page safely
  if (widget.events.length != oldWidget.events.length) {
    // Wait for next frame to ensure PageView is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final hasClients = widget.pageController.hasClients;
      if (hasClients) {
        final page = widget.pageController.page?.round() ?? 0;
        if (page >= widget.events.length) {
          widget.pageController.jumpToPage(0);
          setState(() {
            _currentPage = 0;
          });
        }
      }
    });
  }
}

@override
Widget build(BuildContext context) {
  // Prevent negative or invalid clamp if there are no events
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      
      // PageView for horizontal scrolling - Optimized
      Expanded(
        child: PageView.builder(
          controller: widget.pageController,
          onPageChanged: (index) {
            if (_currentPage != index) {
              setState(() {
                _currentPage = index;
              });
            }
          },
          itemCount: widget.events.length,
          itemBuilder: (context, index) {
            final event = widget.events[index];
            return Container(
              child: Center(
                child: GestureDetector(
                  onTap: () => widget.onEventTap?.call(event),
                  child: _buildEventCard(event, widget.size),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

}
