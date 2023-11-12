import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                      width: medQuery.width * 0.5,
                      decoration: const BoxDecoration(color: Colors.blue),
                    ),
                    Container(
                      height: 225,
                      width: medQuery.width * 0.5,
                      decoration: const BoxDecoration(color: Colors.red),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(
                    child: Container(
                      height: 300,
                      width: 250,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
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
            TextButton(
              onPressed: (() {
                // Navigator.of(context).pushReplacement(
                //     MaterialPageRoute(
                //         builder: (context) => SignupScreen()));
              }),
              child: const TextWidget(
                  fontFamily: 'Bold',
                  text: "Continue as Admin",
                  fontSize: 14,
                  color: Colors.blue),
            ),
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
            // If the account is active, navigate to the home screen
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()));
          } else {
            // If the account is not active, show a toast and sign out
            await FirebaseAuth.instance.signOut();
            showToast("Account is not approve by admin.");
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
}
