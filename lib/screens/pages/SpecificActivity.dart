import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sk_app/screens/pages/registration_page.dart';
import 'package:sk_app/widgets/toast_widget.dart';

class SpecificActivity extends StatefulWidget {
  final String activityName;
  final String activityDescription;
  final String imageUrl;
  final String activityID;

  const SpecificActivity({
    super.key,
    required this.activityName,
    required this.activityDescription,
    required this.imageUrl,
    required this.activityID,
  });

  @override
  State<SpecificActivity> createState() => _SpecificActivityState();
}

class _SpecificActivityState extends State<SpecificActivity> {
  checkIfAlreadyRegistered() async {
    var res = await FirebaseFirestore.instance
        .collection('Registration')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('activityID', isEqualTo: widget.activityID)
        .get();
    if (res.docs.isEmpty) {
      if (!context.mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RegistrationPage(
                activityID: widget.activityID,
              )));
    } else {
      showToast("Already registered! Thank you.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specific Activity'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 40),
              SizedBox(
                width: 250, // Set the desired width
                height: 350, // Set the desired height
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover, // You can adjust the fit as needed
                ),
              ),
              const SizedBox(height: 16), // Add some spacing
              Text(widget.activityName),
              const SizedBox(height: 8), // Add more spacing
              Text(widget.activityDescription),
              const SizedBox(height: 120), // Add spacing for the button
              ElevatedButton(
                onPressed: () {
                  checkIfAlreadyRegistered();
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
