import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sk_app/widgets/text_widget.dart';

class ActivitiesEvaluated extends StatefulWidget {
  const ActivitiesEvaluated({super.key});

  @override
  State<ActivitiesEvaluated> createState() => _ActivitiesEvaluatedState();
}

class _ActivitiesEvaluatedState extends State<ActivitiesEvaluated> {
  List evaluationList = [];

  getEvaluation() async {
    try {
      var res = await FirebaseFirestore.instance
          .collection('Evaluation')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      var helpdesk = res.docs;
      List data = [];
      for (var i = 0; i < helpdesk.length; i++) {
        Map mapData = helpdesk[i].data();
        mapData['id'] = helpdesk[i].id;
        mapData['datetime'] = mapData['datetime'].toDate().toString();
        data.add(mapData);
      }
      setState(() {
        evaluationList = data;
      });
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  width({required double value}) {
    return MediaQuery.of(context).size.width * (value / 100);
  }

  height({required double value}) {
    return MediaQuery.of(context).size.height * (value / 100);
  }

  @override
  void initState() {
    getEvaluation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          getEvaluation();
        },
        child: SizedBox(
          child: ListView.builder(
            itemCount: evaluationList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
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
                          Expanded(
                            child: TextWidget(
                              text: evaluationList[index]['activityName'],
                              fontSize: 16,
                              isBold: true,
                            ),
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
                            text: "${DateFormat.yMMMd().format(DateTime.parse(
                              evaluationList[index]['datetime'],
                            ))} ${DateFormat.jm().format(DateTime.parse(
                              evaluationList[index]['datetime'],
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
                            text: 'Rating:  ',
                            fontSize: 14,
                          ),
                          TextWidget(
                            text: evaluationList[index]['average']
                                .toStringAsFixed(2),
                            fontSize: 16,
                            isBold: true,
                          ),
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                          )
                        ],
                      ),
                    ],
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
