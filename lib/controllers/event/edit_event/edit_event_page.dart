import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/models/event_details.dart';
import 'package:day_night/models/events.dart';
import 'package:day_night/controllers/event/edit_event/general_edit_page.dart';
import 'package:day_night/controllers/event/edit_event/media_edit_page.dart';
import 'package:day_night/controllers/event/edit_event/advanced_edit_page.dart';
import 'package:day_night/controllers/event/edit_event/bank_details_edit_page.dart';
import 'package:day_night/controllers/shared/primary_button.dart';
import 'package:day_night/services/event_service.dart';
import 'package:flutter/material.dart';

enum _EditSection { general, media, advanced, bankDetails }

class EventEditingPage extends StatefulWidget {
  final OrganizerEvent event;

  const EventEditingPage({
    super.key,
    required this.event,
  });

  @override
  State<EventEditingPage> createState() => _EventEditingPageState();
}

class _EventEditingPageState extends State<EventEditingPage> {
  final EventService _eventService = EventService();
  EventEditDetails? _eventDetails;
  late Map<String, dynamic> _eventFormData;
  bool _isLoading = true;
  String? _errorMessage;
  _EditSection _selectedSection = _EditSection.general;
  bool _eventDetailsRebuildScheduled = false;

  @override
  void initState() {
    super.initState();
    _eventFormData = <String, dynamic>{
      'he_title': widget.event.title,
      'en_title': widget.event.title,
      'start_date': widget.event.startDate,
      'start_time': widget.event.startTime,
    };
    _loadEventDetails();
  }

  void _onEventDataChanged(String key, dynamic value) {
    _eventFormData[key] = value;
    _syncEventDetailsFromFormChange(key, value);
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    final normalized = value?.toString().trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }

  EventLanguageContent? _updateLanguageContent(
    EventLanguageContent? content, {
    String? title,
    int? categoryId,
    String? address,
    String? country,
  }) {
    if (content == null) {
      return null;
    }

    return content.copyWith(
      title: title,
      eventCategoryId: categoryId,
      address: address,
      country: country,
    );
  }

  void _syncEventDetailsFromFormChange(String key, dynamic value) {
    final details = _eventDetails;
    if (details == null) {
      return;
    }

    EventEditDetails updated = details;

    switch (key) {
      case 'he_title':
        updated = updated.copyWith(
          heEventContent: _updateLanguageContent(updated.heEventContent, title: _asString(value)),
        );
        break;
      case 'en_title':
        updated = updated.copyWith(
          enEventContent: _updateLanguageContent(updated.enEventContent, title: _asString(value)),
        );
        break;
      case 'he_category_id':
        updated = updated.copyWith(
          heEventContent: _updateLanguageContent(updated.heEventContent, categoryId: _asInt(value)),
        );
        break;
      case 'en_category_id':
        updated = updated.copyWith(
          enEventContent: _updateLanguageContent(updated.enEventContent, categoryId: _asInt(value)),
        );
        break;
      case 'address':
        updated = updated.copyWith(
          address: _asString(value),
          heEventContent: _updateLanguageContent(updated.heEventContent, address: _asString(value)),
          enEventContent: _updateLanguageContent(updated.enEventContent, address: _asString(value)),
          event: updated.event.copyWith(mapAddress: _asString(value)),
        );
        break;
      case 'min_age':
        updated = updated.copyWith(
          event: updated.event.copyWith(minAge: _asInt(value) ?? updated.event.minAge),
        );
        break;
      case 'start_date':
        updated = updated.copyWith(
          event: updated.event.copyWith(startDate: _asString(value) ?? updated.event.startDate),
        );
        break;
      case 'start_time':
        updated = updated.copyWith(
          event: updated.event.copyWith(startTime: _asString(value) ?? updated.event.startTime),
        );
        break;
      case 'end_date':
        updated = updated.copyWith(
          event: updated.event.copyWith(endDate: _asString(value) ?? updated.event.endDate),
        );
        break;
      case 'end_time':
        updated = updated.copyWith(
          event: updated.event.copyWith(endTime: _asString(value) ?? updated.event.endTime),
        );
        break;
      case 'image':
        updated = updated.copyWith(
          event: updated.event.copyWith(coverImage: _asString(value) ?? updated.event.coverImage),
        );
        break;
      case 'he_description':
        updated = updated.copyWith(
          heEventContent: updated.heEventContent?.copyWith(description: _asString(value) ?? ''),
        );
        break;
      case 'en_description':
        updated = updated.copyWith(
          enEventContent: updated.enEventContent?.copyWith(description: _asString(value) ?? ''),
        );
        break;
      case 'isPrivateEvent':
        updated = updated.copyWith(
          event: updated.event.copyWith(status: _asBool(value) ? '1' : '0'),
        );
        break;
      case 'urlSuffix':
        updated = updated.copyWith(
          heEventContent: updated.heEventContent?.copyWith(slug: _asString(value) ?? ''),
          enEventContent: updated.enEventContent?.copyWith(slug: _asString(value) ?? ''),
        );
        break;
      case 'pixel_id':
        updated = updated.copyWith(
          event: updated.event.copyWith(pixelId: _asString(value)),
        );
        break;
      case 'tiktok_pixel_id':
        updated = updated.copyWith(
          event: updated.event.copyWith(tiktokPixelId: _asString(value)),
        );
        break;
      case 'measurement_id':
        updated = updated.copyWith(
          event: updated.event.copyWith(measurementId: _asInt(value)),
        );
        break;
      case 'he_country':
        updated = updated.copyWith(
          heEventContent: _updateLanguageContent(updated.heEventContent, country: _asString(value)),
        );
        break;
      case 'en_country':
        updated = updated.copyWith(
          enEventContent: _updateLanguageContent(updated.enEventContent, country: _asString(value)),
        );
        break;
      default:
        return;
    }

    _eventDetails = updated;
    _scheduleEventDetailsRebuild();
  }

  void _scheduleEventDetailsRebuild() {
    if (!mounted || _eventDetailsRebuildScheduled) {
      return;
    }

    _eventDetailsRebuildScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _eventDetailsRebuildScheduled = false;
      setState(() {});
    });
  }

  void _hydrateFormDataFromDetails(EventEditDetails details) {
    _eventFormData.addAll({
      'he_title': details.heEventContent?.title ?? widget.event.title,
      'en_title': details.enEventContent?.title ?? details.heEventContent?.title ?? widget.event.title,
      'he_category_id': details.heEventContent?.eventCategoryId,
      'en_category_id': details.enEventContent?.eventCategoryId,
      'address': details.address ?? details.heEventContent?.address ?? details.enEventContent?.address ?? details.event.mapAddress ?? '',
      'min_age': details.event.minAge,
      'start_date': details.event.startDate,
      'start_time': details.event.startTime,
      'end_date': details.event.endDate,
      'end_time': details.event.endTime,
      'currency': details.currencyInfo?.baseCurrencyText,
      'image': details.event.coverImage,
      'he_description': details.heEventContent?.description ?? '',
      'en_description': details.enEventContent?.description ?? '',
    });
  }

  Widget _buildSelectedSection() {
    switch (_selectedSection) {
      case _EditSection.general:
        return GeneralEditSection(
          event: widget.event,
          initialEventData: _eventDetails,
          eventData: _eventFormData,
          onDataChanged: _onEventDataChanged,
          onNext: () => setState(() => _selectedSection = _EditSection.media),
        );
      case _EditSection.media:
        return MediaEditSection(
          event: widget.event,
          initialEventData: _eventDetails,
          eventData: _eventFormData,
          onDataChanged: _onEventDataChanged,
          onPrevious: () => setState(() => _selectedSection = _EditSection.general),
          onNext: () => setState(() => _selectedSection = _EditSection.advanced),
        );
      case _EditSection.advanced:
        return AdvancedEditSection(
          event: widget.event,
          initialEventData: _eventDetails,
          eventData: _eventFormData,
          onDataChanged: _onEventDataChanged,
        );
      case _EditSection.bankDetails:
        return BankDetailsEditSection(
          event: widget.event,
          initialEventData: _eventDetails,
          eventData: _eventFormData,
          onDataChanged: _onEventDataChanged,
        );
    }
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await _eventService.getEventDetailsForEdit(widget.event.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _eventDetails = details;
        if (details != null) {
          _hydrateFormDataFromDetails(details);
        }
        _isLoading = false;
        _errorMessage = details == null ? 'Failed to load event details.' : null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load event details.';
      });
    }
  }

  void _onSaveChangesPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).get('save-changes')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations localizations) {
    return AppBar(
      backgroundColor: kMainBackgroundColor,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(localizations.get('organizer-edit-event')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: kMainBackgroundColor,
        appBar: _buildAppBar(localizations),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: kMainBackgroundColor,
        appBar: _buildAppBar(localizations),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadEventDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_eventDetails != null) {
      return Scaffold(
        backgroundColor: kMainBackgroundColor,
        appBar: _buildAppBar(localizations),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _EditTopButton(
                        label: localizations.get('event-edit-general'),
                        isSelected: _selectedSection == _EditSection.general,
                        onPressed: () => setState(() => _selectedSection = _EditSection.general),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EditTopButton(
                        label: localizations.get('event-edit-media'),
                        isSelected: _selectedSection == _EditSection.media,
                        onPressed: () => setState(() => _selectedSection = _EditSection.media),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EditTopButton(
                        label: localizations.get('event-edit-advanced'),
                        isSelected: _selectedSection == _EditSection.advanced,
                        onPressed: () => setState(() => _selectedSection = _EditSection.advanced),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EditTopButton(
                        label: localizations.get('event-edit-bank-details'),
                        isSelected: _selectedSection == _EditSection.bankDetails,
                        onPressed: () => setState(() => _selectedSection = _EditSection.bankDetails),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildSelectedSection()),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: _onSaveChangesPressed,
                    textKey: 'save-changes',
                    flexible: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _EditTopButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const _EditTopButton({
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: isSelected ? kBrandPrimary : Colors.white.withValues(alpha: 0.24),
          ),
          backgroundColor: isSelected
              ? kBrandPrimary
              : Colors.white.withValues(alpha: 0.04),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
