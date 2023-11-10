import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sk_app/screens/auth/login_screen.dart';
import 'package:sk_app/screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> userStream;
  Future<bool> checkApprovalStatus() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final userData = docSnapshot.data() as Map<String, dynamic>?;

    if (userData != null) {
      final isApproved = (userData['isActive'] as bool?) ?? false;
      return isApproved;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();

    // Set up the stream for real-time updates
    userStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
        //title: Text('PENDING FOR APPROVAL'),
        //backgroundColor: Colors.deepPurple,
        //centerTitle: true,
      //),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final userData = snapshot.data?.data() as Map<String, dynamic>?;

            if (userData != null) {
              return buildLandingScreen(userData);
            } else {
              // Handle the case where data is not available
              return buildNotApprovedScreen();
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildLandingScreen(Map<String, dynamic> userData) {
    final isApproved = userData['isActive'] as bool? ?? false;

    return AnimatedSwitcher(
      duration: Duration(seconds: 1),
      child: isApproved ? buildApprovedScreen() : buildNotApprovedScreen(),
    );
  }

Widget buildNotApprovedScreen() {
    return Card(
      margin: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Colors.red),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  "PENDING APPROVAL",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.network(
                  'https://cdn.pixabay.com/animation/2022/12/05/15/23/15-23-06-837_512.gif',
                  width: 300,
                  height: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "Oops! You are not approved by the admin.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    showContactAdminOptions(context);
                  },
                  child: Text("Contact Admin"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    onPrimary: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'or',
                  style: TextStyle(
                    color: Color.fromARGB(255, 155, 147, 147), // Darker shade of grey
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Sign in with another account",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildApprovedScreen() {
    return Card(
      margin: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Colors.green),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  "APPROVED",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.network(
                  'https://cdn.pixabay.com/animation/2022/12/11/04/11/04-11-18-929_512.gif',
                  width: 300,
                  height: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "Hooray! You are approved!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text("Go to Home"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple,
                    onPrimary: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showContactAdminOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Send Email'),
                onTap: () {
                  //replace lng
                  launch('bien:admin@example.com');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Call Admin'),
                onTap: () {
                  // Rreplace lg
                  launch('tel:+6391122');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
