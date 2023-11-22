import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sk_app/screens/pages/SpecificActivity.dart';
import 'package:sk_app/services/add_activities.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:intl/intl.dart';
import '../../utils/colors.dart';
import '../../widgets/textfield_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late String idFileName = '';

  late File idImageFile;

  late String idImageURL = '';

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
        addActivityDialog(context, false, '', '');
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

  final box = GetStorage();
  DateTime? selectedDateTime; // To store the DateTime
  Timestamp? expirationDate; // To store the Timestamp

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: box.read('role') == 'Admin'
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                addActivityDialog(context, false, '', '');
              })
          : null,
      body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('Activities').snapshots(),
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
                )),
              );
            }
            final data = snapshot.requireData;
            final currentTime = Timestamp.now();

            final activities = data.docs.where((doc) {
              final dataMap = doc.data() as Map<String, dynamic>;

              if (dataMap.containsKey('expirationDate')) {
                final expirationDate = dataMap['expirationDate'] as Timestamp;

                // Filter out activities that have not yet expired
                return expirationDate.toDate().isAfter(currentTime.toDate());
              } else {
                // Handle the case where the field does not exist (optional)
                // You can decide whether to include or exclude activities without an expiration date
                // In this example, we include them, but you can modify this behavior as needed.
                return true;
              }
            }).toList();

            return ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Card(
                  child: ListTile(
                    onTap: () {
                      if (box.read('role') == 'Admin') {
                        setState(() {
                          nameController.text = activity['name'];
                          descController.text = activity['description'];
                        });
                        addActivityDialog(
                            context, true, activity.id, activity['imageUrl']);
                      } else if (box.read('role') == 'User') {
                        // Navigate to the SpecificActivity screen when a user clicks the activity
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpecificActivity(
                              activityID: activity.id,
                              activityName: activity['name'],
                              activityDescription: activity['description'],
                              imageUrl: activity['imageUrl'],
                            ),
                          ),
                        );
                      }
                    },
                    title: TextWidget(
                      text: activity['name'],
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'Bold',
                    ),
                    subtitle: TextWidget(
                      text: activity['description'],
                      fontSize: 12,
                      maxLines: 2,
                      color: Colors.grey,
                    ),
                    trailing: box.read('role') == 'Admin'
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editActivityImage(context, activity.id);
                            },
                          )
                        : null,
                  ),
                );
              },
            );
          }),
    );
  }

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();

  addActivityDialog(context, bool inEdit, String id, String image) {
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
            text: 'Posting Activities',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: SingleChildScrollView(
            // Wrap content in SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    uploadImage('gallery');
                  },
                  child: Container(
                    height: 150,
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
                  label: 'Name of Activity',
                  controller: nameController,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldWidget(
                  label: 'Description of Activity',
                  controller: descController,
                  maxLine: 3, // Adjust the number of visible lines
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 10,
                ),
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
          ),
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
                        .collection('Activities')
                        .doc(id)
                        .update({
                      'name': nameController.text,
                      'description': descController.text
                    });
                  } else {
                    addActivities(
                      idImageURL,
                      nameController.text,
                      descController.text,
                      dateController.text,
                      expirationDate as Timestamp,
                    );
                  }

                  Navigator.pop(context);

                  // Show success toast
                  Fluttertoast.showToast(
                    msg: 'Post successfully updated!',
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
            )
          ],
        );
      },
    );
  }

  void dateFromPicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: primary,
                onPrimary: Colors.white,
                onSurface: Colors.grey,
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050));

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      setState(() {
        dateController.text = formattedDate;
      });
    } else {
      return null;
    }
  }
}

Future<void> editActivityImage(BuildContext context, String activityId) async {
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
          padding: EdgeInsets.only(left: 10, right: 10),
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
                  'Uploading . .',
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
      FirebaseFirestore.instance
          .collection('Activities')
          .doc(activityId)
          .update({
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
