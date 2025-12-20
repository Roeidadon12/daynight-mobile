import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../../main.dart';

class NewEventStep4 extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final VoidCallback onComplete;

  const NewEventStep4({
    super.key,
    required this.eventData,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                              MediaQuery.of(context).padding.top - 
                              140, // Subtract button area height
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    // Enjoy Image with Text Overlay - exactly like PaymentSuccessPage
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
                              // Image (same as PaymentSuccessPage)
                              Image.asset(
                                'assets/images/enjoy.png', // Same image as PaymentSuccessPage
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
                                    child: const Center(
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
                      AppLocalizations.of(context).get('event-created-successfully'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      AppLocalizations.of(context).get('event-is-now-live'),
                        style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Success Message
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context).get('event-is-live-our-turn'),
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
            
            // Bottom Buttons - exactly like PaymentSuccessPage
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Main Button - goes to main screen
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(
                              title: AppLocalizations.of(context).get('day_night_home'),
                            ),
                          ),
                          (route) => false, // Remove all previous routes
                        );
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
                        AppLocalizations.of(context).get('to-main-screen'),
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