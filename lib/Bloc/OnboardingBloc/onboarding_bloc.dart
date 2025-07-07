import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chattest/Bloc/OnboardingBloc/onboarding_event.dart';
import 'package:chattest/Bloc/OnboardingBloc/onboarding_state.dart';
import 'package:chattest/Utils/Services/auth.dart';
import 'package:chattest/Utils/Services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../views/home_page.dart';

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
