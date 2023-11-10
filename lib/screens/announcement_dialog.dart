import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnnouncementDialog extends StatelessWidget {
  final String id;

  const AnnouncementDialog({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    if (id.isEmpty) {
      return const Text('User ID is empty or null');
    }
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Announcements')
            .orderBy('dateTime', descending: true)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData && snapshot.data!.size == 0) {
            return _buildNoAnnouncementFound(context);
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        insetPadding: const EdgeInsets.fromLTRB(44, 55, 66, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'ANNOUNCEMENT!',
                              style: TextStyle(
                                fontSize:
                                    24, // You can adjust the font size as needed
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              data.docs[index]['name'],
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Bold',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              data.docs[index]['description'],
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              DateFormat.yMMMd().add_jm().format(
                                  data.docs[index]['dateTime'].toDate()),
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Bold',
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "VIEW",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Bold',
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        data.docs[index]['name'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Bold',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        DateFormat.yMMMd()
                            .add_jm()
                            .format(data.docs[index]['dateTime'].toDate()),
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Bold',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Widget _buildNoAnnouncementFound(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Announcement not found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
