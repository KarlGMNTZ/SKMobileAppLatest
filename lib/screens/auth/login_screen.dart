import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sk_app/screens/auth/forgot_password_screen.dart';
import 'package:sk_app/screens/auth/signup_screen.dart';
import 'package:sk_app/screens/home_screen.dart';
import 'package:sk_app/widgets/button_widget.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:sk_app/widgets/textfield_widget.dart';

import '../../widgets/toast_widget.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final medQuery = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Row(
                  children: [
                    Container(
                      height: 225,
                      width: medQuery.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 175, 87, 40),
                            Color.fromARGB(255, 221, 145, 69),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Center(
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                          image: const DecorationImage(
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.fitWidth)),
                    ),
                  ),
                ),
              ],
            ),
            const Center(
              child: TextWidget(
                text: 'Sign In',
                fontSize: 24,
                fontFamily: 'Bold',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFieldWidget(label: 'Email', controller: emailController),
            const SizedBox(
              height: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFieldWidget(
                    showEye: true,
                    isObscure: true,
                    label: 'Password',
                    controller: passwordController),
                TextButton(
                  onPressed: (() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen()));
                  }),
                  child: const TextWidget(
                      fontFamily: 'Bold',
                      text: "Forgot Password?",
                      fontSize: 12,
                      color: Colors.red),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            ButtonWidget(
              label: 'Sign In',
              onPressed: () {
                login(context);
              },
              color: Color.fromARGB(255, 210, 123, 75), // Light beige color
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextWidget(
                    text: "No Account?", fontSize: 12, color: Colors.black),
                TextButton(
                  onPressed: (() {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const SignupScreen()));
                  }),
                  child: const TextWidget(
                      fontFamily: 'Bold',
                      text: "Signup Now",
                      fontSize: 14,
                      color: Colors.black),
                ),
              ],
            ),
            //TextButton(
            //onPressed: (() {
            // Navigator.of(context).pushReplacement(
            //     MaterialPageRoute(
            //         builder: (context) => SignupScreen()));
            //}),
            //child: const TextWidget(
            //fontFamily: 'Bold',
            //text: "Continue as Admin",
            //fontSize: 14,
            // color: Colors.blue),
            //),
          ],
        ),
      ),
    );
  }

  login(context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      // Get the user data from Firebase
      User? user = userCredential.user;
      if (user != null) {
        // Retrieve additional user data from your database
        // Assuming you have a 'users' collection in Firestore
        var res = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        // Check if the account is active
        var userData = res.data();
        bool? isActive = false;
        if (userData != null) {
          isActive = userData['isActive'];
          if (isActive!) {
            getToken();
            // If the account is active, navigate to the home screen
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            });
          } else {
            // If the account is not active, show a toast and sign out
            await FirebaseAuth.instance.signOut();
            showToast("Account not yet activated.");
          }
        } else {
          await FirebaseAuth.instance.signOut();
          showToast("User did not exist.");
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle authentication exceptions
      if (e.code == 'user-not-found') {
        showToast("No user found with that email.");
      } else if (e.code == 'wrong-password') {
        showToast("Wrong password provided for that user.");
      } else if (e.code == 'invalid-email') {
        showToast("Invalid email provided.");
      } else if (e.code == 'user-disabled') {
        showToast("User account has been disabled.");
      } else {
        showToast("An error occurred: ${e.message}");
      }
    } on Exception catch (e) {
      // Handle other exceptions
      showToast("An error occurred: $e");
    }
  }

  Future<void> getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    var res = await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .limit(1)
        .get();
    if (res.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(res.docs[0].id)
          .update({"fcmToken": token});
    }
  }
}
