import 'package:chattest/NewTest/home_screen.dart';
import 'package:chattest/NewTest/login_with_otp_screen.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _firstNameController;
  late final AnimationController _lastNameController;
  late final AnimationController _phoneController;
  late final AnimationController _buttonController;

  late final Animation<Offset> _logoOffset;
  late final Animation<Offset> _firstNameOffset;
  late final Animation<Offset> _lastNameOffset;
  late final Animation<Offset> _phoneOffset;
  late final Animation<Offset> _buttonOffset;

  bool showLogo = false;
  bool showFirstName = false;
  bool showLastName = false;
  bool showPhone = false;
  bool showButtons = false;

  @override
  void initState() {
    super.initState();

    _logoController = _createController();
    _firstNameController = _createController();
    _lastNameController = _createController();
    _phoneController = _createController();
    _buttonController = _createController();

    _logoOffset = _createOffsetAnimation(_logoController);
    _firstNameOffset = _createOffsetAnimation(_firstNameController);
    _lastNameOffset = _createOffsetAnimation(_lastNameController);
    _phoneOffset = _createOffsetAnimation(_phoneController);
    _buttonOffset = _createOffsetAnimation(_buttonController);

    _startAnimations();
  }

  AnimationController _createController() {
    return AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Animation<Offset> _createOffsetAnimation(AnimationController controller) {
    return Tween<Offset>(begin: const Offset(0, -0.8), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  Future<void> _startAnimations() async {
    setState(() => showLogo = true);
    await _logoController.forward();

    setState(() => showFirstName = true);
    await _firstNameController.forward();

    setState(() => showLastName = true);
    await _lastNameController.forward();

    setState(() => showPhone = true);
    await _phoneController.forward();

    setState(() => showButtons = true);
    await _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 250, 103, 5),
              Color.fromARGB(255, 255, 160, 52),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLogo)
                  SlideTransition(
                      position: _logoOffset,
                      child: Container(
                        // padding:  EdgeInsets.only(bottom: 32),
                        child: Image.asset(
                          "assets/images/logo.png",
                          height: 100,
                        ),
                      )),
                // if (showLogo)
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                if (showFirstName)
                  SlideTransition(
                    position: _firstNameOffset,
                    child: _buildInputField(label: "First Name"),
                  ),
                if (showFirstName) const SizedBox(height: 16),
                if (showLastName)
                  SlideTransition(
                    position: _lastNameOffset,
                    child: _buildInputField(label: "Last Name"),
                  ),
                if (showLastName) const SizedBox(height: 16),
                if (showPhone)
                  SlideTransition(
                    position: _phoneOffset,
                    child: _buildInputField(
                        label: "Mobile Number",
                        keyboardType: TextInputType.phone),
                  ),
                if (showPhone) const SizedBox(height: 24),
                if (showButtons)
                  SlideTransition(
                    position: _buttonOffset,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  const Color.fromARGB(255, 250, 103, 5),
                              elevation: 6,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              // Handle register
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LoginWithOtpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Already have an account? Login",
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

  Widget _buildInputField({
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black26,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
