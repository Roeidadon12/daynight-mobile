import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/models/event_details.dart';
import 'package:day_night/models/events.dart';
import 'package:flutter/material.dart';
import '../../shared/labeled_text_form_field.dart';

class AdvancedEditSection extends StatefulWidget {
  final OrganizerEvent event;
  final EventEditDetails? initialEventData;
  final Map<String, dynamic> eventData;
  final Function(String, dynamic) onDataChanged;

  const AdvancedEditSection({
    super.key,
    required this.event,
    this.initialEventData,
    required this.eventData,
    required this.onDataChanged,
  });

  @override
  State<AdvancedEditSection> createState() => _AdvancedEditSectionState();
}

class _AdvancedEditSectionState extends State<AdvancedEditSection> {
  late bool _isPrivateEvent;
  bool _isEditedByUser = false;
  final TextEditingController _organizerNameController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _organizerIdentificationNumberController = TextEditingController();
  final TextEditingController _urlSuffixController = TextEditingController();
  final TextEditingController _metaPixelController = TextEditingController();
  final TextEditingController _tikTokPixelController = TextEditingController();
  final TextEditingController _ga4AnalyticsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isPrivateEvent = _resolvePrivateEventValue();
    _organizerNameController.text = widget.eventData['organizerName']?.toString() ?? '';
    _contactEmailController.text = widget.eventData['contactEmail']?.toString() ?? '';
    _organizerIdentificationNumberController.text = widget.eventData['organizerIdentificationNumber']?.toString() ?? '';
    _urlSuffixController.text = widget.eventData['urlSuffix']?.toString() ??
      widget.initialEventData?.heEventContent?.slug ??
      widget.initialEventData?.enEventContent?.slug ??
      '';
    _metaPixelController.text = widget.eventData['pixel_id']?.toString() ??
      widget.initialEventData?.event.pixelId ??
      '';
    _tikTokPixelController.text = widget.eventData['tiktok_pixel_id']?.toString() ??
      widget.initialEventData?.event.tiktokPixelId ??
      '';
    _ga4AnalyticsController.text = widget.eventData['measurement_id']?.toString() ??
      widget.initialEventData?.event.measurementId?.toString() ??
      '';
  }

  @override
  void dispose() {
    _organizerNameController.dispose();
    _contactEmailController.dispose();
    _organizerIdentificationNumberController.dispose();
    _urlSuffixController.dispose();
    _metaPixelController.dispose();
    _tikTokPixelController.dispose();
    _ga4AnalyticsController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AdvancedEditSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isEditedByUser) {
      return;
    }

    if (oldWidget.initialEventData != widget.initialEventData ||
        oldWidget.eventData['isPrivateEvent'] != widget.eventData['isPrivateEvent']) {
      setState(() {
        _isPrivateEvent = _resolvePrivateEventValue();
      });
    }
  }

  bool _resolvePrivateEventValue() {
    final fromEventData = widget.eventData['isPrivateEvent'];
    if (fromEventData is bool) {
      return fromEventData;
    }

    final rawStatus = widget.initialEventData?.event.status;
    if (rawStatus == null) {
      return false;
    }

    final normalized = rawStatus.toString().trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kMainBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                AppLocalizations.of(context).get('private-event'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(context).get('private-event-description'),
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              value: _isPrivateEvent,
              onChanged: (bool value) {
                setState(() {
                  _isEditedByUser = true;
                  _isPrivateEvent = value;
                });
                widget.onDataChanged('isPrivateEvent', value);
              },
              activeThumbColor: kBrandPrimary,
            ),
            const SizedBox(height: 24),
            LabeledTextFormField(
              controller: _organizerNameController,
              titleKey: 'organizer-name',
              hintTextKey: 'enter-organizer-name',
              errorTextKey: 'organizer-name-required',
              isRequired: true,
              onChanged: (value) {
                widget.onDataChanged('organizerName', value);
              },
            ),
            const SizedBox(height: 24),
            LabeledTextFormField(
              controller: _contactEmailController,
              titleKey: 'email-for-contact',
              hintTextKey: 'enter-email-for-contact',
              errorTextKey: 'email-for-contact-required',
              isRequired: false,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                widget.onDataChanged('contactEmail', value);
              },
            ),
            const SizedBox(height: 24),
            LabeledTextFormField(
              controller: _organizerIdentificationNumberController,
              titleKey: 'organizer-identification-number',
              hintTextKey: 'enter-organizer-identification-number',
              errorTextKey: 'organizer-identification-number-required',
              isRequired: false,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                widget.onDataChanged('organizerIdentificationNumber', value);
              },
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context).get('url-address'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Directionality(
                    textDirection: Directionality.of(context),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.grey[600]!, width: 1),
                            ),
                            child: TextFormField(
                              controller: _urlSuffixController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).get('your-event-name'),
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              onChanged: (value) {
                                widget.onDataChanged('urlSuffix', value);
                              },
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Text(
                            'Daynight.co.il/Event/',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                              fontFamily: 'monospace',
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).get('users-tracking'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                LabeledTextFormField(
                  controller: _metaPixelController,
                  titleKey: 'meta-pixel',
                  hintTextKey: 'enter-meta-pixel',
                  isRequired: false,
                  onChanged: (value) {
                    widget.onDataChanged('pixel_id', value);
                  },
                ),
                const SizedBox(height: 16),
                LabeledTextFormField(
                  controller: _tikTokPixelController,
                  titleKey: 'tiktok-pixel',
                  hintTextKey: 'enter-tiktok-pixel',
                  isRequired: false,
                  onChanged: (value) {
                    widget.onDataChanged('tiktok_pixel_id', value);
                  },
                ),
                const SizedBox(height: 16),
                LabeledTextFormField(
                  controller: _ga4AnalyticsController,
                  titleKey: 'ga4-analytics',
                  hintTextKey: 'enter-ga4-analytics',
                  isRequired: false,
                  onChanged: (value) {
                    widget.onDataChanged('measurement_id', value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
