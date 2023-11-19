import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/text_widget.dart';

class ActivitiesJoined extends StatefulWidget {
  const ActivitiesJoined({super.key});

  @override
  State<ActivitiesJoined> createState() => _ActivitiesJoinedState();
}

class _ActivitiesJoinedState extends State<ActivitiesJoined> {
  List activitiesJoinedList = [];
  bool isLoading = true;
  getActivitiesJoined() async {
    var user = await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .limit(1)
        .get();
    if (user.docs.isNotEmpty) {
      var res = await FirebaseFirestore.instance
          .collection('Registration')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      var registration = res.docs;
      List data = [];
      for (var i = 0; i < registration.length; i++) {
        Map mapdata = registration[i].data();
        mapdata['id'] = registration[i].id;
        var activityDocumentRef =
            await mapdata['activityDocRef'] as DocumentReference;
        var activitysnapshot = await activityDocumentRef.get();

        if (activitysnapshot.data() != null) {
          Map activities = activitysnapshot.data() as Map;
          activities['id'] = activitysnapshot.id;
          activities['dateTime'] = activities['dateTime'].toDate().toString();
          activities.remove('regId');
          data.add(activities);
        }
      }
      setState(() {
        activitiesJoinedList = data;
        isLoading = false;
      });
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
    getActivitiesJoined();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          getActivitiesJoined();
        },
        child: isLoading
            ? const SizedBox(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 247, 218, 202),
                  ),
                ),
              )
            : activitiesJoinedList.isEmpty
                ? const SizedBox(
                    child: Center(
                      child: TextWidget(
                        text: "No available data",
                        fontSize: 15,
                      ),
                    ),
                  )
                : SizedBox(
                    child: Padding(
                      padding: EdgeInsets.only(top: height(value: 3)),
                      child: ListView.builder(
                        itemCount: activitiesJoinedList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsets.only(top: height(value: 1)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: height(value: 13),
                                      width: width(value: 25),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  activitiesJoinedList[index]
                                                      ['imageUrl']))),
                                    ),
                                    SizedBox(
                                      width: width(value: 2),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        height: height(value: 13),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Activity Name: ${activitiesJoinedList[index]['name']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Regular",
                                                fontSize: 20,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Description: ${activitiesJoinedList[index]['description']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontFamily: "Regular",
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0),
                                                fontSize: 14,
                                              ),
                                              maxLines:
                                                  2, // Set the maximum number of lines before truncating
                                              overflow: TextOverflow
                                                  .ellipsis, // Display ellipsis (...) when the text overflows
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              DateFormat.yMMMEd().format(
                                                  DateTime.parse(
                                                      activitiesJoinedList[
                                                          index]['dateTime'])),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily: "Regular",
                                                  color: Colors.grey,
                                                  fontSize: 9),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const Divider()
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
      ),
    );
  }
}
