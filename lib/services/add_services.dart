import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_notif.dart';

Future addServices(
    imageUrl, name, description, Timestamp expirationDate) async {
  final docUser = FirebaseFirestore.instance.collection('Services').doc();
  final currentTime = DateTime.now();

  final json = {
    'imageUrl': imageUrl,
    'name': name,
    'description': description,
    'dateTime': currentTime,
    'expirationDate': expirationDate,
    'id': docUser.id,
    'userId': FirebaseAuth.instance.currentUser!.uid,
  };

  addNotif('Added a service: $name');
  sendNotification(bodymessage: name, subtitle: "", title: "New service added");
  await docUser.set(json);
}

sendNotification(
    {required String bodymessage,
    required String subtitle,
    required String title}) async {
  var res = await FirebaseFirestore.instance.collection('Users').get();
  var users = res.docs;
  for (var i = 0; i < users.length; i++) {
    Map userdetails = users[i].data();
    if (userdetails.containsKey('fmcToken')) {
      var body = jsonEncode({
        "to": userdetails['fmcToken'],
        "notification": {
          "body": bodymessage,
          "title": title,
          "subtitle": subtitle,
        }
      });

      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            "Authorization":
                "key=AAAAgA2op94:APA91bHTvzBNOLkTDDlV6wKqFsjHg7At0-jIv61Mo--t_jk8a-VD1vEWp20b2KZuiIHOjhNGG_PyWrjamPXXSm2I7BlPr-qr8K-KC1ShXa6Q4ow34zML5ehzBTLmbm3Rwa40JgOSPdPr",
            "Content-Type": "application/json"
          },
          body: body);
    }
  }
}
