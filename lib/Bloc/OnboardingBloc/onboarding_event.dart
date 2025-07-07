import 'package:flutter/material.dart';

abstract class OnboardingEvent {}

class OnSignWithGoogle extends OnboardingEvent {
  BuildContext context;
  OnSignWithGoogle({required this.context});
}
