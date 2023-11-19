import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sk_app/models/helpdesk_model.dart';
import 'package:sk_app/widgets/toast_widget.dart';

// import 'add_notif.dart';

Future addHelpdesk(
    imageUrl, description, fileUrl, helpDeskTitle, concern) async {
  final docUser = FirebaseFirestore.instance.collection('Helpdesk').doc();

  final json = {
    'imageUrl': imageUrl,
    'title': helpDeskTitle,
    'description': description,
    'fileUrl': fileUrl, // Add the file URL to the document
    'dateTime': DateTime.now(),
    'id': docUser.id,
    'userId': FirebaseAuth.instance.currentUser!.uid,
    'action': false,
    'concern': concern
  };

  await docUser.set(json);
  showToast("Thank you!");
}
