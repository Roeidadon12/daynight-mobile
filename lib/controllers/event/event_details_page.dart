import 'package:day_night/controllers/event/horizontal_related_event_gallery.dart';
import 'package:day_night/controllers/event/organizer/organizer_info_card.dart';
import 'package:day_night/models/events.dart';
import 'package:day_night/utils/slide_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../shared/flip_card.dart';
import '../../app_localizations.dart';
import '../../constants.dart';
import '../shared/custom_app_bar.dart';
import '../shared/primary_button.dart';
import '../shared/address_map_widget.dart';
import 'package:day_night/controllers/checkout/checkout_tickets.dart';
import 'package:day_night/services/event_service.dart';
import 'package:day_night/models/event_details.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool isLiked = false;
  EventDetails? eventDetails;
  bool isLoading = true;

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
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      isLoading = true;
    });
    
    final eventService = EventService();
    final details = await eventService.getEventById(kAppLanguageId, widget.event.id);
    
    if (mounted) {
      setState(() {
        eventDetails = details;
        isLoading = false;
      });
    }
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

              // Show loading or content
              Expanded(
                child: isLoading 
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kBrandPrimary),
                      ),
                    )
                  : CustomScrollView(
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
                          background: FlipCard(
                            height: MediaQuery.of(context).size.width,
                            front: ClipRRect(
                              child: Stack(
                                children: [
                                  Image.network(
                                    eventDetails!.eventInformation.coverImage,
                                    fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.width,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => 
                                      Image.asset(
                                        kDefaultEventImage,
                                        fit: BoxFit.cover,
                                      ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    bottom: 16,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(120),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.touch_app,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            back: Container(
                              color: kMainBackgroundColor,
                              height: MediaQuery.of(context).size.width,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Html(
                                    data: eventDetails!.eventInformation.description,
                                    style: {
                                      "body": Style(
                                        color: Colors.white,
                                        fontSize: FontSize(14.0),
                                        margin: Margins.all(0),
                                        padding: HtmlPaddings.all(0),
                                      ),
                                      "p": Style(
                                        margin: Margins.all(0),
                                        padding: HtmlPaddings.all(0),
                                      ),
                                      "a": Style(
                                        color: kBrandPrimary,
                                      ),
                                    },
                                  ),
                                ),
                              ),
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
                              eventDetails!.eventInformation.title,
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
                                        eventDetails!.eventInformation.startDate,
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
                                          side: BorderSide(
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
                                          eventDetails!.eventInformation.address,
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
                                          side: BorderSide(
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
                                PrimaryButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      SlidePageRoute(
                                        page: CheckoutTicketsPage(
                                          event: widget.event,
                                          eventDetails: eventDetails!,
                                        ),
                                      ),
                                    );
                                  },
                                  textKey: 'to-buy-ticket',
                                  trailingIcon: Icons.arrow_forward,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Address and Map
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AddressMapWidget(
                                  address: eventDetails!.eventInformation.address,
                                  height: 200,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  eventDetails!.eventInformation.address,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            // Organizer Info
                            OrganizerInfoCard(
                              organizer: eventDetails!.organizer,
                            ),

                            HorizontalRelatedEventGallery(
                              events: eventDetails!.relatedEvents,
                              itemSize: 150,
                              onEventTap: (event) {},
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
