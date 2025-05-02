import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chattest/Services/auth.dart';
import 'package:chattest/Services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../home_page.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<OnSignWithGoogle>((event, State) async {
      emit(OnbpoardingBlocLoading());
      SharedPreferenceHelper preferenceHelper = SharedPreferenceHelper();
      String? name = await preferenceHelper.getUserDisplayName();
      if (name == null || name.isEmpty) {
        try {
          Authmethods().signInWithGoogle(event.context);
        } catch (e) {
          print("Exception in signInWithGoogle ----> ${e}");
        }
      } else {
        Navigator.pushReplacement(
            event.context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
  }
}
