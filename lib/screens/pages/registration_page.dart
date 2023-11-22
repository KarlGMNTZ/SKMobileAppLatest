import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sk_app/services/add_registration.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:sk_app/widgets/textfield_widget.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../../widgets/toast_widget.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key, required this.activityID})
      : super(key: key);
  final String activityID;
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late String idImageFileName = '';
  late String idFileFileName = '';
  late String idImageFileUrl = '';
  late String idFileFileUrl = '';
  late File idImageFile;
  File? idFile;

  final teamnameController = TextEditingController();
  final commentController = TextEditingController();
  bool isRegistering = false;

  Future<void> uploadImage(BuildContext context, String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;

    try {
      pickedImage = (await picker.pickImage(
        source:
            inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
      ))!;

      setState(() {
        idImageFileName = path.basename(pickedImage.path);
        idImageFile = File(pickedImage.path);
      });

      // try {
      //   if (!context.mounted) return;
      //   showDialog(
      //     context: context,
      //     barrierDismissible: false,
      //     builder: (BuildContext context) => const Padding(
      //       padding: EdgeInsets.only(left: 30, right: 30),
      //       child: AlertDialog(
      //         title: Row(
      //           children: [
      //             CircularProgressIndicator(
      //               color: Colors.black,
      //             ),
      //             SizedBox(
      //               width: 20,
      //             ),
      //             Text(
      //               'Uploading...',
      //               style: TextStyle(
      //                 color: Colors.black,
      //                 fontWeight: FontWeight.bold,
      //                 fontFamily: 'QRegular',
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   );

      //   final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
      //       .ref('Document/$idImageFileName');

      //   final uploadTask = firebaseStorageRef.putFile(idImageFile);

      //   await uploadTask.whenComplete(() {
      //     firebaseStorageRef.getDownloadURL().then((imageUrl) {
      //       setState(() {
      //         idImageFileUrl = imageUrl;
      //       });
      //       Navigator.of(context).pop();
      //     });
      //   });
      // } on firebase_storage.FirebaseException catch (error) {
      //   if (kDebugMode) {
      //     print(error);
      //   }
      // }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  Future<void> uploadFile(BuildContext context, String inputSource) async {
    final picker = FilePicker.platform;
    File? pickedFile;

    try {
      final result = await picker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'jpg',
          'png',
        ],
      );

      if (result != null) {
        pickedFile = File(result.files.single.path!);
        idFileFileName = path.basename(pickedFile.path);
        setState(() {
          idFile = pickedFile;
        });

        // try {
        //   if (!context.mounted) return;
        //   showDialog(
        //     context: context,
        //     barrierDismissible: false,
        //     builder: (BuildContext context) => const Padding(
        //       padding: EdgeInsets.only(left: 30, right: 30),
        //       child: AlertDialog(
        //         title: Row(
        //           children: [
        //             CircularProgressIndicator(
        //               color: Colors.black,
        //             ),
        //             SizedBox(
        //               width: 20,
        //             ),
        //             Text(
        //               'Uploading...',
        //               style: TextStyle(
        //                 color: Colors.black,
        //                 fontWeight: FontWeight.bold,
        //                 fontFamily: 'QRegular',
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   );

        //   final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
        //       .ref('Files/$idFileFileName');

        //   final uploadTask = firebaseStorageRef.putFile(idFile);

        //   await uploadTask.whenComplete(() {
        //     firebaseStorageRef.getDownloadURL().then((url) {
        //       setState(() {
        //         idFileFileUrl = url;
        //       });
        //       Navigator.of(context).pop();
        //     });
        //   });
        // } on firebase_storage.FirebaseException catch (error) {
        //   if (kDebugMode) {
        //     print(error);
        //   }
        // }
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
        backgroundColor: const Color.fromRGBO(245, 199, 177, 100),
        title: const TextWidget(
          text: 'Fill out the form',
          fontSize: 18,
          color: Colors.white,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
      body: isRegistering == true
          ? const SizedBox(
              child: Expanded(
                  child: Center(
                child: CircularProgressIndicator(),
              )),
            )
          : SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: 750,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(245, 199, 177, 100),
                    ),
                    child: Image.network(
                      'https://raw.githubusercontent.com/abuanwar072/Meditation-App/master/assets/images/undraw_pilates_gpdb.png',
                      height: 1200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Spacer(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextFieldWidget(
                                    height: 70,
                                    maxLine: 3,
                                    label: 'Input Name',
                                    controller: teamnameController,
                                  ),
                                ),
                                SizedBox(width: 10), // Add some spacing
                                // Small icon button
                                IconButton(
                                  icon: Icon(Icons.info_outline,
                                      size:
                                          20), // You can choose any icon you want
                                  onPressed: () {
                                    // Show dialog when the icon is clicked
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Information"),
                                          content: Text(
                                            "If it is a single registration activity, just put your name.\n \n If it is a team registration, you must all register and put your team name.",
                                          ),
                                          actions: [
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
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                TextFieldWidget(
                                  height: 100,
                                  width: 300,
                                  maxLine: 7,
                                  label: 'Tell us more',
                                  controller: commentController,
                                ),
                                IconButton(
                                  icon: Icon(Icons.info_outline,
                                      size:
                                          20), // You can choose any icon you want
                                  onPressed: () {
                                    // Show dialog when the icon is clicked
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Tell us more"),
                                          content: Text(
                                            "If you have any requests and message to SK office about your registration. Please let us know.",
                                          ),
                                          actions: [
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
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            GestureDetector(
                              onTap: () {
                                uploadImage(context, 'gallery');
                              },
                              child: Center(
                                child: Container(
                                  height: 50,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                        216, 111, 62, 0.969),
                                    image: idImageFileName.isEmpty
                                        ? null
                                        : DecorationImage(
                                            image: FileImage(idImageFile),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  child: const Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          'Upload Image Here!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  uploadFile(context, 'gallery');
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    const Color.fromRGBO(245, 199, 177, 100),
                                  ),
                                ),
                                child: Text(
                                  idFile == null
                                      ? 'Upload File'
                                      : idFileFileName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Add the registration to Firebase
                                  setState(() {
                                    isRegistering = true;
                                  });
                                  if (idImageFileName.isNotEmpty) {
                                    final firebaseStorageRef = firebase_storage
                                        .FirebaseStorage.instance
                                        .ref('Document/$idImageFileName');

                                    final uploadTask =
                                        firebaseStorageRef.putFile(idImageFile);

                                    await uploadTask.whenComplete(() {
                                      firebaseStorageRef
                                          .getDownloadURL()
                                          .then((imageUrl) {
                                        setState(() {
                                          idImageFileUrl = imageUrl;
                                          log("imageUrl: $imageUrl");
                                        });
                                      });
                                    });
                                  }
                                  if (idFile != null) {
                                    final firebaseStorageRef = firebase_storage
                                        .FirebaseStorage.instance
                                        .ref('Files/$idFileFileName');

                                    final uploadTask =
                                        firebaseStorageRef.putFile(idFile!);

                                    final snapshot =
                                        await uploadTask.whenComplete(() {});
                                    idFileFileUrl =
                                        await snapshot.ref.getDownloadURL();
                                  }
                                  await addRegistration(
                                      idImageFileUrl,
                                      teamnameController.text,
                                      commentController.text,
                                      idFileFileUrl,
                                      widget.activityID);

                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  showToast("Successfully Registered");

                                  // Store the registration ID in the activities collection
                                  // final activitiesCollection = FirebaseFirestore
                                  //     .instance
                                  //     .collection('Activities');

                                  // await activitiesCollection.doc('id').update({
                                  //   'regId': FieldValue.arrayUnion([registrationId]),
                                  // });

                                  // Navigate back to the first page of the application
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    const Color.fromRGBO(245, 199, 177, 100),
                                  ),
                                ),
                                child: const TextWidget(
                                  text: 'Submit',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
