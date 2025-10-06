import 'package:flutter/material.dart';
import '../../../models/organizer.dart';
import '../../../constants.dart';
import '../../../app_localizations.dart';
import 'organizer_contact_picker.dart';

class OrganizerInfoCard extends StatelessWidget {
  final Organizer organizer;
  final VoidCallback? onTap;

  const OrganizerInfoCard({
    super.key,
    required this.organizer,
    this.onTap,
  });

  String _getDisplayName(BuildContext context) {
    if (organizer.productionName.isNotEmpty) {
      return organizer.productionName;
    }
    if (organizer.username != null && organizer.username!.isNotEmpty) {
      return organizer.username!;
    }
    return AppLocalizations.of(context).get('organizer');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Organizer info row
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                // Profile image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[600],
                  ),
                  child: organizer.hasPhoto
                      ? ClipOval(
                          child: Image.network(
                            organizer.photoUrl!,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildDefaultAvatar(),
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
                const SizedBox(width: 12),
                
                // Organizer details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (organizer.productionName.isNotEmpty) ...[
                        Text(
                          organizer.productionName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (organizer.username != null && organizer.username!.isNotEmpty) ...[
                        Text(
                          organizer.username!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (organizer.productionName.isEmpty && 
                          (organizer.username == null || organizer.username!.isEmpty)) ...[
                        Text(
                          AppLocalizations.of(context).get('organizer'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Contact button or arrow
                GestureDetector(
                  onTap: () => OrganizerContactPicker.show(context, organizer),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kBrandPrimary.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: kBrandPrimary,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.message,
                          color: kBrandPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context).get('contact'),
                          style: TextStyle(
                            color: kBrandPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[600],
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey[300],
        size: 24,
      ),
    );
  }
}