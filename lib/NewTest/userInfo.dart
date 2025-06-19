import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  String? _gender;
  DateTime? _dob;
  TimeOfDay? _tob;

  int _currentStep = 0;

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickTimeOfBirth() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _tob ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _tob = picked);
  }

  void _nextStep() {
    if (_currentStep == 0 && _nameController.text.trim().isEmpty) {
      _showError("Please enter your full name");
    } else if (_currentStep == 1 && _dob == null) {
      _showError("Please select date of birth");
    } else if (_currentStep == 2 && _tob == null) {
      _showError("Please select time of birth");
    } else if (_currentStep == 3 && _placeController.text.trim().isEmpty) {
      _showError("Please enter place of birth");
    } else if (_currentStep == 4 && _gender == null) {
      _showError("Please select gender");
    } else {
      if (_currentStep < 4) {
        setState(() => _currentStep++);
      } else {
        _submitForm();
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _submitForm() {
    final name = _nameController.text.trim();
    final place = _placeController.text.trim();
    final dob = DateFormat.yMMMMd().format(_dob!);
    final tob = _tob!.format(context);

    print("Name: $name\nGender: $_gender\nDOB: $dob\nTOB: $tob\nPlace: $place");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Details submitted successfully!")),
    );
  }

  Widget _styledContainer({required Widget child}) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _styledContainer(
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: "Full Name",
            ),
          ),
        );
      case 1:
        return InkWell(
          onTap: _pickDateOfBirth,
          child: _styledContainer(
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Date of Birth",
                border: InputBorder.none,
              ),
              child: Text(
                _dob != null
                    ? DateFormat.yMMMMd().format(_dob!)
                    : "Select Date",
                style: TextStyle(
                  color: _dob != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
        );
      case 2:
        return InkWell(
          onTap: _pickTimeOfBirth,
          child: _styledContainer(
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Time of Birth",
                border: InputBorder.none,
              ),
              child: Text(
                _tob != null ? _tob!.format(context) : "Select Time",
                style: TextStyle(
                  color: _tob != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
        );
      case 3:
        return _styledContainer(
          child: TextField(
            controller: _placeController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: "Place of Birth",
            ),
          ),
        );
      case 4:
        return _styledContainer(
          child: DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(
              labelText: "Gender",
              border: InputBorder.none,
            ),
            items: ['Male', 'Female', 'Other']
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (value) => setState(() => _gender = value),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return "Enter Full Name";
      case 1:
        return "Select Date of Birth";
      case 2:
        return "Select Time of Birth";
      case 3:
        return "Enter Place of Birth";
      case 4:
        return "Select Gender";
      default:
        return "";
    }
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
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  _getStepTitle(),
                  style: const TextStyle(
                    fontSize: 24,
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
                const SizedBox(height: 30),
                _buildStepContent(),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 250, 103, 5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentStep < 4 ? "Continue" : "Submit",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
