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
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
      body: Container(
        height: 1000,
        color: const Color.fromARGB(241, 241, 182, 152),
        child: SingleChildScrollView(
          child: Column(
            children: [
              userData.isEmpty
                  ? Center(child: CircularProgressIndicator())
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
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
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
                              SizedBox(height: 20),
                              ListTile(
                                title: Text(
                                ' ${userData['email']}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Address: ${userData['address']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'Age: ${userData['age']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Mobile Number: ${userData['number']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'Educational Level: ${userData['school']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Youthclass: ${userData['youthclass']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'Work: ${userData['work']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Civil Status: ${userData['civilstatus']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'Birthdate: ${DateFormat('yyyy-MM-dd').format((userData['birthdate'] as Timestamp).toDate())}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Purok: ${userData['purok']}',
                                  style: TextStyle(
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
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(240, 237, 162, 124),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: Center(
                    child: Text('Edit Profile'),
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
