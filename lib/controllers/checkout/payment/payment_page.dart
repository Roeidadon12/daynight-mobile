import 'package:flutter/material.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/app_localizations.dart';
import 'package:day_night/controllers/checkout/checkout_tickets.dart';
import 'package:day_night/models/ticket_item.dart';
  
class PaymentPage extends StatefulWidget {
  final CheckoutTickets orderInfo;
  final List<(TicketItem, int)> flattenedTickets;

  const PaymentPage({super.key, required this.orderInfo, required this.flattenedTickets});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
    double get totalAmount {
    return widget.flattenedTickets.fold(0.0, (sum, ticketItem) {
      final (ticket, _) = ticketItem;
      final price = double.tryParse(ticket.ticket.price ?? '0') ?? 0.0;
      return sum + price;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                CustomAppBar(
                  titleKey: 'buy-tickets',
                  onBackPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Payment Page Content Here',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kMainBackgroundColor.withAlpha(0),
                      kMainBackgroundColor.withAlpha(204), // 0.8 * 255 = 204
                      kMainBackgroundColor,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle payment action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandPrimary,
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: kBrandPrimary,
                          width: 2,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '${AppLocalizations.of(context).get('to-payment-of')} ${totalAmount.toStringAsFixed(2)} ₪',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}