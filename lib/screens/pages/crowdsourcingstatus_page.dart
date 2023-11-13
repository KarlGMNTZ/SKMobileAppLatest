import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/crowdsource_model.dart';
import '../../widgets/text_widget.dart';

class CrowSourcingStatusPage extends StatefulWidget {
  const CrowSourcingStatusPage({super.key});

  @override
  State<CrowSourcingStatusPage> createState() => _CrowSourcingStatusPageState();
}

class _CrowSourcingStatusPageState extends State<CrowSourcingStatusPage> {
  Stream? streamChats;
  StreamSubscription<dynamic>? listener;
  List<CrowdSource> crowsourceList = <CrowdSource>[];
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
        .collection("Crowdsourcing")
        .where('userId', isEqualTo: userid)
        .orderBy('dateTime', descending: true)
        .snapshots();
    getCrowSource();
  }

  getCrowSource() async {
    try {
      listener = streamChats!.listen((event) async {
        print('Received data from Firebase: $event');
        List data = [];
        for (var crowdsource in event.docs) {
          Map mapData = crowdsource.data();
          mapData['dateTime'] = mapData['dateTime']?.toDate()?.toString();

          for (var i = 0; i < mapData['comments'].length; i++) {
            mapData['comments'][i]['dateTime'] =
                mapData['comments'][i]['dateTime'].toDate().toString();
          }
          if (mapData.containsKey('expirationDate')) {
            mapData.remove('expirationDate');
          }
          data.add(mapData);
        }
        var encodedData = jsonEncode(data);
        setState(() {
          crowsourceList = crowdSourceFromJson(encodedData);
          isLoading = false;
        });
        // chatList.assignAll(chatsFromJson(encodedData));
      });
    } catch (_) {
      log(_.toString());
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
              child: ListView.builder(
                itemCount: crowsourceList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 15),
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
                                text: 'Name: ',
                                isBold: true,
                                fontSize: 16,
                              ),
                              TextWidget(
                                text: crowsourceList[index].name,
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
                                    "${DateFormat.yMMMd().format(crowsourceList[index].dateTime)} ${DateFormat.jm().format(crowsourceList[index].dateTime)}",
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
                                text: crowsourceList[index].isApprove == true
                                    ? "Approved"
                                    : "Pending",
                                fontSize: 14,
                                color: crowsourceList[index].isApprove == true
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
