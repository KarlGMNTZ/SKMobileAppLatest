import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sk_app/screens/auth/login_screen.dart';
import 'package:sk_app/widgets/button_widget.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:sk_app/widgets/textfield_widget.dart';

import '../../widgets/toast_widget.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final emailController = TextEditingController();

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
                text: 'Forgot Password',
                fontSize: 24,
                fontFamily: 'Bold',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFieldWidget(label: 'Email', controller: emailController),
            const SizedBox(
              height: 30,
            ),
            ButtonWidget(
              label: 'Continue',
              onPressed: () {
                forgotPassword(context);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextWidget(
                    text: "Already had an account?",
                    fontSize: 12,
                    color: Colors.black),
                TextButton(
                  onPressed: (() {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  }),
                  child: const TextWidget(
                      fontFamily: 'Bold',
                      text: "Login Now",
                      fontSize: 14,
                      color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  forgotPassword(context) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      showToast('Password reset link sent to ${emailController.text}');
      Navigator.pop(context);
    } catch (e) {
      String errorMessage = '';

      if (e is FirebaseException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is invalid.';
            break;
          case 'user-not-found':
            errorMessage =
                'The user associated with the email address is not found.';
            break;
          default:
            errorMessage = 'An error occurred while resetting the password.';
        }
      } else {
        errorMessage = 'An error occurred while resetting the password.';
      }

      showToast(errorMessage);
    }
  }
}
