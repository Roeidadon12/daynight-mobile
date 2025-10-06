import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../../models/organizer.dart';
import '../../../constants.dart';
import '../../../app_localizations.dart';

class OrganizerContactPicker extends StatelessWidget {
  final Organizer organizer;

  const OrganizerContactPicker({
    super.key,
    required this.organizer,
  });

  static void show(BuildContext context, Organizer organizer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OrganizerContactPicker(organizer: organizer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = organizer.phone.isNotEmpty;
    final hasEmail = organizer.email.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Organizer photo section
            if (organizer.hasPhoto) ...[
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kBrandPrimary.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    organizer.photoUrl!,
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultAvatar(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              const SizedBox(height: 20),
              _buildDefaultAvatar(),
              const SizedBox(height: 12),
            ],
            
            // Organizer name
            Text(
              organizer.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              AppLocalizations.of(context).get('event-organizer'),
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Contact options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (hasPhone) ...[
                    FutureBuilder<bool>(
                      future: _isWhatsAppInstalled(),
                      builder: (context, snapshot) {
                        final isWhatsAppInstalled = snapshot.data ?? false;
                        
                        if (!isWhatsAppInstalled) {
                          return const SizedBox.shrink();
                        }
                        
                        return _buildContactOption(
                          context: context,
                          icon: Icons.chat,
                          title: AppLocalizations.of(context).get('send-whatsapp'),
                          subtitle: organizer.fullPhoneNumber,
                          onTap: () => _sendWhatsAppMessage(context, organizer.fullPhoneNumber),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  if (hasEmail) ...[
                    _buildContactOption(
                      context: context,
                      icon: Icons.email,
                      title: AppLocalizations.of(context).get('send-email'),
                      subtitle: organizer.email,
                      onTap: () => _sendEmail(context, organizer.email),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // If no contact options available
                  if (!hasPhone && !hasEmail) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[300],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).get('no-contact-info'),
                              style: TextStyle(
                                color: Colors.orange[300],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[600],
        border: Border.all(
          color: kBrandPrimary.withAlpha(100),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey[300],
        size: 32,
      ),
    );
  }

  Widget _buildContactOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kBrandPrimary.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: kBrandPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _isWhatsAppInstalled() async {
    // For now, we'll assume WhatsApp is available on mobile platforms
    // In a production app, you would want to use url_launcher's canLaunchUrl
    // or implement platform-specific detection
    return Platform.isAndroid || Platform.isIOS;
  }

  void _sendWhatsAppMessage(BuildContext context, String phoneNumber) async {
    Navigator.pop(context);
    
    try {
      // Clean the phone number (remove spaces, dashes, etc.)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Create WhatsApp URL
      final whatsappUrl = 'whatsapp://send?phone=$cleanNumber';
      
      // For now, show a dialog with instructions since we don't have url_launcher
      // In production, you would use: await launchUrl(Uri.parse(whatsappUrl));
      _showWhatsAppInstructions(context, cleanNumber, whatsappUrl);
      
    } catch (e) {
      // Show error dialog
      _showWhatsAppError(context, phoneNumber);
    }
  }

  void _showWhatsAppInstructions(BuildContext context, String phoneNumber, String whatsappUrl) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF111111),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.chat, color: kBrandPrimary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Open WhatsApp',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WhatsApp URL ready:',
                  style: TextStyle(color: Colors.grey[300]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    whatsappUrl,
                    style: TextStyle(
                      color: kBrandPrimary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Phone: $phoneNumber',
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Clipboard.setData(ClipboardData(text: phoneNumber));
                },
                child: Text(
                  'Copy Number',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Clipboard.setData(ClipboardData(text: whatsappUrl));
                },
                child: Text(
                  'Copy URL',
                  style: TextStyle(color: kBrandPrimary),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _showWhatsAppError(BuildContext context, String phoneNumber) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF111111),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'WhatsApp Not Available',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Could not open WhatsApp. Phone number: $phoneNumber',
              style: TextStyle(color: Colors.grey[300]),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Clipboard.setData(ClipboardData(text: phoneNumber));
                },
                child: Text(
                  'Copy Number',
                  style: TextStyle(color: kBrandPrimary),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _sendEmail(BuildContext context, String email) async {
    Navigator.pop(context);
    
    // Copy email to clipboard and show dialog
    await Clipboard.setData(ClipboardData(text: email));
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF111111),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              AppLocalizations.of(context).get('email-copied'),
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              '${AppLocalizations.of(context).get('email-address-copied')}\n$email',
              style: TextStyle(color: Colors.grey[300]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context).get('ok'),
                  style: TextStyle(color: kBrandPrimary),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}