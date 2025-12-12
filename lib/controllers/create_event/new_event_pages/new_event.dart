import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../shared/custom_app_bar.dart';
import 'new_event_step1.dart';
import 'new_event_step2.dart';
import 'new_event_step3.dart';

class NewEventPage extends StatefulWidget {
  const NewEventPage({super.key});

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  int _currentStep = 0;
  
  // Controllers for each step - to be reused in editing phase
  final Map<String, dynamic> _eventData = {};
  
  final List<String> _stepTitles = [
    'event-basic-info',
    'event-details',
    'event-tickets-pricing',
    'event-confirmation'
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
    setState(() {
      _eventData[key] = value;
    });
  }

  void _onStepCompleted() {
    // Handle final step completion
    // This could navigate to a success page or back to events list
    Navigator.pop(context, _eventData);
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return NewEventStep1(
          eventData: _eventData,
          onDataChanged: _onStepDataChanged,
          onNext: _nextStep,
        );
      case 1:
        return NewEventStep2(
          eventData: _eventData,
          onDataChanged: _onStepDataChanged,
          onNext: _nextStep,
          onPrevious: _previousStep,
        );
      case 2:
        return NewEventStep3(
          eventData: _eventData,
          onDataChanged: _onStepDataChanged,
          onComplete: _nextStep, // This will go to step 4
          onPrevious: _previousStep,
        );
      case 3:
        return NewEventStep3( // Placeholder - you'll need to create NewEventStep4
          eventData: _eventData,
          onDataChanged: _onStepDataChanged,
          onComplete: _onStepCompleted, // Final completion
          onPrevious: _previousStep,
        );
      default:
        return NewEventStep1(
          eventData: _eventData,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: kMainBackgroundColor,
      child: Text(
        AppLocalizations.of(context).get(_stepTitles[_currentStep]),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
