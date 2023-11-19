import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sk_app/widgets/text_widget.dart';

class HelpDeskSubmitted extends StatefulWidget {
  const HelpDeskSubmitted({Key? key}) : super(key: key);

  @override
  State<HelpDeskSubmitted> createState() => _HelpDeskSubmittedState();
}

class _HelpDeskSubmittedState extends State<HelpDeskSubmitted> {
  List helpdeskList = [];
  bool isLoading = true;

  getHelpDeskSubmitted() async {
    try {
      var res = await FirebaseFirestore.instance
          .collection('Helpdesk')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      var helpdesk = res.docs;
      List data = [];
      for (var i = 0; i < helpdesk.length; i++) {
        Map mapData = helpdesk[i].data();
        mapData['id'] = helpdesk[i].id;
        mapData['dateTime'] = mapData['dateTime'].toDate().toString();
        if (!mapData.containsKey('remarks')) {
          mapData['remarks'] = '';
        }
        data.add(mapData);
      }
      setState(() {
        helpdeskList = data;
        isLoading = false;
      });
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  void _showRemarksDialog(BuildContext context, String remarks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Admin Remarks'),
          content: Text(remarks),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    getHelpDeskSubmitted();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          getHelpDeskSubmitted();
        },
        child: isLoading
            ? const SizedBox(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 247, 218, 202),
                  ),
                ),
              )
            : helpdeskList.isEmpty
                ? const SizedBox(
                    child: Center(
                      child: TextWidget(
                        text: "No available data",
                        fontSize: 15,
                      ),
                    ),
                  )
                : SizedBox(
                    child: ListView.builder(
                      itemCount: helpdeskList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: GestureDetector(
                            onTap: () {
                              if (helpdeskList[index]['action']) {
                                _showRemarksDialog(
                                  context,
                                  helpdeskList[index]['remarks'],
                                );
                              }
                            },
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
                                    offset: Offset(1, 2),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const TextWidget(
                                        text: 'Title: ',
                                        isBold: true,
                                        fontSize: 16,
                                      ),
                                      Expanded(
                                        child: TextWidget(
                                          text: helpdeskList[index]['title'],
                                          fontSize: 16,
                                          isBold: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const TextWidget(
                                        text: 'Description: ',
                                        isBold: true,
                                        fontSize: 16,
                                      ),
                                      Expanded(
                                        child: TextWidget(
                                          text: helpdeskList[index]
                                              ['description'],
                                          fontSize: 16,
                                          isBold: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  helpdeskList[index]['action'] == false
                                      ? const SizedBox()
                                      : Row(
                                          children: [
                                            const TextWidget(
                                              text: 'Date Created: ',
                                              fontSize: 14,
                                            ),
                                            TextWidget(
                                              text:
                                                  "${DateFormat.yMMMd().format(DateTime.parse(
                                                helpdeskList[index]['dateTime'],
                                              ))} ${DateFormat.jm().format(DateTime.parse(
                                                helpdeskList[index]['dateTime'],
                                              ))}",
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
                                        text: helpdeskList[index]['action']
                                            ? "Settled"
                                            : "Unsettled",
                                        fontSize: 14,
                                        color: helpdeskList[index]['action']
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
