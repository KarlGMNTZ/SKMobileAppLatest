import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_notif.dart';

Future addSurvey(name, description, link, Timestamp timestamp, Timestamp expirationDate) async {
  final docUser = FirebaseFirestore.instance.collection('Surveys').doc();
final currentTime = DateTime.now();
final oneDayFromNow = currentTime.add(const Duration(days: 1));

final json = {
  'link': link,
  'name': name,
  'description': description,
  'dateTime': currentTime,
  'expirationDate': Timestamp.fromDate(oneDayFromNow), 
  'id': docUser.id,
  'userId': FirebaseAuth.instance.currentUser!.uid,
  'response': []
};
  addNotif('New Survey: $name');

  await docUser.set(json);
}
