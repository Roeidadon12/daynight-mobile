import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/event/orginizer_events/orginizer_event_list_tile.dart';
import 'package:day_night/controllers/create_event/edit_event_pages/special_graphs.dart';
import 'package:day_night/controllers/create_event/edit_event_pages/summary_status_card.dart';
import 'package:day_night/controllers/create_event/edit_event_pages/total_earnings_section.dart';
import 'package:day_night/controllers/create_event/edit_event_pages/waiting_participants_section.dart';
import 'package:day_night/models/events.dart';
import 'package:day_night/services/event_service.dart';
import 'package:flutter/material.dart';

class EditEventPage extends StatefulWidget {
  final OrganizerEvent event;

  const EditEventPage({
    super.key,
    required this.event,
  });

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final EventService _eventService = EventService();
  int _waitingParticipants = 0;
  double _totalEarnings = 0;
  int _womenParticipants = 0;
  int _menParticipants = 0;
  int _approvedParticipants = 0;
  int _abondedParticipants = 0;
  int _rejectedParticipants = 0;
  int _hiddenParticipants = 0;

  @override
  void initState() {
    super.initState();
    _loadEventStatistics();
  }

  Future<void> _loadEventStatistics() async {
    final statistics = await _eventService.getEventStatistics(
      widget.event.id.toString(),
    );

    if (!mounted || statistics == null) return;

    setState(() {
      _waitingParticipants = statistics.data.totalPendingBookings;
      _totalEarnings = statistics.data.totalEarning;
      _womenParticipants = statistics.data.totalFemales;
      _menParticipants = statistics.data.totalMales;
      _approvedParticipants = statistics.data.totalParticipants;
      _abondedParticipants = statistics.data.totalAbandonedBookings;
      _rejectedParticipants = statistics.data.totalRejectedBookings;
      _hiddenParticipants = 0; // statistics.data.totalHiddenBookings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: AppBar(
        backgroundColor: kMainBackgroundColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(localizations.get('event-details')),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OrginizerEventListTile(
              event: widget.event,
              showTrailingArrow: false,
              showBottomActions: false,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TopActionButton(
                    label: localizations.get('edit-event-team'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TopActionButton(
                    label: localizations.get('edit-event-links'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TopActionButton(
                    label: localizations.get('edit-event-coupons'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TopActionButton(
                    label: localizations.get('edit-event-cashier'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: localizations.get('search-participants'),
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kBrandPrimary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WaitingParticipantsSection(
                      waitingParticipants: _waitingParticipants,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryStatusCard(
                            title: localizations.get('summary-status-approved'),
                            value: _approvedParticipants.toString(),
                            valueColor: const Color(0xFF11C782),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SummaryStatusCard(
                            title: localizations.get('summary-status-dropouts'),
                            value: _abondedParticipants.toString(),
                            valueColor: const Color(0xFFF2C94C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryStatusCard(
                            title: localizations.get('summary-status-rejected'),
                            value: _rejectedParticipants.toString(),
                            valueColor: const Color(0xFFFF4C4C),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SummaryStatusCard(
                            title: localizations.get('summary-status-hidden'),
                            value: _hiddenParticipants.toString(),
                            valueColor: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TotalEarningsSection(totalEarnings: _totalEarnings),
                    const SizedBox(height: 12),
                    SpecialGraphsSection(
                      womenCount: _womenParticipants,
                      menCount: _menParticipants,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
             
          ],
        ),
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  final String label;

  const _TopActionButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
          backgroundColor: Colors.white.withValues(alpha: 0.04),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
