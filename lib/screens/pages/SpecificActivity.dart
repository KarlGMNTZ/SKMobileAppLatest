import 'package:flutter/material.dart';
import 'package:sk_app/screens/pages/registration_page.dart';

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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RegistrationPage(
                            activityID: widget.activityID,
                          )));
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
