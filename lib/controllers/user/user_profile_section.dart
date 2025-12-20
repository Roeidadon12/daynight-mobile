import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../constants.dart';
import '../../models/user.dart';
import '../../screens/auth/login_screen.dart';

/// Widget displayed for connected users showing their profile information
class UserProfileSection extends StatelessWidget {
  final User user;
  
  const UserProfileSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Limit the height of the header
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          textDirection: Directionality.of(context),
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: Directionality.of(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.address != null && user.address!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      textDirection: Directionality.of(context),
                      children: [
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.address!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textDirection: Directionality.of(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Profile Action Button
            IconButton(
              onPressed: () {
                // TODO: Navigate to profile/settings page
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white70,
                size: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Profile Picture
            CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              backgroundImage: user.thumbnail != null ? NetworkImage(user.thumbnail!) : null,
              radius: 32,
              child: user.thumbnail == null ? const Icon(Icons.person, size: 32, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget displayed for guest users, prompting them to login for a better experience
class GuestProfileSection extends StatelessWidget {
  const GuestProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Limit the height of the header
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          textDirection: Directionality.of(context),
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context).get('guest-mode'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: Directionality.of(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    textDirection: Directionality.of(context),
                    children: [
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).get('guest-mode-description'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textDirection: Directionality.of(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                AppLocalizations.of(context).get('login'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}