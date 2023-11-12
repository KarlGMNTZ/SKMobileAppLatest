import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sk_app/screens/pages/evaluation_page.dart';

class EvaluateActivities extends StatefulWidget {
  const EvaluateActivities({super.key});

  @override
  State<EvaluateActivities> createState() => _EvaluateActivitiesState();
}

class _EvaluateActivitiesState extends State<EvaluateActivities> {
  List activitiesList = [];

  bool isLoading = true;

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

  getActivities() async {
    isLoading = true;
    try {
      var res = await FirebaseFirestore.instance
          .collection('Activities')
          .where('expirationDate', isLessThan: Timestamp.now())
          .get();
      var activities = res.docs;
      List tempData = [];
      for (var i = 0; i < activities.length; i++) {
        Map mapdata = activities[i].data();
        mapdata['id'] = activities[i].id;
        mapdata['dateTime'] = mapdata['dateTime'].toDate().toString();
        mapdata['expirationDate'] =
            mapdata['expirationDate'].toDate().toString();
        tempData.add(mapdata);
      }
      setState(() {
        activitiesList = tempData;
      });
    } on Exception catch (_) {}
    isLoading = false;
  }

  @override
  void initState() {
    getActivities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(238, 241, 210, 194),
        centerTitle: true,
        title: const Text("Activities Evaluation"),
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
              height: height(value: 100),
              width: width(value: 100),
              child: activitiesList.isEmpty
                  ? Center(
                      child: Text(
                        "No available data.",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: fontSize(value: 4),
                            fontFamily: 'Regular'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: activitiesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: width(value: 5),
                              right: width(value: 5),
                              top: height(value: 2)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EvaluationPage(
                                        activityName: activitiesList[index]
                                            ['name'],
                                        activityID: activitiesList[index]
                                            ['id'])),
                              );
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: height(value: 15),
                                      width: width(value: 30),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  activitiesList[index]
                                                      ['imageUrl']))),
                                    ),
                                    SizedBox(
                                      width: width(value: 2),
                                    ),
                                    Expanded(
                                        child: SizedBox(
                                      height: height(value: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activitiesList[index]['name'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: fontSize(value: 5),
                                                fontFamily: 'Regular'),
                                          ),
                                          SizedBox(
                                            height: height(value: .01),
                                          ),
                                          Text(
                                            activitiesList[index]
                                                ['description'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: fontSize(value: 3),
                                                fontFamily: 'Regular'),
                                          ),
                                          SizedBox(
                                            height: height(value: .01),
                                          ),
                                          Text(
                                            "${DateFormat.yMMMd().format(DateTime.parse(activitiesList[index]['dateTime']))} ${DateFormat.jm().format(DateTime.parse(activitiesList[index]['dateTime']))}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: fontSize(value: 3),
                                                fontFamily: 'Regular'),
                                          ),
                                        ],
                                      ),
                                    ))
                                  ],
                                ),
                                SizedBox(
                                  height: height(value: 2),
                                ),
                                const Divider()
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
