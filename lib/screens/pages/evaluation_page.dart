import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sk_app/widgets/toast_widget.dart';

class EvaluationPage extends StatefulWidget {
  const EvaluationPage(
      {super.key, required this.activityID, required this.activityName});
  final String activityID;
  final String activityName;
  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  bool isLoading = false;
  fontSize({required double value}) {
    final double maxScreenSize = MediaQuery.of(context).size.shortestSide;
    return maxScreenSize * (value / 100);
  }

  width({required double value}) {
    return MediaQuery.of(context).size.width * (value / 100);
  }

  height({required double value}) {
    return MediaQuery.of(context).size.height * (value / 100);
  }

  List evaluationQuestions = [
    {"question": "1. The activity is well-orgarnized?", "answer": 1},
    {"question": "2. The objectives of the activity is relevant", "answer": 1},
    {"question": "3. The activity is conductive?", "answer": 1},
    {"question": "4. The activity is well prepared?", "answer": 1},
    {"question": "5. The activity is well timed?", "answer": 1},
    {"question": "6. The materials was well distributed", "answer": 1},
    {"question": "7. The conductor was well prepared?", "answer": 1},
    {"question": "8. The facilitator is informative?", "answer": 1},
    {
      "question":
          "9. The facilitator presented the objectives in a coherent manner?",
      "answer": 1
    },
    {"question": "10. Are you satisfied with the activity?", "answer": 1},
    {
      "question":
          "11. How likely would you join in these activities in the future?",
      "answer": 1
    },
  ];

  submit() async {
    isLoading = true;
    try {
      int totalNumber = 0;
      for (var i = 0; i < evaluationQuestions.length; i++) {
        totalNumber = totalNumber +
            int.parse(evaluationQuestions[i]['answer'].toString());
      }

      double average = totalNumber / evaluationQuestions.length;

      var res = await FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();
      if (res.docs.isNotEmpty) {
        var userDetails = res.docs[0].data();
        var userDocumentRef =
            FirebaseFirestore.instance.collection('Users').doc(res.docs[0].id);
        await FirebaseFirestore.instance.collection('Evaluation').add({
          "activityName": widget.activityName,
          "activityID": widget.activityID,
          "evaluationOutput": evaluationQuestions,
          "datetime": Timestamp.now(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'userFullName': userDetails['fname'] + " " + userDetails['lname'],
          "userProfile": userDetails['profile'],
          'userDocumentRef': userDocumentRef,
          'average': average
        });
      }
      if (!context.mounted) return;
      Navigator.pop(context);
      showToast("Thank you for your feedback");
    } on Exception catch (_) {}
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(238, 241, 210, 194),
        centerTitle: true,
        title: const Text("Evaluation Page"),
      ),
      body: isLoading == true
          ? SizedBox(
              height: height(value: 100),
              width: width(value: 100),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(238, 241, 210, 194),
                ),
              ),
            )
          : SizedBox(
              child: Padding(
                padding: EdgeInsets.only(
                    left: width(value: 5), right: width(value: 5)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height(value: 3),
                      ),
                      Text(
                        "Evaluation Form",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize(value: 5.5),
                            fontFamily: "Regular"),
                      ),
                      Text(
                        "For ${widget.activityName}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize(value: 5.5),
                            fontFamily: "Regular"),
                      ),
                      SizedBox(
                        height: height(value: 3),
                      ),
                      Text(
                        "1 - Strongly Disagree",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: fontSize(value: 4),
                            fontFamily: "Regular"),
                      ),
                      Text(
                        "2 - Disagree",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: fontSize(value: 4),
                            fontFamily: "Regular"),
                      ),
                      Text(
                        "3 - Neutral",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: fontSize(value: 4),
                            fontFamily: "Regular"),
                      ),
                      Text(
                        "4 - Agree",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: fontSize(value: 4),
                            fontFamily: "Regular"),
                      ),
                      Text(
                        "5 - Strongly Agree",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: fontSize(value: 4),
                            fontFamily: "Regular"),
                      ),
                      SizedBox(
                        height: height(value: 3),
                      ),
                      SizedBox(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: evaluationQuestions.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding:
                                  EdgeInsets.only(bottom: height(value: 1)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    evaluationQuestions[index]['question'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSize(value: 4),
                                        fontFamily: "Regular"),
                                  ),
                                  Row(
                                    children: [
                                      Radio(
                                        value: "1",
                                        groupValue: evaluationQuestions[index]
                                            ['answer'],
                                        onChanged: (value) {
                                          setState(() {
                                            evaluationQuestions[index]
                                                ['answer'] = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        "1",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: fontSize(value: 4),
                                            fontFamily: "Regular"),
                                      ),
                                      SizedBox(
                                        width: width(value: 2),
                                      ),
                                      Radio(
                                        value: "2",
                                        groupValue: evaluationQuestions[index]
                                            ['answer'],
                                        onChanged: (value) {
                                          setState(() {
                                            evaluationQuestions[index]
                                                ['answer'] = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        "2",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: fontSize(value: 4),
                                            fontFamily: "Regular"),
                                      ),
                                      SizedBox(
                                        width: width(value: 2),
                                      ),
                                      Radio(
                                        value: "3",
                                        groupValue: evaluationQuestions[index]
                                            ['answer'],
                                        onChanged: (value) {
                                          setState(() {
                                            evaluationQuestions[index]
                                                ['answer'] = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        "3",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: fontSize(value: 4),
                                            fontFamily: "Regular"),
                                      ),
                                      SizedBox(
                                        width: width(value: 2),
                                      ),
                                      Radio(
                                        value: "4",
                                        groupValue: evaluationQuestions[index]
                                            ['answer'],
                                        onChanged: (value) {
                                          setState(() {
                                            evaluationQuestions[index]
                                                ['answer'] = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        "4",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: fontSize(value: 4),
                                            fontFamily: "Regular"),
                                      ),
                                      SizedBox(
                                        width: width(value: 2),
                                      ),
                                      Radio(
                                        value: "5",
                                        groupValue: evaluationQuestions[index]
                                            ['answer'],
                                        onChanged: (value) {
                                          setState(() {
                                            evaluationQuestions[index]
                                                ['answer'] = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        "5",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: fontSize(value: 4),
                                            fontFamily: "Regular"),
                                      ),
                                      SizedBox(
                                        width: width(value: 2),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: submit,
                          child: Container(
                            height: height(value: 7),
                            width: width(value: 100),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color.fromARGB(238, 241, 210, 194),
                                border: Border.all(color: Colors.white),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: Offset(1, 2))
                                ]),
                            child: Center(
                              child: Text(
                                "SUBMIT",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Regular",
                                    fontSize: fontSize(value: 5),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height(value: 2),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
