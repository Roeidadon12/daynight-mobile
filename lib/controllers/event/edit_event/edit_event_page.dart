import 'package:day_night/models/event_details.dart';
import 'package:day_night/models/events.dart';
import 'package:day_night/services/event_service.dart';
import 'package:flutter/material.dart';

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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!),
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

    // Keep page content intentionally empty for now, but only after data is loaded.
    if (_eventDetails != null) {
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }
}
