part of 'onboarding_bloc.dart';

@immutable
abstract class OnboardingEvent {}

class OnSignWithGoogle extends OnboardingEvent {
  BuildContext context;
  OnSignWithGoogle({required this.context});
}
