import 'package:flutter/material.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/app_localizations.dart';
import 'package:day_night/controllers/checkout/checkout_tickets.dart';
import 'package:day_night/controllers/checkout/payment/promo_code_controller.dart';
import 'package:day_night/models/ticket_item.dart';
  
class PaymentPage extends StatefulWidget {
  final CheckoutTickets orderInfo;
  final List<(TicketItem, int)> flattenedTickets;

  const PaymentPage({super.key, required this.orderInfo, required this.flattenedTickets});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isPromoCodeLoading = false;
  String? _promoCodeError;
  String? _promoCodeSuccess;

  double get totalAmount {
    return widget.flattenedTickets.fold(0.0, (sum, ticketItem) {
      final (ticket, _) = ticketItem;
      final price = double.tryParse(ticket.ticket.price ?? '0') ?? 0.0;
      return sum + price;
    });
  }

  void _clearPromoCodeMessages() {
    setState(() {
      _promoCodeError = null;
      _promoCodeSuccess = null;
    });
  }

  void _handlePromoCodeApplied(String promoCode) async {
    setState(() {
      _isPromoCodeLoading = true;
      _promoCodeError = null;
      _promoCodeSuccess = null;
    });

    try {
      // TODO: Implement actual promo code validation API call
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate API call
      
      // For now, simulate success for valid promo codes
      if (promoCode.toUpperCase() == 'DN10OFF' || promoCode.toLowerCase() == 'demo') {
        setState(() {
          _promoCodeSuccess = AppLocalizations.of(context).get('coupon-applied-successfully');
          _isPromoCodeLoading = false;
        });
      } else {
        setState(() {
          _promoCodeError = AppLocalizations.of(context).get('invalid-coupon');
          _isPromoCodeLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _promoCodeError = AppLocalizations.of(context).get('invalid-coupon');
        _isPromoCodeLoading = false;
      });
    }
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Promo Code Field - First field in the page
                        PromoCodeField(
                          onPromoCodeApplied: _handlePromoCodeApplied,
                          onTextChanged: _clearPromoCodeMessages,
                          isLoading: _isPromoCodeLoading,
                          errorMessage: _promoCodeError,
                          successMessage: _promoCodeSuccess,
                        ),
                        const SizedBox(height: 24),
                        // TODO: Add other payment fields here
                        Expanded(
                          child: Center(
                            child: Text(
                              'Other Payment Fields Will Go Here',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        ),
                      ],
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