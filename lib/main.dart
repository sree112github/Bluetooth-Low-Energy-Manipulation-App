import 'package:firstapp/page1.dart';
import 'package:firstapp/page2.dart';
import 'package:firstapp/page3.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(StepperApp());
}

class StepperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StepperScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StepperScreen extends StatefulWidget {
  @override
  _StepperScreenState createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Horizontal Stepper')),
      body: Column(
        children: [
          // 👇 Provide fixed height to prevent layout errors
          SizedBox(
            height: 100,
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (index) {
                setState(() => _currentStep = index);
              },
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              controlsBuilder: (context, ControlsDetails details) {
                return SizedBox.shrink(); // Hides default buttons
              },
              steps: [
                Step(
                  title: Text('Step 1'),
                  content: SizedBox.shrink(),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: Text('Step 2'),
                  content: SizedBox.shrink(),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: Text('Step 3'),
                  content: SizedBox.shrink(),
                  isActive: _currentStep >= 2,
                ),
              ],
            ),
          ),

          // 👇 Page-like content area
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: _buildStepContent(),
            ),
          ),

          // 👇 Custom navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentStep > 0
                      ? () => setState(() => _currentStep -= 1)
                      : null,
                  child: Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _currentStep < 2
                      ? () => setState(() => _currentStep += 1)
                      : null,
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👇 Builds the content shown for each step
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return StepOnePage();
      case 1:
        return StepTwoPage();
      case 2:
        return StepThreePage();
      default:
        return SizedBox.shrink();
    }
  }

}
