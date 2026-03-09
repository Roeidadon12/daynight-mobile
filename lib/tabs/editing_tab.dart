import 'package:day_night/controllers/create_event/empty_my_events.dart';
import 'package:day_night/controllers/create_event/new_event_pages/new_event.dart';
import 'package:day_night/controllers/event/orginizer_events/orginizer_events_list.dart';
import 'package:day_night/app_localizations.dart';
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

    return OrginizerEventsList(
      events: _userEvents,
      onRefresh: _loadUserEvents,
    );
  }

  Widget _buildPageHeader() {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              localizations.get('my-events'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewEventPage(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: kBrandPrimary,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                localizations.get('create-event'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
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
            _buildPageHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
