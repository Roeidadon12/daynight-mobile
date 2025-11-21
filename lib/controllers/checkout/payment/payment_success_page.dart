import 'package:flutter/material.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/app_localizations.dart';

class PaymentSuccessPage extends StatelessWidget {
  final double totalAmount;
  final String eventTitle;
  final int ticketCount;
  final String? transactionId;

  const PaymentSuccessPage({
    super.key,
    required this.totalAmount,
    required this.eventTitle,
    required this.ticketCount,
    this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              titleKey: 'payment-success',
              onBackPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                              MediaQuery.of(context).padding.top - 
                              kToolbarHeight - 
                              140, // Subtract button area height
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    // Enjoy Image with Text Overlay
                    Builder(
                      builder: (context) {
                        const double imageWidth = 300;
                        const double imageHeight = 210;
                        
                        return SizedBox(
                          width: imageWidth,
                          height: imageHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Image (try PNG first, fallback to placeholder)
                              Image.asset(
                                'assets/images/enjoy.png', // Change to .png or .jpg if you have it
                                width: imageWidth,
                                height: imageHeight,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback if image doesn't exist
                                  return Container(
                                    width: imageWidth,
                                    height: imageHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [kBrandPrimary, Colors.purple],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.celebration,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Overlay localized text with rotation - centered positioning
                              Center(
                                child: Transform.rotate(
                                  angle: -0.56, // Rotation to match ticket angle
                                  child: Text(
                                    AppLocalizations.of(context).get('enjoy'),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Colors.black26,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    );
                  },
                ),
                    const SizedBox(height: 20),
                    
                    // Success Title
                    Text(
                      AppLocalizations.of(context).get('purchase-completed-successfully'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Success Message with Enjoy
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context).get('tickets-sent-to-email'),
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  ),
                ),
              ),
            ),
            
            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // View Tickets Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to tickets/orders page
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandPrimary,
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: kBrandPrimary,
                          width: 2,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).get('to-my-tickets'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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