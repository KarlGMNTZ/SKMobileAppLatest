import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sk_app/screens/pages/EditProfileScreen.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UserInfoDisplay extends StatefulWidget {
  const UserInfoDisplay({super.key});

  @override
  State<UserInfoDisplay> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<UserInfoDisplay> {
  late File imageFile;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? currentUser;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    getUserData();
    _checkProfileUpdateReminder();
  }

  bool _isUpdateDialogShown = false;

  Future<void> _checkProfileUpdateReminder() async {
    if (_isUpdateDialogShown) {
      return; // Skip checking if the dialog has already been shown
    }

    final docUser = _firestore.collection('Users').doc(currentUser!.uid);
    final docSnapshot = await docUser.get();

    if (docSnapshot.exists) {
      final userDataFromFirestore = docSnapshot.data() as Map<String, dynamic>;
      final lastEditTimeString = userDataFromFirestore['editTime'] as String?;

      if (lastEditTimeString != null) {
        DateTime lastEditTime = DateTime.parse(lastEditTimeString);

        DateTime sixMonthsLater = lastEditTime.add(Duration(days: 6 * 30));

        if (DateTime.now().isAfter(sixMonthsLater)) {
          _showUpdateProfileDialog();
        }
      }
    }
  }

  Future<void> _showUpdateProfileDialog() async {
    _isUpdateDialogShown = true; // Set the flag to true

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Profile"),
          content: Text(
            "Please update your profile by visiting the SK office. Your account will be deactivated if not updated.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> getUserData() async {
    final docUser = _firestore.collection('Users').doc(currentUser!.uid);
    final docSnapshot = await docUser.get();
    if (docSnapshot.exists) {
      setState(() {
        userData = docSnapshot.data() as Map<String, dynamic>;
      });
    }
  }

  Future<void> editUserProfileImage(BuildContext context, String userId) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
      ))!;

      String newImageFileName = path.basename(pickedImage.path);
      File newImageFile = File(pickedImage.path);

      try {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(
                color: Colors.black,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Uploading . . .',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'QRegular',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
        ));

        await firebase_storage.FirebaseStorage.instance
            .ref('Users/$newImageFileName')
            .putFile(newImageFile);

        String newImageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Users/$newImageFileName')
            .getDownloadURL();

        // Update the user's profile image URL
        FirebaseFirestore.instance.collection('Users').doc(userId).update({
          'profile': newImageURL,
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Refresh the screen to reflect the updated data
        getUserData();
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        toolbarHeight: 80,
        centerTitle: true,
        // You can customize the appbar further as needed
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: const Color.fromARGB(241, 241, 182, 152),
        child: SingleChildScrollView(
          child: Column(
            children: [
              userData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      padding: const EdgeInsets.all(10),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    minRadius: 50,
                                    maxRadius: 50,
                                    backgroundImage:
                                        NetworkImage(userData['profile']),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () {
                                        editUserProfileImage(
                                            context, currentUser!.uid);
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ListTile(
                                title: Text(
                                  'Email: ${userData['email']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  'Address: ${userData['address']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  'Age: ${userData['age']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  'Mobile Number: +63 ${userData['number']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  'Educational Level: ${userData['school']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  'Youthclass: ${userData['youthclass']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  'Work Status: ${userData['work']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  'Civil Status: ${userData['civilstatus']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  'Birthdate: ${DateFormat('yyyy-MM-dd').format((userData['birthdate'] as Timestamp).toDate())}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(
                                  'Purok: ${userData['purok']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
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
}
