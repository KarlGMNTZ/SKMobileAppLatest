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
    Key? key,
    required this.activityName,
    required this.activityDescription,
    required this.imageUrl,
    required this.activityID,
  }) : super(key: key);

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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specific Activity'),
        backgroundColor: Color.fromARGB(255, 242, 151, 101),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.activityName,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.activityDescription,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    checkIfAlreadyRegistered();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 242, 151, 101),
                  ),
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
