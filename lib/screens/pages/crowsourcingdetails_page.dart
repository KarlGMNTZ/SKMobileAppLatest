import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/crowdsource_model.dart';
import '../../widgets/text_widget.dart';

class CrowSourcingDetailsPage extends StatefulWidget {
  const CrowSourcingDetailsPage({super.key});

  @override
  State<CrowSourcingDetailsPage> createState() =>
      _CrowSourcingDetailsPageState();
}

class _CrowSourcingDetailsPageState extends State<CrowSourcingDetailsPage> {
  Stream? streamChats;
  StreamSubscription<dynamic>? listener;
  List<CrowdSource> crowsourceList = <CrowdSource>[];

  bool isLoading = true;

  listenToChanges() async {
    streamChats = FirebaseFirestore.instance
        .collection("Crowdsourcing")
        .where("isApprove", isEqualTo: true)
        .orderBy('dateTime', descending: true)
        .snapshots();
    getCrowSource();
  }

  getCrowSource() async {
    try {
      listener = streamChats!.listen((event) async {
        List data = [];
        for (var crowdsource in event.docs) {
          Map mapData = crowdsource.data();
          mapData['dateTime'] = mapData['dateTime'].toDate().toString();
          for (var i = 0; i < mapData['comments'].length; i++) {
            mapData['comments'][i]['dateTime'] =
                mapData['comments'][i]['dateTime'].toDate().toString();
          }
          if (mapData.containsKey('expirationDate')) {
            mapData.remove('expirationDate');
          }

          var resUser = await FirebaseFirestore.instance
              .collection('Users')
              .where('id', isEqualTo: mapData['userId'])
              .get();
          if (resUser.docs.isNotEmpty) {
            var resUserDetails = await FirebaseFirestore.instance
                .collection('Users')
                .doc(resUser.docs[0].id)
                .get();
            var userDetails = resUserDetails.data();
            userDetails!['birthdate'] =
                userDetails['birthdate'].toDate().toString();
            mapData['userDetails'] = userDetails;
          }

          data.add(mapData);
        }
        var encodedData = jsonEncode(data);
        if (mounted) {
          setState(() {
            crowsourceList = crowdSourceFromJson(encodedData);
            isLoading = false;
          });
        }
        // chatList.assignAll(chatsFromJson(encodedData));
      });
    } catch (_) {}
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
    listenToChanges();
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
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const TextWidget(
                                text: 'Suggested by: ',
                                fontSize: 14,
                              ),
                              TextWidget(
                                text:
                                    "${crowsourceList[index].userDetails?.fname} ${crowsourceList[index].userDetails?.lname}",
                                fontSize: 14,
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
                          const TextWidget(
                            text: 'Current Result ',
                            isBold: true,
                            fontSize: 16,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: crowsourceList[index].options.length,
                            itemBuilder:
                                (BuildContext context, int optionIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Row(
                                  children: [
                                    TextWidget(
                                      text: crowsourceList[index]
                                          .options[optionIndex]
                                          .text,
                                      fontSize: 14,
                                    ),
                                    const TextWidget(
                                      isBold: true,
                                      text: "  -  ",
                                      fontSize: 14,
                                    ),
                                    TextWidget(
                                      text: crowsourceList[index]
                                          .options[optionIndex]
                                          .votes1
                                          .length
                                          .toString(),
                                      fontSize: 14,
                                    ),
                                  ],
                                ),
                              );
                            },
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
