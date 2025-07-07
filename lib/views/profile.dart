import 'package:chattest/Utils/Services/auth.dart';
import 'package:chattest/Utils/Services/shared_pref.dart';
import 'package:chattest/views/starter/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? myUserName, myName, myEmail, myPicture = "";

  getTheSharedpreferenceData() async {
    myUserName = await SharedPreferenceHelper().getUserName();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPicture = await SharedPreferenceHelper().getUserImage();
    setState(() {});
  }

  @override
  void initState() {
    onLoad();
    super.initState();
  }

  onLoad() async {
    await getTheSharedpreferenceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade800, Colors.blueGrey.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: myPicture != null && myPicture!.isNotEmpty
                                  ? Image.network(
                                      myPicture!,
                                      height: 140,
                                      width: 140,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: 70,
                                          color: Colors.grey.shade500,
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Colors.grey.shade500,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        // Name Card
                        _buildInfoCard(
                          icon: Icons.person,
                          label: "Name",
                          value: myName ?? "Not set",
                        ),
                        SizedBox(height: 20),
                        // Email Card
                        _buildInfoCard(
                          icon: Icons.email,
                          label: "Email",
                          value: myEmail ?? "Not set",
                        ),
                        SizedBox(height: 30),
                        // Logout Button
                        _buildActionButton(
                          icon: Icons.logout,
                          text: "Log Out",
                          onTap: () async {
                            await Authmethods().signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Onbpoarding()),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        // Delete Account Button
                        _buildActionButton(
                          icon: Icons.delete,
                          text: "Delete Account",
                          textColor: Colors.red,
                          onTap: () async {
                            await Authmethods().delete();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Onbpoarding()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue.shade400, size: 24),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.red.shade400, size: 24),
          ),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
