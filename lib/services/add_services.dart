import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_notif.dart';

Future addServices(
    imageUrl, name, description, Timestamp expirationDate) async {
  final docUser = FirebaseFirestore.instance.collection('Services').doc();
  final currentTime = DateTime.now();
  final oneDayFromNow = currentTime.add(const Duration(days: 1));

  final json = {
    'imageUrl': imageUrl,
    'name': name,
    'description': description,
    'dateTime': currentTime,
    'expirationDate': Timestamp.fromDate(oneDayFromNow),
    'id': docUser.id,
    'userId': FirebaseAuth.instance.currentUser!.uid,
  };

  addNotif('Added a service: $name');

  await docUser.set(json);
}
