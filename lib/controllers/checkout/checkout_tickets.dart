import 'package:day_night/constants.dart';
import 'package:day_night/controllers/event/event_summary_tile.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/controllers/shared/primary_button.dart';
import 'package:day_night/controllers/checkout/ticket/list_tickets.dart';
import 'package:day_night/controllers/checkout/checkout_tickets_controller.dart';
import 'package:day_night/models/events.dart';
import 'package:day_night/models/event_details.dart';
import 'package:day_night/models/ticket.dart';
import 'package:day_night/models/ticket_item.dart';
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
  late CheckoutTicketsController orderInfo;
  final Map<String, TicketItem> selectedTickets = {};

  void _handleTicketSelection(Ticket? selectedTicket, int amount) {
    if (selectedTicket != null) {
      final ticketId = selectedTicket.id.toString();
      
      if (amount > 0) {
        // Create or update ticket item
        final ticketItem = TicketItem(
          id: ticketId,
          ticket: selectedTicket,
          quantity: amount
        );
        
        setState(() {
          selectedTickets[ticketId] = ticketItem;
          // Update basket with all current tickets
          orderInfo.currentBasket.addTickets(selectedTickets.values.toList());
        });
      } else {
        // Remove ticket if amount is 0
        setState(() {
          selectedTickets.remove(ticketId);
          if (selectedTickets.isEmpty) {
            orderInfo.resetBasket();
          } else {
            // Update basket with remaining tickets
            orderInfo.currentBasket.addTickets(selectedTickets.values.toList());
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    final eventService = EventService();
    final details = await eventService.getEventById(kAppLanguageId, widget.event.id);
    if (mounted && details != null) {
      setState(() {
        eventDetails = details;
        orderInfo = CheckoutTicketsController(eventDetails: details);
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
                              ListTickets(
                                eventDetails: eventDetails!,
                                tickets: eventDetails!.tickets,
                                onTicketSelected: _handleTicketSelection,
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
