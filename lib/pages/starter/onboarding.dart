import 'package:chattest/Services/auth.dart';
import 'package:chattest/Services/fcm_service.dart';
import 'package:chattest/Services/notification_services.dart';
import 'package:chattest/Services/shared_pref.dart';
import 'package:chattest/pages/home_page.dart';
import 'package:chattest/pages/starter/bloc/onboarding_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class Onbpoarding extends StatefulWidget {
  const Onbpoarding({super.key});

  @override
  State<Onbpoarding> createState() => _OnbpoardingState();
}

class _OnbpoardingState extends State<Onbpoarding> {
  @override
  void initState() {
    // TODO: implement initState
    NotificationServices().getNotificationPermission();
    NotificationServices().getDeviceToken();
    FcmService.firebaseInit();
    NotificationServices().firebaseInit(context);
    NotificationServices().setupInteractMessage(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => OnboardingBloc(),
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            if (state is OnbpoardingBlocFailed) {
              return Center(
                child: Text("Something went wrong!"),
              );
            }
            if (state is OnbpoardingBlocLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container(
              child: Column(
                children: [
                  Material(
                      elevation: 3,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30)),
                            child: Image.asset(
                                fit: BoxFit.cover, "assets/images/images.jpg"),
                          ))),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10.0, right: 10, top: 5, bottom: 5),
                    child: Text(
                      "Enjoy the experience of chating with your friends",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10.0, right: 10, top: 5, bottom: 5),
                    child: Text(
                      "Connect people around the world for free",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      BlocProvider.of<OnboardingBloc>(context)
                          .add(OnSignWithGoogle(context: context));
                      // SharedPreferenceHelper preferenceHelper =
                      //     SharedPreferenceHelper();
                      // String? name =
                      //     await preferenceHelper.getUserDisplayName();
                      // name == null || name.isEmpty
                      //     ? Authmethods().signInWithGoogle(context)
                      //     : Navigator.pushReplacement(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => HomePage()
                      //             ));
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 25, right: 25),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 8, bottom: 8, left: 10, right: 10),
                          // margin: EdgeInsets.only(left: 25, right: 25),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blueGrey,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/images/google_logo.svg",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Sign in with Google",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
