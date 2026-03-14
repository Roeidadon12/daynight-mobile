import 'package:day_night/models/events.dart';
import 'package:flutter/material.dart';
import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';

class OrginizerEventListTile extends StatelessWidget {
  final OrganizerEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onEditPressed;
  final VoidCallback? onGraphPressed;
  final bool showTrailingArrow;
  final bool showBottomActions;
  final bool showGraphButton;

  const OrginizerEventListTile({
    super.key,
    required this.event,
    this.onTap,
    this.onEditPressed,
    this.onGraphPressed,
    this.showTrailingArrow = true,
    this.showBottomActions = true,
    this.showGraphButton = false,
  });

  String _formatStartDateTime() {
    try {
      final date = DateTime.parse(event.startDate);
      const dayNames = <String>[
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      const monthNames = <String>[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      final dayName = dayNames[date.weekday - 1];
      final monthName = monthNames[date.month - 1];
      final time = event.startTime.trim();

      return '$dayName, ${date.day} $monthName ${time.isNotEmpty ? time : '--:--'}';
    } catch (_) {
      return event.startTime.isNotEmpty ? event.startTime : event.eventDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minLeadingWidth: 0,
            horizontalTitleGap: 12,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 64,
                child: event.coverImage.isNotEmpty
                    ? Image.network(
                        event.coverImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white.withValues(alpha: 0.08),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.white.withValues(alpha: 0.08),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
              ),
            ),
            title: Text(
              event.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _formatStartDateTime(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
            ),
            trailing: showTrailingArrow || showGraphButton
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showGraphButton)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 4),
                          child: _TrailingIconButton(
                            icon: Icons.bar_chart_rounded,
                            onPressed: onGraphPressed,
                          ),
                        ),
                      if (showTrailingArrow)
                        Icon(
                          Directionality.of(context) == TextDirection.ltr
                              ? Icons.chevron_left
                              : Icons.chevron_right,
                          color: Colors.grey[400],
                          size: 22,
                        ),
                    ],
                  )
                : null,
          ),
          if (event.isActive && showBottomActions) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withValues(alpha: 0.35),
            ),
            SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _ActionButton(
                              label: localizations.get('organizer-enter-permits'),
                              color: kBrandPrimary,
                              icon: Icons.how_to_reg_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _ActionButton(
                              label: localizations.get('organizer-scan'),
                              color: const Color(0xFF4BE39C),
                              icon: Icons.qr_code_scanner,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 96,
                      child: _ActionButton(
                        label: localizations.get('organizer-edit-event'),
                        color: const Color(0xFFB9C0CD),
                        icon: Icons.edit_outlined,
                        onPressed: onEditPressed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrailingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _TrailingIconButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white.withValues(alpha: 0.06),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shape: CircleBorder(
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ),
        icon: Icon(icon, size: 22),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color,
          disabledForegroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: color, width: 1),
          ),
          backgroundColor: color.withValues(alpha: 0.07),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 14),
          ],
        ),
      ),
    );
  }
}
