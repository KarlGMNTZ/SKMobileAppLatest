import 'dart:io';

import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:sk_app/screens/pages/helpdesk/add_helpdesk_page.dart';
import 'package:sk_app/services/add_helpdesk.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:sk_app/widgets/textfield_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

class MainHelpdeskScreen extends StatefulWidget {
  const MainHelpdeskScreen({Key? key}) : super(key: key);

  @override
  _MainHelpdeskScreenState createState() => _MainHelpdeskScreenState();
}

class _MainHelpdeskScreenState extends State<MainHelpdeskScreen> {
  late String idImageFileName = '';
  late String idFileFileName = ''; // Separate variable for file name
  late String idImageFileUrl = '';
  late String idFileFileUrl = ''; // Separate variable for file URL
  late File idImageFile;
  late File idFile;

  Future<void> uploadImage(BuildContext context, String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;

    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

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
            // Image successfully uploaded, and the URL is retrieved
            setState(() {
              idImageFileUrl = imageUrl; // Use idImageFileUrl for the image URL
            });
            Navigator.of(context).pop(); // Close the loading dialog
          });
        });

        // Push the current screen back onto the navigation stack to stay on the same screen
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
              // File successfully uploaded, and the URL is retrieved
              setState(() {
                idFileFileUrl = url; // Use idFileFileUrl for the file URL
              });
              Navigator.of(context).pop(); // Close the loading dialog
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

  final box = GetStorage();

  TextEditingController chairmanController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController concernController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with values from GetStorage
    chairmanController.text = box.read('chairman') ?? '';
    emailController.text = box.read('email') ?? '';
    phoneController.text = box.read('phone') ?? '';
    concernController.text = box.read('description') ?? '';
  }

  Future<void> _showEditDialog(BuildContext context) async {
    chairmanController.text = box.read('chairman') ?? '';
    emailController.text = box.read('email') ?? '';
    phoneController.text = box.read('phone') ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Contact Information'),
          content: Column(
            children: [
              TextField(
                controller: chairmanController,
                decoration: const InputDecoration(labelText: 'SK Chairman'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the updated information
                box.write('chairman', chairmanController.text);
                box.write('email', emailController.text);
                box.write('phone', phoneController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Contact Information'),
      content: Column(
        children: [
          TextField(
            controller: chairmanController,
            decoration: const InputDecoration(labelText: 'SK Chairman'),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Save the updated information
            box.write('chairman', chairmanController.text);
            box.write('email', emailController.text);
            box.write('phone', phoneController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 199, 177, 100),
        title: TextWidget(
          text: 'Help Desk',
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
                        label: 'Input your concern',
                        controller: concernController,
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          uploadImage(context, 'gallery');
                        },
                        child: Center(
                          child: Container(
                            height: 150,
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
                                      color: Colors.white, // Set the text color
                                      fontSize: 24, // Set the font size
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            uploadFile(context,
                                'gallery'); // Call your upload function here
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromRGBO(245, 199, 177, 100),
                            ), // Set your desired color
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
                          onPressed: () {
                            // Submit the concern and image here
                            addHelpdesk(idImageFileUrl, concernController.text,
                                idFileFileUrl);

                            // Navigate back to the main home screen
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromRGBO(245, 199, 177, 100),
                            ), // Set your desired color
                          ),
                          child: TextWidget(
                            text: 'Submit',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      const Center(
                        child: Text(
                          'For more information please contact',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'SK Chairman: ${chairmanController.text}',
                        style: const TextStyle(fontSize: 15.0),
                      ),
                      Text(
                        'Email: ${emailController.text}',
                        style: const TextStyle(fontSize: 15.0),
                      ),
                      Text(
                        'Phone: ${phoneController.text}',
                        style: const TextStyle(fontSize: 15.0),
                      ),
                      const SizedBox(height: 16.0),
                      Visibility(
                        visible: box.read('role') == 'Admin',
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return _buildEditDialog(context);
                                },
                              ).then((_) {
                                // Update UI with the new values after the dialog is closed
                                setState(() {
                                  // Fetch the updated values from storage after the dialog is closed
                                  chairmanController.text =
                                      box.read('chairman') ?? '';
                                  emailController.text =
                                      box.read('email') ?? '';
                                  phoneController.text =
                                      box.read('phone') ?? '';
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(180, 146, 129, 1),
                            ),
                            child: const Text('Edit Contact Info'),
                          ),
                        ),
                      )
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
