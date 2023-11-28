import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sk_app/screens/pages/ideas_page_create.dart';
import 'package:sk_app/widgets/text_widget.dart';

class IdeasPages extends StatefulWidget {
  const IdeasPages({super.key});

  @override
  State<IdeasPages> createState() => _IdeasPagesState();
}

class _IdeasPagesState extends State<IdeasPages> {
  List topicsList = [];
  getTopics() async {
    var res = await FirebaseFirestore.instance
        .collection('Topics')
        .where('expirationDate',
            isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .get();
    var topics = res.docs;
    List tempData = [];
    for (var i = 0; i < topics.length; i++) {
      Map mapData = topics[i].data();
      mapData['id'] = topics[i].id;
      mapData['dateTime'] = mapData['dateTime'].toDate().toString();
      mapData['expirationDate'] = mapData['expirationDate'].toDate().toString();
      tempData.add(mapData);
    }
    setState(() {
      topicsList = tempData;
    });
  }

  @override
  void initState() {
    getTopics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        backgroundColor: Colors.black,
        title: const Text('Topic'),
        centerTitle: true, // Set the title as needed
        // Add any other app bar configuration you need
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05),
          child: ListView.builder(
            itemCount: topicsList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateIdeasPages(
                                    name: topicsList[index]['topicName'],
                                    description: topicsList[index]['topicName'],
                                    id: topicsList[index]['id'],
                                  )),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: topicsList[index]['topicName'],
                            fontSize: 15,
                            isBold: true,
                            color: Colors.white,
                          ),
                          const Icon(Icons.arrow_forward_ios)
                        ],
                      ),
                    ),
                  ));
            },
          ),
        ),
      ),
    );
  }
}
