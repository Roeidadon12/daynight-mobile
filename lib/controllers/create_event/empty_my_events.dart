import 'package:flutter/material.dart';
import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/create_event/new_event_pages/new_event.dart';

class EmptyMyEvents extends StatelessWidget {
  const EmptyMyEvents({super.key});

  @override
  Widget build(BuildContext context) {
    const double imageWidth = 400;
    const double imageHeight = 300;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Empty Events Image
            Image.asset(
              'assets/images/create_event.png',
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon if image doesn't exist
                return Container(
                  width: imageWidth,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_note,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Empty State Title
            Text(
              AppLocalizations.of(context).get('no-events-available'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Empty State Message
            Text(
              AppLocalizations.of(context).get('create-first-event'),
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Create New Event Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewEventPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).get('create-event'),
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
    );
  }
}
