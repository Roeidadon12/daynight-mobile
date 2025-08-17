import 'package:day_night/controllers/ticket/checkout/checkout_rounds.dart';
import 'package:day_night/utils/slide_page_route.dart';
import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../app_localizations.dart';
import '../../constants.dart';
import '../shared/custom_app_bar.dart';
import 'package:flutter/services.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // background behind status bar
        statusBarIconBrightness: Brightness.light, // icons color
        statusBarBrightness: Brightness.light, // iOS top bar
      ), // <-- Forces white status bar icons
      child: Scaffold(
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
                    // Image Header with safe area
                    SliverSafeArea(
                      top: false, // already handled by Scaffold SafeArea
                      sliver: SliverAppBar(
                        expandedHeight: MediaQuery.of(context).size.width,
                        floating: false,
                        pinned: false,
                        automaticallyImplyLeading: false,
                        backgroundColor: kMainBackgroundColor,
                        flexibleSpace: FlexibleSpaceBar(
                          background: widget.event.thumbnailUrl != null
                              ? ClipRRect(
                                  child: Image.network(
                                    widget.event.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
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

                            // Date and Location
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.event.formattedStartDate,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.calendar_today),
                                        label: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).get('add-to-calendar'),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: kBrandPrimary,
                                          side: const BorderSide(
                                            color: kBrandPrimary,
                                            width: 2,
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.event.location,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow
                                              .ellipsis, // or .visible if you want full wrap
                                          maxLines:
                                              2, // remove if you want unlimited wrapping
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ), // spacing between text & button
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.location_on),
                                        label: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).get('navigate-to'),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: kBrandPrimary,
                                          side: const BorderSide(
                                            color: kBrandPrimary,
                                            width: 2,
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Price Information
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${widget.event.price} ${AppLocalizations.of(context).get('currency')}',
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${widget.event.price} ${AppLocalizations.of(context).get('currency')}',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Special offer: Limited time!',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          SlidePageRoute(
                                            page: CheckoutRoundsPage(
                                              event: widget.event,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kBrandPrimary,
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: kBrandPrimary,
                                          width: 2,
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              ).get('to-buy-ticket'),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
