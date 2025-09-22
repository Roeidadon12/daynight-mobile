import 'package:day_night/constants.dart';
import 'package:day_night/controllers/event/event_summary_tile.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/controllers/shared/primary_button.dart';
import 'package:day_night/controllers/ticket/list_tickets.dart';
import 'package:day_night/models/events.dart';
import 'package:day_night/models/event_details.dart';
import 'package:day_night/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutTicketsPage extends StatefulWidget {
  final Event event;

  const CheckoutTicketsPage({super.key, required this.event});

  @override
  State<CheckoutTicketsPage> createState() => _CheckoutTicketsPageState();
}

class _CheckoutTicketsPageState extends State<CheckoutTicketsPage> {
  EventDetails? eventDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kMainBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              /// Top App Bar
              CustomAppBar(
                titleKey: 'buy-tickets',
                onBackPressed: () => Navigator.pop(context),
              ),

              /// Main content (summary + list)
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : eventDetails == null
                        ? const Center(child: Text('Failed to load event details'))
                        : ListView(
                            children: [
                              EventSummaryTile(event: widget.event),
                              ...eventDetails!.tickets.map(
                                (ticket) => ListTickets(
                                  ticket: ticket,
                                ),
                              ),
   
                            ],
                          ),
              ),

              /// Bottom Button
              if (!isLoading && eventDetails != null)
                Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: () {
                      // Handle button press
                      print('Proceed to payment');
                    },
                    textKey: 'proceed-to-payment',
                    trailingIcon: Icons.arrow_forward,
                    flexible: false,
                    height: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
