import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

Future addRegistration(imageUrl, teamName, comment, fileUrl, activityid) async {
  final docUser = FirebaseFirestore.instance.collection('Registration').doc();
  final activityDocRef =
      FirebaseFirestore.instance.collection('Activities').doc(activityid);

  var res = await FirebaseFirestore.instance
      .collection('Users')
      .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .limit(1)
      .get();
  if (res.docs.isNotEmpty) {
    var userDetails = res.docs[0].data();
    var userDocumentRef =
        FirebaseFirestore.instance.collection('Users').doc(res.docs[0].id);
    final json = {
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'teamName': teamName,
      'comment': comment,
      'dateTime': DateTime.now(),
      'id': docUser.id,
      'activityID': activityid,
      'activityDocRef': activityDocRef,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'userFullName': userDetails['fname'] + " " + userDetails['lname'],
      "userProfile": userDetails['profile'],
      'userDocumentRef': userDocumentRef
    };

    await docUser.set(json);
  }
}
