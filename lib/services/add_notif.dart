import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addNotif(
  name,
) async {
  final docUser = FirebaseFirestore.instance.collection('Notif').doc();

  final json = {
    'name': name,
    'dateTime': DateTime.now(),
    'id': docUser.id,
    'userId': FirebaseAuth.instance.currentUser!.uid,
  };

  await docUser.set(json);
}
