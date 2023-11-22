import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_notif.dart';

Future<void> addCrowdsourcing(
  imageUrl,
  name,
  description,
  List<String> options,
  Timestamp expirationDate,
) async {
  final docUser = FirebaseFirestore.instance.collection('Crowdsourcing').doc();
  final currentTime = DateTime.now();

  // Create a list to store option objects with text and votes
  List<Map<String, dynamic>> optionObjects = [];

  for (String optionText in options) {
    // Initialize each option with text and an empty vote count
    optionObjects.add({
      'text': optionText,
      'votes1': [], // Initialize votes as an empty array for each option
    });
  }

  final json = {
    'options': optionObjects, // Store option objects with text and votes
    'imageUrl': imageUrl,
    'name': name,
    //'daysValid': int.parse(validDays.toString()),
    'isApprove': false,
    'description': description,
    'dateTime': currentTime,
    'expirationDate': expirationDate, // Added expirationDate field
    'isArchived': false,
    'id': docUser.id,
    'userId': FirebaseAuth.instance.currentUser!.uid,
    'comments': [], // Comments related to the crowdsourcing
    'new': [], // Any other data related to the crowdsourcing
    'likes': [], // Initialize the likes array as empty
  };

  addNotif('New Crowdsourcing: $name');
  await docUser.set(json);
}
