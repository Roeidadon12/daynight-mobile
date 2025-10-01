import 'package:day_night/constants.dart';
import 'package:day_night/controllers/event/event_summary_tile.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/controllers/shared/primary_button.dart';
import 'package:day_night/controllers/checkout/ticket/list_tickets.dart';
import 'package:day_night/controllers/checkout/checkout_tickets_controller.dart';
import 'package:day_night/controllers/checkout/participant/participant_info_page.dart';
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

  bool hasValidTickets() {
    return selectedTickets.values.any((ticket) => ticket.quantity > 0);
  }

  void _handleTicketSelection(Ticket? selectedTicket, int amount) {
    if (selectedTicket != null) {
      final ticketId = selectedTicket.id.toString();
      
      setState(() {
        // Update or create ticket entry regardless of amount
        if (selectedTickets.containsKey(ticketId)) {
          selectedTickets[ticketId]!.quantity = amount;
        } else {
          selectedTickets[ticketId] = TicketItem(
            id: ticketId,
            ticket: selectedTicket,
            quantity: amount
          );
        }
        
        // Clean up any tickets with zero quantity
        selectedTickets.removeWhere((id, ticket) => ticket.quantity <= 0);
        
        // Update basket based on remaining tickets
        if (selectedTickets.isEmpty || !hasValidTickets()) {
          orderInfo.resetBasket();
        } else {
          orderInfo.currentBasket.addTickets(selectedTickets.values.toList());
        }
      });
    }
    else {
      setState(() {
        // If no ticket is selected, clear all selections
        selectedTickets.clear();
        orderInfo.resetBasket();
      });
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
                      if (hasValidTickets()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParticipantInfoPage(
                              orderInfo: orderInfo,
                            ),
                          ),
                        );
                      }
                    },
                    disabled: !hasValidTickets(),
                    textKey: 'add-items',
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
