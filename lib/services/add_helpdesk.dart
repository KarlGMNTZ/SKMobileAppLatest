import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'add_notif.dart';

Future addHelpdesk(imageUrl, description, fileUrl) async {
  final docUser = FirebaseFirestore.instance.collection('Helpdesk').doc();

  final json = {
    'imageUrl': imageUrl,
    'description': description,
    'fileUrl': fileUrl, // Add the file URL to the document
    'dateTime': DateTime.now(),
    'id': docUser.id,
    'userId': FirebaseAuth.instance.currentUser!.uid,
    'action': false,
  };

  await docUser.set(json);
}
