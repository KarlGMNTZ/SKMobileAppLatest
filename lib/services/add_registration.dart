import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addRegistration(
  imageUrl,
  teamName,
  comment,
  fileUrl,
) async {
  final docUser = FirebaseFirestore.instance.collection('Registration').doc();

  final json = {
    'imageUrl': imageUrl,
    'fileUrl': fileUrl,
    'teamName': teamName,
    'comment': comment,
    'dateTime': DateTime.now(),
    'id': docUser.id,
    'userId': FirebaseAuth.instance.currentUser!.uid,
  };

  await docUser.set(json);
}
