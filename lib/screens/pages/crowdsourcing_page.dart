import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
// import 'package:sk_app/screens/pages/fullscreenimage.dart';
import '../../services/add_crowdsourcing.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/textfield_widget.dart';
import 'dart:io';
import '../../widgets/toast_widget.dart';

class CroudsourcingPage extends StatefulWidget {
  const CroudsourcingPage({super.key});

  @override
  State<CroudsourcingPage> createState() => _CroudsourcingPageState();
}

class _CroudsourcingPageState extends State<CroudsourcingPage> {
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

  List<PollOption> pollOptions = [
    PollOption(text: 'Option 1', votes1: []),
    PollOption(text: 'Option 2', votes1: []),
  ];

  StreamController<int> likeCountController = StreamController<int>.broadcast();

  void _voteForOption(
      int documentIndex, int optionIndex, DocumentSnapshot? document) async {
    if (document == null) {
      // Handle the case where the document is null, possibly show an error message.
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      List<Map<String, dynamic>> updatedOptions =
          List<Map<String, dynamic>>.from(document['options']);

      if (document['options'][optionIndex]['votes1'].contains(userId)) {
        // User has already voted for this option; let them change their vote.
        updatedOptions[optionIndex]['votes1'].remove(userId);

        await FirebaseFirestore.instance
            .collection('Crowdsourcing')
            .doc(document.id)
            .update({
          'options': updatedOptions,
        });
      } else {
        // User is voting for the first time; update as before.

        updatedOptions[optionIndex]['votes1'].add(userId);

        await FirebaseFirestore.instance
            .collection('Crowdsourcing')
            .doc(document.id)
            .update({
          'options': updatedOptions,
        });
      }

      // Update the state to trigger a rebuild of the widget
      likeCountController.add(document['likes'].length);
    }
  }

  void _toggleLike(int documentIndex, DocumentSnapshot? document) async {
    if (document == null) {
      // Handle the case where the document is null, possibly show an error message.
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      List<String> updatedLikes = List<String>.from(document['likes']);

      if (document['likes'].contains(userId)) {
        // User has already liked this entry; let them unlike it.
        addUserActivity(
            activity: "Undo like in the crowd source ${document['name']}");
        updatedLikes.remove(userId);
      } else {
        addUserActivity(activity: "Liked the crowd source ${document['name']}");
        // User is liking this entry for the first time.
        updatedLikes.add(userId);
      }

      await FirebaseFirestore.instance
          .collection('Crowdsourcing')
          .doc(document.id)
          .update({
        'likes': updatedLikes,
      });

      // Update the state to trigger a rebuild of the widget
      likeCountController.add(updatedLikes.length);
    }
  }

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final daysValidController = TextEditingController();

  List<Map<String, dynamic>> options = [];

  final box = GetStorage();

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
        addCrowdsourcingDialog(context);
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

  void showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(180, 146, 129, 1),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(241, 241, 182, 152),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(241, 241, 182, 152),
        child: const Icon(Icons.add),
        onPressed: () {
          addCrowdsourcingDialog(context);
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Crowdsourcing')
            .where('isApprove', isEqualTo: true)
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
          final DateTime currentDate = DateTime.now();
          final List<Widget> notExpiredCrowdsourcingWidgets = [];

          for (int index = 0; index < data.docs.length; index++) {
            Map<String, dynamic> documentData =
                data.docs[index].data() as Map<String, dynamic>;

            if (documentData.containsKey('expirationDate')) {
              DateTime expirationDate = documentData['expirationDate'].toDate();
              if (currentDate.isBefore(expirationDate)) {
                notExpiredCrowdsourcingWidgets.add(
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(3.8),
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            showImageDialog(data.docs[index]['imageUrl']);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 250,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                              image: DecorationImage(
                                image: NetworkImage(
                                  data.docs[index]['imageUrl'],
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.docs[index]['name'],
                                    style: const TextStyle(fontSize: 18.0),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Posted on: ${DateFormat('yyyy-MM-dd HH:mm').format(data.docs[index]['dateTime'].toDate())}',
                                    style: const TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _toggleLike(index, data.docs[index]);
                                    },
                                    icon: Icon(
                                      data.docs[index]['likes'].contains(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                  ),
                                  if (data.docs[index]['likes'].length > 0)
                                    StreamBuilder<int>(
                                      stream: likeCountController.stream,
                                      initialData:
                                          data.docs[index]['likes'].length,
                                      builder: (context, snapshot) {
                                        return Text(
                                          '${data.docs[index]['likes'].length}',
                                        );
                                      },
                                    ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: StatefulBuilder(
                                                builder: (context, setState) {
                                                  return SizedBox(
                                                    height: 500,
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: ListView
                                                              .separated(
                                                            separatorBuilder:
                                                                (context,
                                                                    index) {
                                                              return const Divider();
                                                            },
                                                            itemCount: data
                                                                .docs[index]
                                                                    ['comments']
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index1) {
                                                              return ListTile(
                                                                leading:
                                                                    CircleAvatar(
                                                                  minRadius: 20,
                                                                  maxRadius: 20,
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                          userData[
                                                                              'profile']),
                                                                ),
                                                                title:
                                                                    TextWidget(
                                                                  text: data.docs[
                                                                              index]
                                                                          [
                                                                          'comments']
                                                                      [
                                                                      index1]['name'],
                                                                  fontSize: 14,
                                                                ),
                                                                subtitle:
                                                                    TextWidget(
                                                                  text: data.docs[index]
                                                                              [
                                                                              'comments']
                                                                          [
                                                                          index1]
                                                                      [
                                                                      'comment'],
                                                                  fontSize: 12,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: TextFormField(
                                                            controller:
                                                                commentController,
                                                            decoration:
                                                                InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors
                                                                  .grey[300],
                                                              suffixIcon:
                                                                  StreamBuilder<
                                                                      DocumentSnapshot>(
                                                                stream: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Users')
                                                                    .doc(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .snapshots(),
                                                                builder: (context,
                                                                    AsyncSnapshot<
                                                                            DocumentSnapshot>
                                                                        snapshot) {
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return const SizedBox();
                                                                  } else if (snapshot
                                                                      .hasError) {
                                                                    return const Center(
                                                                        child: Text(
                                                                            'Something went wrong'));
                                                                  } else if (snapshot
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting) {
                                                                    return const SizedBox();
                                                                  }
                                                                  dynamic
                                                                      data1 =
                                                                      snapshot
                                                                          .data;
                                                                  return IconButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Crowdsourcing')
                                                                          .doc(data
                                                                              .docs[index]
                                                                              .id)
                                                                          .update({
                                                                        'comments':
                                                                            FieldValue.arrayUnion([
                                                                          {
                                                                            'name':
                                                                                data1['fname'],
                                                                            'comment':
                                                                                commentController.text,
                                                                            'dateTime':
                                                                                DateTime.now()
                                                                          }
                                                                        ])
                                                                      });

                                                                      Navigator.pop(
                                                                          context);

                                                                      commentController
                                                                          .clear();
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .send,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.comment,
                                    ),
                                  ),
                                  box.read('role') == 'Admin'
                                      ? IconButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('Crowdsourcing')
                                                .doc(data.docs[index].id)
                                                .delete();
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              Text(
                                data.docs[index]['description'],
                                style: const TextStyle(fontSize: 12.0),
                              ),
                              const SizedBox(height: 20.0),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.docs[index]['options'].length,
                                itemBuilder: (context, index1) {
                                  return PollOptionCard(
                                    changeVotePressed: () async {
                                      addUserActivity(
                                          activity:
                                              "Voted in the crowd source ${data.docs[index]['name']}");
                                      _voteForOption(
                                          index, index1, data.docs[index]);
                                      await FirebaseFirestore.instance
                                          .collection('Crowdsourcing')
                                          .doc(data.docs[index].id)
                                          .update({
                                        data.docs[index]['options'][index1]
                                            ['votes1']: [
                                          ...data.docs[index]['options'][index1]
                                              ['votes1'],
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                        ],
                                      });
                                    },
                                    hasVotedForThisOption: data.docs[index]
                                            ['options'][index1]['votes1']
                                        .contains(FirebaseAuth
                                            .instance.currentUser!.uid),
                                    pollOption: PollOption(
                                      text: data.docs[index]['options'][index1]
                                          ['text'],
                                      votes1: [],
                                    ),
                                    onPressed: () async {
                                      bool isExist = false;
                                      for (var i = 0;
                                          i <
                                              data.docs[index]['options']
                                                  .length;
                                          i++) {
                                        for (var x = 0;
                                            x <
                                                data
                                                    .docs[index]['options'][i]
                                                        ['votes1']
                                                    .length;
                                            x++) {
                                          if (data.docs[index]['options'][i]
                                                  ['votes1'][x] ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid) {
                                            isExist = true;
                                          }
                                        }
                                      }

                                      if (isExist == false) {
                                        addUserActivity(
                                            activity:
                                                "Voted in the crowd source ${data.docs[index]['name']}");
                                        _voteForOption(
                                            index, index1, data.docs[index]);
                                        await FirebaseFirestore.instance
                                            .collection('Crowdsourcing')
                                            .doc(data.docs[index].id)
                                            .update({
                                          data.docs[index]['options'][index1]
                                              ['votes1']: [
                                            ...data.docs[index]['options']
                                                [index1]['votes1'],
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                          ],
                                        });
                                      } else {
                                        showToast(
                                            "Please remove your existing vote. Thank you");
                                      }
                                    },
                                  );
                                },
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
          }

          if (notExpiredCrowdsourcingWidgets.isNotEmpty) {
            return ListView.separated(
              itemCount: notExpiredCrowdsourcingWidgets.length,
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemBuilder: (context, index) {
                return notExpiredCrowdsourcingWidgets[index];
              },
            );
          } else {
            // If there are no not expired crowdsourcing items, show the message
            return const Center(
              child: Text(
                'No crowdsourcing available.',
                style: TextStyle(fontSize: 16.0),
              ),
            );
          }
        },
      ),
    );
  }

  addCrowdsourcingDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        // Define a list to hold answer controllers
        List<TextEditingController> answerControllers = [];

        // Function to add a new answer field

        return AlertDialog(
          content: StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
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
                  TextFieldWidget(label: 'Name', controller: nameController),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFieldWidget(
                      label: 'Description', controller: descController),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFieldWidget(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      inputType: TextInputType.number,
                      label: 'No. days valid',
                      controller: daysValidController),
                  const SizedBox(
                    height: 20,
                  ),
                  // Display answer input fields
                  if (answerControllers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Option:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        for (int i = 0; i < answerControllers.length; i++)
                          TextFieldWidget(
                              label: 'Option ${i + 1}',
                              controller: answerControllers[i]),
                      ],
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Button to add new answer field
                  TextButton(
                    onPressed: () {
                      if (answerControllers.length == 5) {
                        showToast("Maximum option reached.");
                        // ScaffoldMessenger.of(context)
                        //     .showSnackBar(const SnackBar(
                        //   content: Text('Maximum option reached!'),
                        // ));
                      } else {
                        setState(() {
                          answerControllers.add(TextEditingController());
                        });
                      }
                    },
                    child: const TextWidget(
                      text: 'Add Answer',
                      fontSize: 14,
                    ),
                  ),
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
                List<String> answers = answerControllers
                    .map((controller) => controller.text)
                    .toList();

                if (idFileName == '') {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    toastLength: Toast.LENGTH_LONG,
                    msg: "Please add image",
                  );
                } else if (nameController.text.isEmpty) {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    toastLength: Toast.LENGTH_LONG,
                    msg: "Missing name input",
                  );
                } else if (descController.text.isEmpty) {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    toastLength: Toast.LENGTH_LONG,
                    msg: "Missing description input",
                  );
                } else if (answers.length < 2) {
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    toastLength: Toast.LENGTH_LONG,
                    msg: "Please add at least 2 options",
                  );
                } else {
                  bool isThereTextEmoty = false;
                  for (var i = 0; i < answers.length; i++) {
                    if (answers[i].isEmpty) {
                      isThereTextEmoty = true;
                    }
                  }
                  if (isThereTextEmoty == true) {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      toastLength: Toast.LENGTH_LONG,
                      msg: "Please fill all the options",
                    );
                  } else {
                    addUserActivity(activity: "Created a crowd sourcing entry");
                    addCrowdsourcing(
                        idImageURL,
                        nameController.text,
                        descController.text,
                        answers,
                        context,
                        daysValidController.text);
                    Navigator.pop(context);

                    // Display the "Your crowdsource idea is being reviewed" pop-up
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Your crowdsource idea is being reviewed',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                    context); // Close the review pop-up
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: const TextWidget(
                text: 'Add',
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}

class PollOption {
  final String text;
  List<String> votes1; // Store userIDs who have voted for this option

  PollOption({required this.text, required this.votes1});
}

class PollOptionCard extends StatelessWidget {
  final PollOption pollOption;
  final VoidCallback onPressed;
  final VoidCallback changeVotePressed;
  final bool? hasVotedForThisOption;

  const PollOptionCard({
    super.key,
    required this.pollOption,
    required this.onPressed,
    required this.changeVotePressed,
    required this.hasVotedForThisOption,
  });

  @override
  Widget build(BuildContext context) {
    final numberOfVotes =
        hasVotedForThisOption != null && hasVotedForThisOption!
            ? pollOption.votes1.length + 1
            : pollOption.votes1.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: ListTile(
        title: Text(pollOption.text),
        subtitle: Text('Votes: $numberOfVotes'), // Display the vote count
        trailing: hasVotedForThisOption != null && hasVotedForThisOption!
            ? ElevatedButton(
                onPressed: changeVotePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(180, 146, 129, 1),
                ),
                child: const Text('Remove Vote'),
              )
            : ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(220, 179, 158, 1)),
                child: const Text('Vote'),
              ),
      ),
    );
  }
}
