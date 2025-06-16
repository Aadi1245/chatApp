import 'package:chattest/pages/home_page.dart';
import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int _currentIndex = 0;

  final List<TutorialStep> steps = [
    TutorialStep(
      imagePath: 'assets/images/images.jpg',
      title: 'Welcome',
      description: 'Welcome to our awesome app tutorial!',
    ),
    TutorialStep(
      imagePath: 'assets/images/images.jpg',
      title: 'Discover Features',
      description: 'Explore amazing features tailored for you.',
    ),
    TutorialStep(
      imagePath: 'assets/images/images.jpg',
      title: 'Stay Organized',
      description: 'Manage your tasks and stay productive easily.',
    ),
    TutorialStep(
      imagePath: 'assets/images/images.jpg',
      title: 'Track Progress',
      description: 'Keep an eye on your performance and stats.',
    ),
    TutorialStep(
      imagePath: 'assets/images/images.jpg',
      title: 'Get Started!',
      description: 'Let’s dive in and start using the app now!',
    ),
  ];

  void _nextStep() {
    if (_currentIndex < steps.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = steps[_currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Image
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Image.asset(
                  currentStep.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Title and description
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Text(
                    currentStep.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      currentStep.description,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                steps.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.blueAccent
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Next/Finish button
            Padding(
              padding: const EdgeInsets.only(right: 24, bottom: 24),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text(
                    _currentIndex == steps.length - 1 ? 'Finish' : 'Next',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialStep {
  final String imagePath;
  final String title;
  final String description;

  TutorialStep({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}
