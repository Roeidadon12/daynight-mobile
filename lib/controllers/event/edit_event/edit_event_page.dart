import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/models/event_details.dart';
import 'package:day_night/models/events.dart';
import 'package:day_night/controllers/event/edit_event/general_edit_page.dart';
import 'package:day_night/controllers/event/edit_event/media_edit_page.dart';
import 'package:day_night/controllers/event/edit_event/advanced_edit_page.dart';
import 'package:day_night/controllers/event/edit_event/bank_details_edit_page.dart';
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
