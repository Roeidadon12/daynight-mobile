import 'package:flutter/material.dart';
import '../../models/event.dart';
import 'event_gallery_item.dart';
import 'package:day_night/constants.dart';

class HorizontalEventGallery extends StatefulWidget {
  final List<Event> events;
  final void Function(Event event)? onEventTap;
  final double height;
  final String? title; 
  final String? subtitle;

  const HorizontalEventGallery({
    super.key,
    required this.events,
    this.onEventTap,
    this.height = 160,
    this.title, 
    this.subtitle, 
  });

  @override
  State<HorizontalEventGallery> createState() => _HorizontalEventGalleryState();
}


class _HorizontalEventGalleryState extends State<HorizontalEventGallery> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height * 1.5 + 120,
      width: widget.height * 1.5 + 120,
      child: _HorizontalEventGalleryWithDots(
        events: widget.events,
        onEventTap: widget.onEventTap,
        height: widget.height,
        pageController: _pageController,
      ),
    );
  }
}

class _HorizontalEventGalleryWithDots extends StatefulWidget {
  final List<Event> events;
  final void Function(Event event)? onEventTap;
  final double height;
  final PageController pageController;

  const _HorizontalEventGalleryWithDots({
    required this.events,
    this.onEventTap,
    required this.height,
    required this.pageController,
  });

  @override
  State<_HorizontalEventGalleryWithDots> createState() => _HorizontalEventGalleryWithDotsState();
}

class _HorizontalEventGalleryWithDotsState extends State<_HorizontalEventGalleryWithDots> {
  int _currentPage = 0;

  late final PageController _internalController;

@override
void initState() {
  super.initState();
  _internalController = widget.pageController;
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
  final clampedPage = widget.events.isEmpty ? 0 : _currentPage.clamp(0, widget.events.length - 1);
  
  return Column(
    children: [
      Expanded(
        child: PageView.builder(
          controller: widget.pageController,
          itemCount: widget.events.length,
          onPageChanged: (int index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            // The active event is the one closest to the center (current page)
            final isActive = (index == _currentPage);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0,  horizontal: 8.0),
              child: AnimatedScale(
                scale: isActive ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: EventGalleryItem(
                  event: widget.events[index],
                  onTap: widget.onEventTap != null ? () => widget.onEventTap!(widget.events[index]) : null,
                  heightFactor: 1.0,
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      
      // Event label/title
      if (widget.events.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Column(
              key: ValueKey(clampedPage),
              children: [
                Text(
                  widget.events[clampedPage].title, // Assuming your Event model has a title property
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      widget.events[clampedPage].eventLocationDateTime,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(179),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      
      const SizedBox(height: 16),
      
      // Page indicator dots
      if (widget.events.isNotEmpty)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.events.length, (index) {
            final isActive = clampedPage == index;
            return GestureDetector(
              onTap: () {
                widget.pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 8, // Fixed width
                height: 8, // Fixed height
                decoration: BoxDecoration(
                  color: isActive ? Theme.of(context).colorScheme.primary : kBrandPrimaryInvert,
                  borderRadius: BorderRadius.circular(4), // Adjusted for square/rounded square
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.white.withAlpha(102),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
              ),
            );
          }),
        ),
    ],
  );
}


}
