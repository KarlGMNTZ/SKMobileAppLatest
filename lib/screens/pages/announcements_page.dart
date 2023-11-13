import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sk_app/services/add_announcements.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:sk_app/widgets/textfield_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'dart:io';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({
    super.key,
  });

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
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
        addAnnouncementDialog(context, false, '', '');
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

  DateTime? selectedDateTime; // To store the DateTime
  Timestamp? expirationDate; // To store the Timestamp

  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: box.read('role') == 'Admin'
          ? FloatingActionButton(
              backgroundColor: const Color.fromRGBO(245, 199, 177, 100),
              onPressed: () {
                addAnnouncementDialog(context, false, '', '');
              },
              child: const Icon(Icons.add))
          : null,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 199, 177, 100),
        title: const TextWidget(
          text: 'Announcements',
          fontSize: 18,
          color: Colors.white,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Announcements')
            .orderBy('dateTime', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          final currentTime = Timestamp.now();

          final announcements = data.docs.where((doc) {
            final dataMap = doc.data() as Map<String, dynamic>;

            if (dataMap.containsKey('expirationDate')) {
              final expirationDate = dataMap['expirationDate'] as Timestamp;

              // Filter out announcements that have not yet expired
              return expirationDate.toDate().isAfter(currentTime.toDate());
            } else {
              // Handle the case where the field does not exist (optional)
              // You can decide whether to include or exclude announcements without an expiration date
              // In this example, we include them, but you can modify this behavior as needed.
              return true;
            }
          }).toList();

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4.0,
                margin: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    if (box.read('role') == 'Admin') {
                      setState(() {
                        nameController.text = announcement['name'];
                        descController.text = announcement['description'];
                      });
                      addAnnouncementDialog(
                        context,
                        true,
                        announcement.id,
                        announcement['imageUrl'],
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(announcement['imageUrl']),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: announcement['name'],
                              fontSize: 20,
                              fontFamily: 'Nexa',
                            ),
                            const SizedBox(height: 5),
                            TextWidget(
                              text: DateFormat.yMMMd()
                                  .add_jm()
                                  .format(announcement['dateTime'].toDate()),
                              fontSize: 12,
                              color: Colors.black,
                              fontFamily: 'Bold',
                            ),
                            const SizedBox(height: 10),
                            TextWidget(
                              text: announcement['description'],
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              maxLines: 3,
                            ),
                            Visibility(
                              visible: box.read('role') == 'Admin',
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  editAnnouncementImage(
                                      context, announcement.id);
                                },
                              ),
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
                                      expirationDate =
                                          Timestamp.fromDate(selectedDate);
                                    });
                                  }
                                },
                                child: const Text('Set Expiration Date'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  final nameController = TextEditingController();
  final descController = TextEditingController();

  addAnnouncementDialog(context, bool inEdit, String id, String image) {
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
            text: 'Posting Announcement',
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
                  label: 'Name of Announcement',
                  controller: nameController,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldWidget(
                  label: 'Description of Announcement',
                  controller: descController,
                  maxLine: 3, // Adjust the number of visible lines
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
                        .collection('Announcements')
                        .doc(id)
                        .update({
                      'name': nameController.text,
                      'description': descController.text,
                    });
                  } else {
                    addAnnouncement(
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
                        ? 'Announcement successfully updated!'
                        : 'Announcement posted successfully!',
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

Future<void> editAnnouncementImage(
    BuildContext context, String announcementId) async {
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
      FirebaseFirestore.instance
          .collection('Announcements')
          .doc(announcementId)
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
