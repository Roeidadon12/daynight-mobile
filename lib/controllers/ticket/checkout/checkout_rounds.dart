import 'package:day_night/constants.dart';
import 'package:day_night/controllers/event/event_summary_tile.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/controllers/shared/primary_button.dart';
import 'package:day_night/controllers/ticket/list_tickets.dart';
import 'package:day_night/models/ticket.dart';
import 'package:day_night/models/events_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutRoundsPage extends StatelessWidget {
  final Event event;

  const CheckoutRoundsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final List<Ticket> tickets = []; //event.tickets ?? [];

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
                child: ListView(
                  children: [
                    EventSummaryTile(event: event),

                    ...tickets.map((t) => ListTickets(ticket: t)),
                  ],
                ),
              ),

              /// Bottom Button
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
