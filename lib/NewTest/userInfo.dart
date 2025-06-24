import 'package:flutter/material.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _latitude = TextEditingController();
  final TextEditingController _longitude = TextEditingController();

  String? _gender;
  String? _marriageStatus;
  String? _day;
  String? _month;
  String? _year;
  String? _hour;
  String? _minute;

  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        "name": _firstName.text.trim(),
        "lname": _lastName.text.trim(),
        "date": _day,
        "month": _month,
        "year": _year,
        "hour": _hour,
        "minute": _minute,
        "location": _location.text.trim(),
        "latitude": double.tryParse(_latitude.text),
        "longitude": double.tryParse(_longitude.text),
        "gender": _gender,
        "marriage_status": _marriageStatus,
        "primary": true
      };

      print("Submitted Data: $data");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details submitted successfully!")),
      );
    }
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Required" : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: const TextStyle(color: Colors.deepOrange),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("User Info Form"),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _firstName,
                  decoration: _inputDecoration("First Name"),
                  validator: (val) => val!.isEmpty ? "Enter first name" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastName,
                  decoration: _inputDecoration("Last Name"),
                  validator: (val) => val!.isEmpty ? "Enter last name" : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: _inputDecoration("Day"),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _day = val,
                        validator: (val) => val!.isEmpty ? "Enter day" : null,
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: _buildDropdownField(
                        label: "Month",
                        value: _month,
                        items: months,
                        onChanged: (val) => setState(() => _month = val),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: TextFormField(
                        decoration: _inputDecoration("Year"),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _year = val,
                        validator: (val) => val!.isEmpty ? "Enter year" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: _inputDecoration("Hour"),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _hour = val,
                        validator: (val) => val!.isEmpty ? "Enter hour" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: _inputDecoration("Minute"),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _minute = val,
                        validator: (val) =>
                            val!.isEmpty ? "Enter minute" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _location,
                  decoration: _inputDecoration("Location"),
                  validator: (val) => val!.isEmpty ? "Enter location" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _latitude,
                  decoration: _inputDecoration("Latitude"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _longitude,
                  decoration: _inputDecoration("Longitude"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: "Gender",
                  value: _gender,
                  items: ["Male", "Female", "Other"],
                  onChanged: (val) => setState(() => _gender = val),
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: "Marital Status",
                  value: _marriageStatus,
                  items: ["Single", "Married", "Divorced", "Widowed"],
                  onChanged: (val) => setState(() => _marriageStatus = val),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Submit", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';

// class UserInfo extends StatefulWidget {
//   const UserInfo({super.key});

//   @override
//   State<UserInfo> createState() => _UserInfoState();
// }

// class _UserInfoState extends State<UserInfo> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _firstName = TextEditingController();
//   final TextEditingController _lastName = TextEditingController();
//   final TextEditingController _location = TextEditingController();
//   final TextEditingController _latitude = TextEditingController();
//   final TextEditingController _longitude = TextEditingController();

//   String? _gender;
//   String? _marriageStatus;
//   String? _day;
//   String? _month;
//   String? _year;
//   String? _hour;
//   String? _minute;

//   final List<String> months = [
//     "January", "February", "March", "April", "May", "June",
//     "July", "August", "September", "October", "November", "December"
//   ];

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       final data = {
//         "name": _firstName.text.trim(),
//         "lname": _lastName.text.trim(),
//         "date": _day,
//         "month": _month,
//         "year": _year,
//         "hour": _hour,
//         "minute": _minute,
//         "location": _location.text.trim(),
//         "latitude": double.tryParse(_latitude.text),
//         "longitude": double.tryParse(_longitude.text),
//         "gender": _gender,
//         "marriage_status": _marriageStatus,
//         "primary": true
//       };

//       print("Submitted Data: $data");

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Details submitted successfully!")),
//       );
//     }
//   }

//   Widget _buildDropdownField<T>({
//     required String label,
//     required T? value,
//     required List<T> items,
//     required void Function(T?) onChanged,
//   }) {
//     return DropdownButtonFormField<T>(
//       value: value,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       items: items
//           .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
//           .toList(),
//       onChanged: onChanged,
//       validator: (val) => val == null ? "Required" : null,
//     );
//   }

//   InputDecoration _inputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData(
//         colorSchemeSeed: Colors.deepOrange,
//         useMaterial3: true,
//       ),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("User Info Form"),
//           backgroundColor: Colors.deepOrange,
//           foregroundColor: Colors.white,
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: _firstName,
//                   decoration: _inputDecoration("First Name"),
//                   validator: (val) =>
//                       val!.trim().isEmpty ? "Enter first name" : null,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _lastName,
//                   decoration: _inputDecoration("Last Name"),
//                   validator: (val) =>
//                       val!.trim().isEmpty ? "Enter last name" : null,
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         decoration: _inputDecoration("Day"),
//                         keyboardType: TextInputType.number,
//                         onChanged: (val) => _day = val,
//                         validator: (val) {
//                           if (val == null || val.isEmpty) return "Enter day";
//                           final day = int.tryParse(val);
//                           if (day == null || day < 1 || day > 31) {
//                             return "Day must be 1-31";
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildDropdownField(
//                         label: "Month",
//                         value: _month,
//                         items: months,
//                         onChanged: (val) => setState(() => _month = val),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: TextFormField(
//                         decoration: _inputDecoration("Year"),
//                         keyboardType: TextInputType.number,
//                         onChanged: (val) => _year = val,
//                         validator: (val) {
//                           if (val == null || val.isEmpty) return "Enter year";
//                           if (val.length != 4) return "Year must be 4 digits";
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         decoration: _inputDecoration("Hour"),
//                         keyboardType: TextInputType.number,
//                         onChanged: (val) => _hour = val,
//                         validator: (val) {
//                           if (val == null || val.isEmpty) return "Enter hour";
//                           final h = int.tryParse(val);
//                           if (h == null || h < 0 || h > 23) {
//                             return "Hour must be 0–23";
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: TextFormField(
//                         decoration: _inputDecoration("Minute"),
//                         keyboardType: TextInputType.number,
//                         onChanged: (val) => _minute = val,
//                         validator: (val) {
//                           if (val == null || val.isEmpty) return "Enter minute";
//                           final m = int.tryParse(val);
//                           if (m == null || m < 0 || m > 59) {
//                             return "Minute must be 0–59";
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _location,
//                   decoration: _inputDecoration("Location"),
//                   validator: (val) =>
//                       val!.trim().isEmpty ? "Enter location" : null,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _latitude,
//                   decoration: _inputDecoration("Latitude"),
//                   keyboardType: TextInputType.number,
//                   validator: (val) {
//                     if (val == null || val.isEmpty) return "Enter latitude";
//                     final lat = double.tryParse(val);
//                     if (lat == null || lat < -90 || lat > 90) {
//                       return "Invalid latitude (-90 to 90)";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _longitude,
//                   decoration: _inputDecoration("Longitude"),
//                   keyboardType: TextInputType.number,
//                   validator: (val) {
//                     if (val == null || val.isEmpty) return "Enter longitude";
//                     final lng = double.tryParse(val);
//                     if (lng == null || lng < -180 || lng > 180) {
//                       return "Invalid longitude (-180 to 180)";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 _buildDropdownField(
//                   label: "Gender",
//                   value: _gender,
//                   items: ["Male", "Female", "Other"],
//                   onChanged: (val) => setState(() => _gender = val),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildDropdownField(
//                   label: "Marital Status",
//                   value: _marriageStatus,
//                   items: ["Single", "Married", "Divorced", "Widowed"],
//                   onChanged: (val) => setState(() => _marriageStatus = val),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: _submitForm,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 16, horizontal: 32),
//                     backgroundColor: Colors.deepOrange,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text("Submit", style: TextStyle(fontSize: 16)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

