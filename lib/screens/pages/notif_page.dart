import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/text_widget.dart';

class NotifPage extends StatefulWidget {
  const NotifPage({Key? key}) : super(key: key);

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  @override
  void initState() {
    super.initState();

    // Schedule the deletion after 5 seconds
    Future.delayed(const Duration(seconds: 1), () {
      deleteExpiredDocuments();
    });
  }

  void deleteExpiredDocuments() {
    DateTime now = DateTime.now();
    DateTime fiveSecondsAgo = now.subtract(const Duration(days: 1));

    FirebaseFirestore.instance
        .collection('Notif')
        .where('dateTime', isLessThan: fiveSecondsAgo)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    // Optionally, you can trigger a rebuild of the widget after deletion
    // setState(() {});
  }

  void _showNotificationDialog(String name, Timestamp dateTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: $name', style: const TextStyle(fontSize: 16)),
              Text(
                  'Date & Time: ${DateFormat.yMMMd().add_jm().format(dateTime.toDate())}',
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget(
          text: 'Notifications',
          fontSize: 18,
          color: Colors.white,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Notif')
            .orderBy('dateTime', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text('Error'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
            );
          }

          final data = snapshot.requireData;
          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _showNotificationDialog(
                      data.docs[index]['name'], data.docs[index]['dateTime']);
                },
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title:
                      TextWidget(text: data.docs[index]['name'], fontSize: 14),
                  subtitle: TextWidget(
                    text: DateFormat.yMMMd()
                        .add_jm()
                        .format(data.docs[index]['dateTime'].toDate()),
                    fontSize: 12,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
