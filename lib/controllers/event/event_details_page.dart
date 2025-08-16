import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../app_localizations.dart';
import '../../constants.dart';
import '../shared/custom_app_bar.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool isLiked = false;

  void _handleShare() {
    // TODO: Implement share functionality
  }

  void _handleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    // TODO: Implement like functionality with backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            CustomAppBar(
              titleKey: 'event-details',
              isLiked: isLiked,
              onSharePressed: _handleShare,
              onLikePressed: _handleLike,
            ),
            
            // Scrollable Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Image Header
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: false,
                    automaticallyImplyLeading: false,
                    backgroundColor: kMainBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      background: widget.event.thumbnailUrl != null
                          ? Image.network(
                              widget.event.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey)),
                            )
                          : const Center(child: Icon(Icons.image, size: 60, color: Colors.grey)),
                    ),
                  ),

                  // Event Details
                  SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.event.information?['title'] ?? 'No Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date and Location Row
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Text(
                          widget.event.formattedStartDate,
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.event.location,
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    if (widget.event.information?['description'] != null) ...[
                      Text(
                        AppLocalizations.of(context).get('description'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.event.information!['description'],
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Price Information
                    Text(
                      AppLocalizations.of(context).get('price-info'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.event.price} ${AppLocalizations.of(context).get('currency')}',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Book Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement booking functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).get('book-now'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
