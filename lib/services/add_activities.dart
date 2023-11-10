import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_notif.dart';

Future addActivities(
    imageUrl, name, description, date, Timestamp expirationDate) async {
  final docUser = FirebaseFirestore.instance.collection('Activities').doc();
  final currentTime = DateTime.now();
  final oneDayFromNow = currentTime.add(const Duration(days: 1));

  final json = {
    'date': date,
    'imageUrl': imageUrl,
    'name': name,
    'description': description,
    'dateTime': currentTime,
    'expirationDate':
        Timestamp.fromDate(oneDayFromNow), // Added expirationDate field
    'id': docUser.id,
    'userId': FirebaseAuth.instance.currentUser!.uid,
  };

  addNotif('New Activity: $name');

  await docUser.set(json);
}
