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
  bool isLoading = true;
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
        isLoading = false;
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

  showEvaluationAnswers({required List evaluationOutput}) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextWidget(
          text: 'Evaluation Result',
          fontSize: 18,
          fontFamily: 'Bold',
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: evaluationOutput.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['question'],
                        style: const TextStyle(
                            fontSize: 11, fontFamily: "Regular"),
                      ),
                      Row(
                        children: [
                          const TextWidget(
                            text: "Answer ",
                            fontSize: 11,
                            isBold: true,
                          ),
                          TextWidget(
                            text: item['answer'],
                            fontSize: 11,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const TextWidget(
              text: 'OK',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
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
        child: isLoading
            ? const SizedBox(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 247, 218, 202),
                  ),
                ),
              )
            : evaluationList.isEmpty
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
                      itemCount: evaluationList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: InkWell(
                            onTap: () {
                              showEvaluationAnswers(
                                  evaluationOutput: evaluationList[index]
                                      ['evaluationOutput']);
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
                                          text: evaluationList[index]
                                              ['activityName'],
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
                                        text:
                                            "${DateFormat.yMMMd().format(DateTime.parse(
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
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
