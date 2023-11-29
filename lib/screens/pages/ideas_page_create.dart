import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:sk_app/widgets/toast_widget.dart';

import '../../widgets/textfield_widget.dart';

class CreateIdeasPages extends StatefulWidget {
  const CreateIdeasPages(
      {super.key,
      required this.id,
      required this.name,
      // required this.expirationDate,
      required this.description});
  final String id;
  final String name;
  final String description;
  // final String expirationDate;

  @override
  State<CreateIdeasPages> createState() => _CreateIdeasPagesState();
}

class _CreateIdeasPagesState extends State<CreateIdeasPages> {
  TextEditingController ideaController = TextEditingController();
  TextEditingController ideaTitleController = TextEditingController();

  String username = '';
  String useremail = '';
  String userimage = '';
  int numberOfTries = 3;

  List<String> types = [];
  bool isLoading = true;
  String dropdownValue = '';

  getTopics() async {
    isLoading = true;
    var res = await FirebaseFirestore.instance
        .collection('Topics')
        .doc(widget.id)
        .get();

    if (res.exists) {
      Map? topics = res.data();
      for (var i = 0; i < topics!['types'].length; i++) {
        types.add(topics['types'][i]);
      }
      types.insert(0, "");
    }
    var resnew = await FirebaseFirestore.instance
        .collection('Topics')
        .doc(widget.id)
        .collection('ideas')
        .where('userid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    numberOfTries = numberOfTries - (resnew.docs.length);
    setState(() {
      isLoading = false;
    });
  }

  getUserDetails() async {
    var res = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (res.exists) {
      Map? userDetails = res.data();
      setState(() {
        username = userDetails!['fname'] + " " + userDetails['lname'];
        useremail = userDetails['email'];
        userimage = userDetails['profile'];
      });
    }
  }

  @override
  void initState() {
    getUserDetails();
    getTopics();
    super.initState();
  }

  submitIdea() async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('Topics')
          .doc(widget.id)
          .collection('ideas')
          .add({
        "idea": ideaController.text,
        "score": 0,
        "ideaType": dropdownValue,
        "submittedBy": username,
        "userimage": userimage,
        "ideaTitle": ideaTitleController.text,
        "useremail": useremail,
        "userid": FirebaseAuth.instance.currentUser!.uid
      });
      if (!context.mounted) return;
      Navigator.pop(context);
      showToast("Idea submitted");
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80.0,
        backgroundColor: Colors.black,
        title: const Text('Campaign'),
        centerTitle: true, // Set the title as needed
        // Add any other app bar configuration you need
      ),
      body: isLoading == true
          ? SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TextWidget(
                          text: widget.name,
                          fontSize: 25,
                          isBold: true,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TextWidget(
                          text: widget.description,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: const TextWidget(
                          text: "Title",
                          fontSize: 12,
                          isBold: true,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadiusDirectional.circular(6)),
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: TextField(
                          controller: ideaTitleController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.03,
                              ),
                              border: InputBorder.none,
                              hintText: "Give us a title for your idea"),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: const TextWidget(
                          text: "Type",
                          fontSize: 12,
                          isBold: true,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadiusDirectional.circular(6)),
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.only(right: 11, left: 11),
                          isExpanded: true,
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          underline: const SizedBox(),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              dropdownValue = value!;
                            });
                          },
                          items: types
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: const TextWidget(
                          text: "Your idea",
                          fontSize: 12,
                          isBold: true,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadiusDirectional.circular(6)),
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: TextField(
                          maxLines: 8,
                          controller: ideaController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.03,
                                top: MediaQuery.of(context).size.height * 0.015,
                              ),
                              border: InputBorder.none,
                              hintText: "Say something about your idea..."),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          "  Attemps: $numberOfTries",
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.normal),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.black)),
                            onPressed: () {
                              if (dropdownValue != "" &&
                                  ideaController.text.isNotEmpty &&
                                  numberOfTries > 0) {
                                submitIdea();
                              }
                            },
                            child: const Text("Submit")),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )),
            ),
    );
  }
}
