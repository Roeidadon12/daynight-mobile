import 'dart:io';

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
  bool _isSaving = false;
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

  int _resolveInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? fallback;
  }

  String _resolveString(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int _toBinary(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is bool) return value ? 1 : 0;

    final normalized = value.toString().trim().toLowerCase();
    if (normalized == '1' || normalized == 'true' || normalized == 'yes') return 1;
    if (normalized == '0' || normalized == 'false' || normalized == 'no') return 0;
    return fallback;
  }

  String _toYesNo(dynamic value, String fallback) {
    if (value == null) return fallback;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == '1' || normalized == 'true' || normalized == 'yes') return 'yes';
    if (normalized == '0' || normalized == 'false' || normalized == 'no') return 'no';
    return fallback;
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }

    return <String>[];
  }

  File? _resolveCoverImageFile() {
    final dynamic explicitFile = _eventFormData['imageFile'];
    if (explicitFile is File && explicitFile.existsSync()) {
      return explicitFile;
    }

    final imagePath = _eventFormData['image']?.toString();
    if (imagePath != null && imagePath.isNotEmpty) {
      final candidate = File(imagePath);
      if (candidate.existsSync()) {
        return candidate;
      }
    }

    return null;
  }

  Map<String, dynamic> _buildUpdateEventPayload() {
    final details = _eventDetails!;
    final event = details.event;

    final isFeatured = _toYesNo(_eventFormData['is_featured'], _toYesNo(event.isFeatured, 'no'));
    final countdownStatus = _toBinary(_eventFormData['countdown_status'], event.countdownStatus);
    final mapStatus = _toBinary(_eventFormData['map_status'], event.mapStatus);
    final endDateTimeStatus = _toBinary(
      _eventFormData['end_date_time_status'],
      event.hideDuration == 1 ? 0 : 1,
    );

    String dateType = _resolveString(_eventFormData['date_type'], event.dateType);
    if (dateType != 'single' && dateType != 'multiple') {
      dateType = 'single';
    }

    final address = _resolveString(
      _eventFormData['address'],
      details.address ?? event.mapAddress ?? '',
    );
    final mapAddress = _resolveString(_eventFormData['map_address'], event.mapAddress ?? address);
    final latitude = _resolveString(_eventFormData['latitude'], event.latitude?.toString() ?? '');
    final longitude = _resolveString(_eventFormData['longitude'], event.longitude?.toString() ?? '');

    final slug = _resolveString(
      _eventFormData['slug'] ?? _eventFormData['urlSuffix'],
      details.enEventContent?.slug ?? details.heEventContent?.slug ?? '',
    );

    final payload = <String, dynamic>{
      'event_id': widget.event.id,
      'min_age': _resolveInt(_eventFormData['min_age'], event.minAge).clamp(0, 999),
      'countdown_status': countdownStatus,
      'is_featured': isFeatured,
      'date_type': dateType,
      'end_date_time_status': endDateTimeStatus,
      'map_status': mapStatus,
      'address': address,
      'map_address': mapAddress,
      'latitude': latitude,
      'longitude': longitude,
      'pixel_id': _resolveString(_eventFormData['pixel_id'], event.pixelId ?? ''),
      'tiktok_pixel_id': _resolveString(_eventFormData['tiktok_pixel_id'], event.tiktokPixelId ?? ''),
      'measurement_id': _resolveString(_eventFormData['measurement_id'], event.measurementId?.toString() ?? ''),
      'slug': slug,
      'bank_name': _resolveString(_eventFormData['bank_name'] ?? _eventFormData['bankNumber'], ''),
      'account_name': _resolveString(_eventFormData['account_name'] ?? _eventFormData['accountHolderName'], ''),
      'account_number': _resolveString(_eventFormData['account_number'] ?? _eventFormData['bankAccountNumber'], ''),
      'branch_number': _resolveString(_eventFormData['branch_number'] ?? _eventFormData['branch'], ''),
      'cover_image': _resolveString(_eventFormData['cover_image'] ?? _eventFormData['image'], event.coverImage),
    };

    if (dateType == 'single') {
      payload['start_date'] = _resolveString(_eventFormData['start_date'], event.startDate);
      payload['start_time'] = _resolveString(_eventFormData['start_time'], event.startTime);
      payload['end_date'] = _resolveString(_eventFormData['end_date'], event.endDate);
      payload['end_time'] = _resolveString(_eventFormData['end_time'], event.endTime);
    } else {
      final mStartDate = _toStringList(_eventFormData['m_start_date']);
      final mStartTime = _toStringList(_eventFormData['m_start_time']);
      final mEndDate = _toStringList(_eventFormData['m_end_date']);
      final mEndTime = _toStringList(_eventFormData['m_end_time']);

      payload['m_start_date'] = mStartDate.isNotEmpty
          ? mStartDate
          : [_resolveString(_eventFormData['start_date'], event.startDate)];
      payload['m_start_time'] = mStartTime.isNotEmpty
          ? mStartTime
          : [_resolveString(_eventFormData['start_time'], event.startTime)];
      payload['m_end_date'] = mEndDate.isNotEmpty
          ? mEndDate
          : [_resolveString(_eventFormData['end_date'], event.endDate)];
      payload['m_end_time'] = mEndTime.isNotEmpty
          ? mEndTime
          : [_resolveString(_eventFormData['end_time'], event.endTime)];
    }

    final enTitle = _resolveString(
      _eventFormData['en_title'],
      details.enEventContent?.title ?? details.heEventContent?.title ?? widget.event.title,
    );
    final enCategoryId = _resolveInt(
      _eventFormData['en_category_id'],
      details.enEventContent?.eventCategoryId ?? details.heEventContent?.eventCategoryId ?? 0,
    );
    final enCountry = _resolveString(
      _eventFormData['en_country'],
      details.enEventContent?.country ?? details.heEventContent?.country ?? '',
    );
    final enDescription = _resolveString(
      _eventFormData['en_description'],
      details.enEventContent?.description ?? details.heEventContent?.description ?? '',
    );

    payload['en_title'] = enTitle;
    payload['en_category_id'] = enCategoryId;
    payload['en_country'] = enCountry;
    payload['en_description'] = enDescription;
    payload['en_refund_policy'] = _resolveString(_eventFormData['en_refund_policy'], details.enEventContent?.refundPolicy ?? '');
    payload['en_meta_keywords'] = _resolveString(_eventFormData['en_meta_keywords'], details.enEventContent?.metaKeywords ?? '');
    payload['en_meta_description'] = _resolveString(_eventFormData['en_meta_description'], details.enEventContent?.metaDescription ?? '');

    if (_eventFormData['he_title'] != null || details.heEventContent != null) {
      payload['he_title'] = _resolveString(
        _eventFormData['he_title'],
        details.heEventContent?.title ?? enTitle,
      );
      payload['he_category_id'] = _resolveInt(
        _eventFormData['he_category_id'],
        details.heEventContent?.eventCategoryId ?? enCategoryId,
      );
      payload['he_country'] = _resolveString(
        _eventFormData['he_country'],
        details.heEventContent?.country ?? enCountry,
      );
      payload['he_description'] = _resolveString(
        _eventFormData['he_description'],
        details.heEventContent?.description ?? enDescription,
      );
      payload['he_refund_policy'] = _resolveString(_eventFormData['he_refund_policy'], details.heEventContent?.refundPolicy ?? '');
      payload['he_meta_keywords'] = _resolveString(_eventFormData['he_meta_keywords'], details.heEventContent?.metaKeywords ?? '');
      payload['he_meta_description'] = _resolveString(_eventFormData['he_meta_description'], details.heEventContent?.metaDescription ?? '');
    }

    return payload;
  }

  Future<void> _onSaveChangesPressed() async {
    if (_eventDetails == null || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final payload = _buildUpdateEventPayload();
      final success = await _eventService.updateEvent(
        eventId: widget.event.id,
        eventData: payload,
        coverImageFile: _resolveCoverImageFile(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Event updated successfully.'
                : 'Failed to update event. Please try again.',
          ),
        ),
      );

      if (success) {
        await _loadEventDetails();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: _onSaveChangesPressed,
                    textKey: 'save-changes',
                    flexible: false,
                    disabled: _isSaving,
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
