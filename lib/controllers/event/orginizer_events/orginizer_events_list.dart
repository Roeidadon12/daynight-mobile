import 'package:day_night/constants.dart';
import 'package:day_night/app_localizations.dart';
import 'package:day_night/controllers/user/user_controller.dart';
import 'package:day_night/controllers/user/user_profile_section.dart';
import 'package:day_night/controllers/event/event_details/detail_event.dart';
import 'package:day_night/models/events.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'orginizer_event_list_tile.dart';

enum _OrginizerStatusFilter { active, nonActive }

class OrginizerEventsList extends StatefulWidget {
  final List<OrganizerEvent> events;
  final Future<void> Function()? onRefresh;

  const OrginizerEventsList({
    super.key,
    required this.events,
    this.onRefresh,
  });

  @override
  State<OrginizerEventsList> createState() => _OrginizerEventsListState();
}

class _OrginizerEventsListState extends State<OrginizerEventsList> {
  _OrginizerStatusFilter _selectedFilter = _OrginizerStatusFilter.active;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final filteredEvents = _selectedFilter == _OrginizerStatusFilter.active
        ? widget.events.where((event) => event.isActive).toList()
        : widget.events.where((event) => !event.isActive).toList();

    final listView = ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: filteredEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return OrginizerEventListTile(
          event: event,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailEventPage(event: event),
              ),
            );
          },
        );
      },
    );

    final scrollableContent = widget.onRefresh == null
        ? listView
        : RefreshIndicator(
            color: kBrandPrimary,
            onRefresh: widget.onRefresh!,
            child: listView,
          );

    final activeCount = widget.events.where((event) => event.isActive).length;
    final nonActiveCount = widget.events.length - activeCount;

    return Column(
      children: [
        Consumer<UserController>(
          builder: (context, userController, _) {
            if (userController.isLoggedIn && userController.user != null) {
              return UserProfileSection(user: userController.user!);
            }
            return const SizedBox.shrink();
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: _FilterButton(
                  title:
                      '${localizations.get("organizer-filter-active")} ($activeCount)',
                  isSelected: _selectedFilter == _OrginizerStatusFilter.active,
                  onTap: () {
                    setState(() {
                      _selectedFilter = _OrginizerStatusFilter.active;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterButton(
                  title:
                      '${localizations.get("organizer-filter-non-active")} ($nonActiveCount)',
                  isSelected: _selectedFilter == _OrginizerStatusFilter.nonActive,
                  onTap: () {
                    setState(() {
                      _selectedFilter = _OrginizerStatusFilter.nonActive;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredEvents.isEmpty
              ? Center(
                  child: Text(
                    _selectedFilter == _OrginizerStatusFilter.active
                        ? localizations.get('organizer-empty-active-events')
                        : localizations.get('organizer-empty-non-active-events'),
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                )
              : scrollableContent,
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? kBrandPrimary : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? kBrandPrimary : Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
