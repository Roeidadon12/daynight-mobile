import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../../models/create_event_data.dart';
import '../../shared/custom_app_bar.dart';
import '../event_components/create_step_title.dart';
import 'new_event_step1.dart';
import 'new_event_step2.dart';
import 'new_event_step3.dart';
import 'new_event_step4.dart';

class NewEventPage extends StatefulWidget {
  const NewEventPage({super.key});

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  int _currentStep = 0;
  
  // Structured event data model
  final CreateEventData _eventData = CreateEventData();
  
  List<CreateStepTitle> get _stepTitles => [
    CreateStepTitle(
      title: AppLocalizations.of(context).get('create-event-basic-info'),
      description: AppLocalizations.of(context).get('create-event-basic-info-description'),
    ),
    CreateStepTitle(
      title: AppLocalizations.of(context).get('create-event-design'),
      description: AppLocalizations.of(context).get('create-event-design-description'),
    ),
    CreateStepTitle(
      title: AppLocalizations.of(context).get('create-event-details'),
      description: AppLocalizations.of(context).get('create-event-details-description'),
    ),
    CreateStepTitle(
      title: AppLocalizations.of(context).get('event-created'),
      description: '',
    ),
  ];

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _onStepDataChanged(String key, dynamic value) {
    // Update data without setState to avoid calling setState during build phase
    // The child widgets manage their own state, so parent doesn't need to rebuild
    _eventData.updateField(key, value);
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return NewEventStep1(
          eventData: _eventData.toMap(),
          onDataChanged: _onStepDataChanged,
          onNext: _nextStep,
        );
      case 1:
        return NewEventStep2(
          eventData: _eventData.toMap(),
          onDataChanged: _onStepDataChanged,
          onNext: _nextStep,
          onPrevious: _previousStep,
        );
      case 2:
        return NewEventStep3(
          eventData: _eventData.toMap(),
          onDataChanged: _onStepDataChanged,
          onComplete: _nextStep, // This will go to step 4
          onPrevious: _previousStep,
        );
      default:
        return NewEventStep1(
          eventData: _eventData.toMap(),
          onDataChanged: _onStepDataChanged,
          onNext: _nextStep,
        );
    }
  }

  Widget _buildStepIndicator() {
    // Calculate progress with some padding at the end (0.2, 0.4, 0.6, 0.85)
    double progressValue = ((_currentStep + 1) / 4.0) * 0.85 + 0.05;
    bool isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: kMainBackgroundColor,
      child: Container(
        width: double.infinity,
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey[700],
        ),
        child: FractionallySizedBox(
          alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
          widthFactor: progressValue,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: kBrandPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepTitle() {
    return Container(
      width: double.infinity,
      color: kMainBackgroundColor,
      child: _stepTitles[_currentStep],
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we're on the final step (step 4), show it as a full-screen success page
    if (_currentStep == 3) {
      return NewEventStep4(
        eventData: _eventData.toMap(),
        onComplete: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      );
    }
    
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Common Header
            CustomAppBar(
              titleKey: 'create-new-event',
              onBackPressed: () {
                if (_currentStep > 0) {
                  _previousStep();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            
            // Step Indicator
            _buildStepIndicator(),
            
            // Step Title
            _buildStepTitle(),
            
            // Step Content
            Expanded(
              child: _buildCurrentStep(),
            ),
          ],
        ),
      ),
    );
  }
}
