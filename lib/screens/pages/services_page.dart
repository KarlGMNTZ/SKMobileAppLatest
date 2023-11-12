import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sk_app/services/add_services.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import '../../widgets/textfield_widget.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final box = GetStorage();

  late String idFileName = '';

  late File idImageFile;

  late String idImageURL = '';

  DateTime? selectedDateTime; // To store the DateTime

  Timestamp? expirationDate; // To store the Timestamp

  Future<void> uploadImage(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

      idFileName = path.basename(pickedImage.path);
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
                  'Loading . . .',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular'),
                ),
              ],
            )),
          ),
        );

        await firebase_storage.FirebaseStorage.instance
            .ref('Document/$idFileName')
            .putFile(idImageFile);
        idImageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Document/$idFileName')
            .getDownloadURL();

        Navigator.of(context).pop();
        Navigator.of(context).pop();
        addServicesDialog(context, false, '', '');
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
      floatingActionButton: box.read('role') == 'Admin'
          ? FloatingActionButton(
              backgroundColor: const Color.fromRGBO(245, 199, 177, 100),
              onPressed: () {
                addServicesDialog(context, false, '', '');
              },
              child: const Icon(Icons.add))
          : null,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 199, 177, 100),
        title: const TextWidget(
          text: 'Services',
          fontSize: 18,
          color: Colors.white,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Services').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(child: Text('Error'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              );
            }

            final data = snapshot.requireData;

            // Filter out expired services

            final nonExpiredServices = data.docs.where((doc) {
              final dataMap = doc.data() as Map<String, dynamic>;

              if (dataMap.containsKey('expirationDate')) {
                final expirationDate = dataMap['expirationDate'] as Timestamp;
                final currentTime = Timestamp.now(); // Update currentTime here

                // Filter out surveys that have not yet expired
                return expirationDate.toDate().isAfter(currentTime.toDate());
              } else {
                // Handle the case where the field does not exist (optional)
                // You can decide whether to include or exclude surveys without an expiration date
                // In this example, we include them, but you can modify this behavior as needed.
                return true;
              }
            }).toList();

            return Center(
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    for (int i = 0; i < nonExpiredServices.length; i++)
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () {
                            if (box.read('role') == 'Admin') {
                              setState(() {
                                nameController.text =
                                    nonExpiredServices[i]['name'];
                                descController.text =
                                    nonExpiredServices[i]['description'];
                              });
                              addServicesDialog(
                                  context,
                                  true,
                                  nonExpiredServices[i].id,
                                  nonExpiredServices[i]['imageUrl']);
                            }
                          },
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                Container(
                                  height: 300,
                                  width: 500, // Fixed width
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          data.docs[i]['imageUrl']),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: 500, // Fixed width
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: data.docs[i]['name'],
                                            fontSize: 20,
                                            fontFamily: 'Nexa',
                                          ),
                                          const SizedBox(height: 1),
                                          const SizedBox(height: 10),
                                          TextWidget(
                                            text: data.docs[i]['description'],
                                            fontSize: 12,
                                            fontFamily: 'Helvetica',
                                            maxLines: 100,
                                          ),
                                          Visibility(
                                            visible:
                                                box.read('role') == 'Admin',
                                            child: IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                editServiceImage(
                                                    context,
                                                    data.docs[i].id,
                                                    data.docs[i]['name']);
                                              },
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
                      ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  final nameController = TextEditingController();
  final descController = TextEditingController();

  addServicesDialog(context, bool inEdit, String id, String image) {
    if (!inEdit) {
      setState(() {
        nameController.clear();
        descController.clear();
      });
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const TextWidget(
            text: 'Posting Services',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  inEdit
                      ? Container(
                          height: 100,
                          width: 300,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            image: DecorationImage(
                                image: NetworkImage(
                                  image,
                                ),
                                fit: BoxFit.cover),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            uploadImage('gallery');
                          },
                          child: Container(
                            height: 100,
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              image: idFileName == ''
                                  ? null
                                  : DecorationImage(
                                      image: NetworkImage(
                                        idImageURL,
                                      ),
                                      fit: BoxFit.cover),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFieldWidget(
                      label: 'Name of Service', controller: nameController),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFieldWidget(
                      label: 'Description of Service',
                      controller: descController),
                  Visibility(
                    visible: box.read('role') == 'Admin',
                    child: ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 1),
                        );

                        if (selectedDate != null) {
                          setState(() {
                            selectedDateTime = selectedDate;
                            expirationDate = Timestamp.fromDate(selectedDate);
                          });
                        }
                      },
                      child: const Text('Set Expiration Date'),
                    ),
                  )
                ],
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const TextWidget(
                text: 'Close',
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (inEdit) {
                    await FirebaseFirestore.instance
                        .collection('Services')
                        .doc(id)
                        .update({
                      'name': nameController.text,
                      'description': descController.text,
                      'expirationDate': expirationDate,
                    });
                  } else {
                    addServices(
                      idImageURL,
                      nameController.text,
                      descController.text,
                      expirationDate as Timestamp,
                    );
                  }

                  Navigator.pop(context);

                  // Show success toast
                  Fluttertoast.showToast(
                    msg: inEdit
                        ? 'Service successfully updated!'
                        : 'Service posted successfully!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                } catch (e) {
                  // Show error toast
                  Fluttertoast.showToast(
                    msg: 'Please fill out all required fields',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              child: const TextWidget(
                text: 'Post',
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> editServiceImage(
    BuildContext context, String serviceId, doc) async {
  final picker = ImagePicker();
  XFile pickedImage;
  try {
    pickedImage = (await picker.pickImage(
      source: ImageSource
          .gallery, // You can change this to allow choosing from the camera as well
      maxWidth: 1920,
    ))!;

    String newImageFileName = path.basename(pickedImage.path);
    File newImageFile = File(pickedImage.path);

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
                  'Uploading . . .',
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

      await firebase_storage.FirebaseStorage.instance
          .ref('Document/$newImageFileName')
          .putFile(newImageFile);

      String newImageURL = await firebase_storage.FirebaseStorage.instance
          .ref('Document/$newImageFileName')
          .getDownloadURL();

      // Update the activity with the new image URL
      FirebaseFirestore.instance.collection('Services').doc(serviceId).update({
        'imageUrl': newImageURL,
      });

      Navigator.of(context).pop();
      Navigator.of(context).pop();

      // Optionally, you can show a success message or perform other actions
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
