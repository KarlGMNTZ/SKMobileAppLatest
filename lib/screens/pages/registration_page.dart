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

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late String idImageFileName = '';
  late String idFileFileName = '';
  late String idImageFileUrl = '';
  late String idFileFileUrl = '';
  late File idImageFile;
  late File idFile;

  final teamnameController = TextEditingController();
  final commentController = TextEditingController();

  Future<void> uploadImage(BuildContext context, String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;

    try {
      pickedImage = (await picker.pickImage(
        source:
            inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
      ))!;

      idImageFileName = path.basename(pickedImage.path);
      idImageFile = File(pickedImage.path);

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: AlertDialog(
              title: Row(
                children: [
                  CircularProgressIndicator(
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Uploading...',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
            .ref('Document/$idImageFileName');

        final uploadTask = firebaseStorageRef.putFile(idImageFile);

        await uploadTask.whenComplete(() {
          firebaseStorageRef.getDownloadURL().then((imageUrl) {
            setState(() {
              idImageFileUrl = imageUrl;
            });
            Navigator.of(context).pop();
          });
        });
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
        idFile = pickedFile;

        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => const Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: AlertDialog(
                title: Row(
                  children: [
                    CircularProgressIndicator(
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Uploading...',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'QRegular',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
              .ref('Files/$idFileFileName');

          final uploadTask = firebaseStorageRef.putFile(idFile);

          await uploadTask.whenComplete(() {
            firebaseStorageRef.getDownloadURL().then((url) {
              setState(() {
                idFileFileUrl = url;
              });
              Navigator.of(context).pop();
            });
          });
        } on firebase_storage.FirebaseException catch (error) {
          if (kDebugMode) {
            print(error);
          }
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
        backgroundColor: Color.fromRGBO(245, 199, 177, 100),
        title: TextWidget(
          text: 'Fill out the form',
          fontSize: 18,
          color: Colors.white,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFieldWidget(
                        height: 150,
                        maxLine: 10,
                        label: 'Input Team Name',
                        controller: teamnameController,
                      ),
                      SizedBox(height: 30),
                      TextFieldWidget(
                        height: 150,
                        maxLine: 10,
                        label: 'Input Comments',
                        controller: commentController,
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          uploadImage(context, 'gallery');
                        },
                        child: Center(
                          child: Container(
                            height: 50,
                            width: 300,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(216, 111, 62, 0.969),
                              image: idImageFileName.isEmpty
                                  ? null
                                  : DecorationImage(
                                      image: NetworkImage(idImageFileUrl),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            child: Stack(
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
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            uploadFile(context, 'gallery');
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromRGBO(245, 199, 177, 100),
                            ),
                          ),
                          child: Text(
                            'Upload File',
                            style: TextStyle(
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
                            final registrationId = await addRegistration(
                                idImageFileUrl,
                                teamnameController.text,
                                commentController.text,
                                idFileFileUrl);

                            // Store the registration ID in the activities collection
                            final activitiesCollection = FirebaseFirestore
                                .instance
                                .collection('Activities');

                            await activitiesCollection.doc('id').update({
                              'regId': FieldValue.arrayUnion([registrationId]),
                            });

                            // Navigate back to the first page of the application
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromRGBO(245, 199, 177, 100),
                            ),
                          ),
                          child: TextWidget(
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
