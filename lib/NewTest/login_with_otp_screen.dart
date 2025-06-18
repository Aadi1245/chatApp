import 'package:chattest/app_theme.dart';
import 'package:chattest/NewTest/signup_screen.dart';
import 'package:flutter/material.dart';

class LoginWithOtpScreen extends StatefulWidget {
  const LoginWithOtpScreen({super.key});

  @override
  State<LoginWithOtpScreen> createState() => _LoginWithOtpScreenState();
}

class _LoginWithOtpScreenState extends State<LoginWithOtpScreen>
    with TickerProviderStateMixin {
  late final AnimationController _textController;
  late final AnimationController _arrowController;
  late final AnimationController _fieldController;
  late final AnimationController _btnController;

  late final Animation<Offset> _textOffset;
  late final Animation<Offset> _arrowOffset;
  late final Animation<Offset> _fieldOffset;
  late final Animation<Offset> _btnOffset;

  bool showText = false;
  bool showArrow = false;
  bool showField = false;
  bool showBtn = false;

  @override
  void initState() {
    super.initState();

    _textController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    _arrowController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    _fieldController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    _btnController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));

    _textOffset = Tween<Offset>(begin: Offset(0, -2), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.bounceOut),
    );
    _arrowOffset =
        Tween<Offset>(begin: Offset(0, -2), end: Offset.zero).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.bounceOut),
    );
    _fieldOffset =
        Tween<Offset>(begin: Offset(0, -2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fieldController, curve: Curves.bounceOut),
    );
    _btnOffset = Tween<Offset>(begin: Offset(0, -2), end: Offset.zero).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.bounceOut),
    );

    _startDropSequence();
  }

  Future<void> _startDropSequence() async {
    setState(() => showText = true);
    await _textController.forward();

    setState(() => showArrow = true);
    await _arrowController.forward();

    setState(() => showField = true);
    await _fieldController.forward();

    setState(() => showBtn = true);
    await _btnController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _arrowController.dispose();
    _fieldController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 250, 103, 5),
              Color.fromARGB(255, 255, 160, 52)
              // Color.fromARGB(255, 247, 184, 106)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/gossip_logo.png', // Replace with your actual path
                  height: 100,
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                // 1. TEXT
                if (showText)
                  SlideTransition(
                    position: _textOffset,
                    child: Text(
                      "Enter your mobile number to get started",
                      style: TextStyle(
                        fontSize:
                            AppTheme.lightTheme.textTheme.titleLarge!.fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black26,
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (showText)
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                // 2. ARROW
                if (showArrow)
                  SlideTransition(
                    position: _arrowOffset,
                    child: Image.asset(
                      "assets/gif/arrow_down.gif",
                      height: 70,
                    ),
                  ),
                if (showArrow)
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                // 3. TEXT FIELD
                if (showField)
                  SlideTransition(
                    position: _fieldOffset,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Mobile Number',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (showField)
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                // 4. BUTTON
                if (showBtn)
                  SlideTransition(
                    position: _btnOffset,
                    child: Column(
                      children: [
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  const Color.fromARGB(255, 250, 103, 5),
                              elevation: 6,
                              padding: EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              // Handle login
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),

                        // Signup TextButton
                        TextButton(
                          onPressed: () {
                            // Navigate to Signup screen
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SignupScreen()));
                          },
                          child: Text(
                            "Don't have an account? Sign up",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
