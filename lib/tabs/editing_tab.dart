import 'package:day_night/controllers/create_event/empty_my_events.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class EditingTab extends StatefulWidget {
  const EditingTab({super.key});

  @override
  State<EditingTab> createState() => _EditingTabState();
}

class _EditingTabState extends State<EditingTab>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  Widget _buildContent() {
    // For now, always show EmptyMyEvents as default
    // You can add logic here to show different content based on _selectedFilterIndex
    // and whether there are actual events to display
    return const EmptyMyEvents();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
