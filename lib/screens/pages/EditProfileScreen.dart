import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Define TextEditingController for each field
  TextEditingController fnameController = TextEditingController();
  TextEditingController mnameController = TextEditingController();
  // Add controllers for other fields

  // Confirm password field
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers to prevent memory leaks
    fnameController.dispose();
    mnameController.dispose();
    // Dispose of other controllers
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Implement your editing logic here
  void editProfile() {
    addUserActivity(activity: "Edit his/her profile information");
    // You can access the values entered by the user using the controllers
    // final editedFirstName = fnameController.text;
    // final editedMiddleName = mnameController.text;
    // // Access other edited fields

    // // You can also access the new password and confirm password fields
    // final currentPassword = currentPasswordController.text;
    // final newPassword = newPasswordController.text;
    // final confirmPassword = confirmPasswordController.text;

    // Implement your logic for updating the user's information and changing the password
  }

  addUserActivity({required String activity}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      var res = await FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: user.uid)
          .get();
      if (res.docs.isNotEmpty) {
        String fname = res.docs[0].get('fname');
        String lname = res.docs[0].get('lname');
        String userimage = res.docs[0].get('profile');
        await FirebaseFirestore.instance.collection('UserActivities').add({
          "username": "$fname $lname",
          "userimage": userimage,
          "datetime": Timestamp.now(),
          "useraction": activity,
          "userRole": "user",
        });
      } else {
        await FirebaseFirestore.instance.collection('UserActivities').add({
          "username": user.email,
          "userimage":
              'https://firebasestorage.googleapis.com/v0/b/sk-app-56284.appspot.com/o/profilenew.jpg?alt=media&token=7ff9979b-9503-4b55-ae89-feb1065bdff2&_gl=1*1n7fjoj*_ga*MTgxNjUyOTc5NC4xNjk1MTAyOTYz*_ga_CW55HF8NVT*MTY5OTQzNTE4Ni4yMi4xLjE2OTk0MzU0MzcuNTQuMC4w',
          "datetime": Timestamp.now(),
          "useraction": activity,
          "userRole": "user",
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: fnameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              controller: mnameController,
              decoration: const InputDecoration(labelText: 'Middle Name'),
            ),
            // Add fields for other user details
            TextFormField(
              controller: currentPasswordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            TextFormField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextFormField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: editProfile,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
