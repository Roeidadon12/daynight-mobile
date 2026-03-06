import 'package:day_night/controllers/create_event/empty_my_events.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/event_service.dart';
import '../models/events.dart';

class EditingTab extends StatefulWidget {
  final bool isSelected;
  
  const EditingTab({super.key, this.isSelected = false});

  @override
  State<EditingTab> createState() => _EditingTabState();
}

class _EditingTabState extends State<EditingTab> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  final EventService _eventService = EventService();
  List<OrganizerEvent> _userEvents = [];
  bool _isLoading = false;
  bool _wasSelected = false;

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
  }

  @override
  void didUpdateWidget(EditingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when tab becomes selected
    if (widget.isSelected && !_wasSelected) {
      _wasSelected = true;
      _loadUserEvents();
    } else if (!widget.isSelected) {
      _wasSelected = false;
    }
  }

  /// Fetches user events from the API
  Future<void> _loadUserEvents() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls

    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _eventService.getUserEvents();
      if (mounted) {
        setState(() {
          _userEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: kBrandPrimary,
        ),
      );
    }

    // Show empty state if no events
    if (_userEvents.isEmpty) {
      return const EmptyMyEvents();
    }

    // TODO: Show events list when there are events
    // For now, still showing empty state
    return const EmptyMyEvents();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return SafeArea(
      child: Container(
        color: kMainBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. Content Area - Show EmptyMyEvents by default
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
