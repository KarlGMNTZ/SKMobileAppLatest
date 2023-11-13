import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sk_app/models/helpdesk_model.dart';

import '../../widgets/text_widget.dart';

class HelpdeskStatusPage extends StatefulWidget {
  const HelpdeskStatusPage({Key? key}) : super(key: key);

  @override
  State<HelpdeskStatusPage> createState() => _HelpdeskStatusPageState();
}

class _HelpdeskStatusPageState extends State<HelpdeskStatusPage> {
  Stream<QuerySnapshot>? streamChats;
  StreamSubscription<QuerySnapshot>? listener;
  List<Helpdesk> helpdeskList = <Helpdesk>[];
  bool isLoading = true;

  getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    print(user!.uid);

    var res = await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: user.uid)
        .get();
    if (res.docs.isNotEmpty) {
      String userID = res.docs[0].get('id');
      listenToChanges(userid: userID);
    } else {}
  }

  listenToChanges({required String userid}) async {
    streamChats = FirebaseFirestore.instance
        .collection("Helpdesk")
        .where('userId', isEqualTo: userid)
        .orderBy('dateTime', descending: true)
        .snapshots();
    getHelpdesk();
  }

  getHelpdesk() async {
    try {
      listener = streamChats!.listen((QuerySnapshot event) async {
        print('Received data from Firebase: $event');
        List<Map<String, dynamic>> data = [];

        for (var helpdesk in event.docs) {
          if (helpdesk.exists) {
            Map<String, dynamic>? mapData =
                helpdesk.data() as Map<String, dynamic>?;

            if (mapData != null) {
              mapData['dateTime'] = mapData['dateTime']?.toDate()?.toString();

              // Check if 'comments' field exists before iterating
              if (mapData.containsKey('comments') &&
                  mapData['comments'] != null) {
                for (var i = 0; i < mapData['comments'].length; i++) {
                  mapData['comments'][i]['dateTime'] =
                      mapData['comments'][i]['dateTime']?.toDate()?.toString();
                }
              }

              if (mapData.containsKey('expirationDate')) {
                mapData.remove('expirationDate');
              }

              data.add(mapData);
            }
          }
        }

        var encodedData = jsonEncode(data);
        setState(() {
          helpdeskList = helpdeskFromJson(encodedData);
          isLoading = false;
        });
      });
    } catch (error) {
      log(error.toString());
    }
  }

  @override
  void dispose() {
    if (listener != null) {
      listener!.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const SizedBox(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 247, 218, 202),
                ),
              ),
            )
          : SizedBox(
              child: helpdeskList.isEmpty
                  ? Center(
                      child: Text(
                        'No Helpdesk Interaction yet.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: helpdeskList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5,
                                    spreadRadius: 3,
                                    offset: Offset(1, 2))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const TextWidget(
                                      text: 'Helpdesk Description: ',
                                      isBold: true,
                                      fontSize: 16,
                                    ),
                                    TextWidget(
                                      text: helpdeskList[index].description,
                                      fontSize: 16,
                                      isBold: true,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const TextWidget(
                                      text: 'Date Created: ',
                                      fontSize: 14,
                                    ),
                                    TextWidget(
                                      text:
                                          "${DateFormat.yMMMd().format(helpdeskList[index].dateTime)} ${DateFormat.jm().format(helpdeskList[index].dateTime)}",
                                      fontSize: 14,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const TextWidget(
                                      text: 'Status ',
                                      fontSize: 14,
                                    ),
                                    TextWidget(
                                      text: helpdeskList[index].action == true
                                          ? "Opened"
                                          : "Pending",
                                      fontSize: 14,
                                      color: helpdeskList[index].action == true
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
