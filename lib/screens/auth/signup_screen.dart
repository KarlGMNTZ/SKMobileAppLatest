import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sk_app/screens/auth/landing_screen.dart';
import 'package:sk_app/screens/auth/login_screen.dart';
import 'package:sk_app/screens/home_screen.dart';
import 'package:sk_app/services/signup.dart';
import 'package:sk_app/widgets/button_widget.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:sk_app/widgets/textfield_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import '../../widgets/toast_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;

  Future<void> _sendOTP() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+639928594661',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Error: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _verifyOTP(String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      // OTP verification successful, proceed with user registration or other actions
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _showOTPDialog() async {
    String enteredOTP = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter OTP'),
          content: TextField(
            onChanged: (value) {
              enteredOTP = value;
            },
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _verifyAndRegister(enteredOTP);
              },
              child: Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyAndRegister(String otp) async {
    // Verify OTP
    await _verifyOTP(otp);

    // Check if verification was successful
    if (_auth.currentUser != null) {
      // User is verified, proceed with registration
      register(context);
    } else {
      // Show error message
      showToast('Invalid OTP. Please try again.');
    }
  }

  late String fileName = '';
  late String fileUrl = '';

  late File imageFile;

  late String imageURL = '';
  bool hasLoaded = false;
  bool pickedFile = false;

  DateTime? birthdate;

  @override
  void dispose() {
    // Cancel any asynchronous operations or timers here
    // Example: myTimer?.cancel();

    super.dispose();
  }

  int calculateAge(DateTime? birthdate) {
    if (birthdate == null) {
      return 0; // You can handle this case as needed
    }

    final currentDate = DateTime.now();
    int age = currentDate.year - birthdate.year;

    // Check if the birthdate has occurred this year
    if (birthdate.month > currentDate.month ||
        (birthdate.month == currentDate.month &&
            birthdate.day > currentDate.day)) {
      age--;
    }

    return age;
  }

  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != birthdate) {
      setState(() {
        birthdate = picked;
        birthdateController.text =
            birthdate!.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> uploadImage(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

      fileName = path.basename(pickedImage.path);
      imageFile = File(pickedImage.path);

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: AlertDialog(
                title: Row(
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Loading . . .',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular'),
                ),
              ],
            )),
          ),
        );

        await firebase_storage.FirebaseStorage.instance
            .ref('Users/$fileName')
            .putFile(imageFile);
        imageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Users/$fileName')
            .getDownloadURL();

        setState(() {
          hasLoaded = true;
        });

        Navigator.of(context).pop();
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fnameController = TextEditingController();
  final mnameController = TextEditingController();
  final lnameController = TextEditingController();
  final birthdateController = TextEditingController();
  final addressController = TextEditingController();
  final contactNumberController = TextEditingController();

  String selectedPurok = 'Purok 1';
  // Store the selected purok
  List<String> purokOptions = [
    'Purok 1',
    'Purok 2',
    'Purok 3',
    'Purok 4',
    'Purok 5',
    'Purok 6',
    'Purok 7',
    'Purok 8',
    'Purok 9',
    'Purok 10',
  ];

  String selectedCivil = 'Single';
  // Store the selected civilstatus
  List<String> civilOptions = [
    'Single',
    'Married',
    'Widowed',
    'Separated',
    'Live-in',
  ];

  String selectedYouth = 'In-School Youth';
  // Store the selected youthclass
  List<String> youthOptions = [
    'In-School Youth',
    'Out-of-School Youth',
    'Working Youth',
    'Youth with special needs',
  ];

  String selectedSchool = 'Elementary Level';
  // Store the selected schoolattainment
  List<String> schoolOptions = [
    'Elementary Level',
    'Elementary Graduate',
    'Highschool Level',
    'Highschool Graduate',
    'Vocational Graduate',
    'College Level',
    'College Graduate',
    'Masters Graduate',
    'Doctors Graduate',
  ];

  String selectedWork = 'Employed';
  // Store the selected workstatus
  List<String> workOptions = [
    'Employed',
    'Unemployed',
    'Self-imployed',
    'Currently Looking for a Job',
    'Not interested for a Job',
  ];

  String selectedVoter = 'Yes';
  // Store the selected voter
  List<String> voterOptions = [
    'Yes',
    'No',
  ];

  String selectedSex = 'Male';
  // Store the selected voter
  List<String> sexOptions = [
    'Male',
    'Female',
  ];

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
                      height: 150,
                      width: medQuery.width * 0.5,
                      decoration: const BoxDecoration(color: Colors.blue),
                    ),
                    Container(
                      height: 150,
                      width: medQuery.width * 0.5,
                      decoration: const BoxDecoration(color: Colors.red),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Center(
                    child: Container(
                      height: 150,
                      width: 150,
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
            const SizedBox(
              height: 10,
            ),
            Center(
              child: TextWidget(
                text: 'Sign Up',
                fontSize: 24,
                fontFamily: 'Bold',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
                onTap: () {
                  uploadImage('gallery');
                },
                child: hasLoaded
                    ? CircleAvatar(
                        minRadius: 45,
                        maxRadius: 45,
                        backgroundImage: NetworkImage(imageURL),
                        child: const Icon(
                          Icons.photo_size_select_actual_rounded,
                          color: Colors.black,
                        ),
                      )
                    : const CircleAvatar(
                        minRadius: 45,
                        maxRadius: 45,
                        backgroundImage:
                            AssetImage('assets/images/profile.png'),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(70, 50, 0, 0),
                          child: Icon(
                            Icons.photo_size_select_actual_rounded,
                            color: Colors.black,
                          ),
                        ),
                      )),
            const SizedBox(
              height: 10,
            ),
            TextFieldWidget(label: 'First Name', controller: fnameController),
            const SizedBox(
              height: 10,
            ),
            TextFieldWidget(label: 'Middle Name', controller: mnameController),
            const SizedBox(
              height: 10,
            ),
            TextFieldWidget(label: 'Last Name', controller: lnameController),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Sex',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 325,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<String>(
                    underline: const SizedBox(),
                    value: selectedSex,
                    onChanged: (newValue6) {
                      setState(() {
                        selectedSex = newValue6!;
                      });
                    },
                    items: sexOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextWidget(
                            text: value,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                _selectBirthdate(context);
              },
              child: Container(
                width: 325,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextWidget(
                      text: birthdate != null
                          ? birthdate!.toLocal().toString().split(' ')[0]
                          : 'Select Birthdate',
                      fontSize: 16,
                    ),
                    Icon(Icons.calendar_today, color: Colors.black),
                  ],
                ),
              ),
            ),
            Text(
              'Age: ${calculateAge(birthdate)}',
              style: TextStyle(fontSize: 16), // Adjust the font size as needed
            ),
            TextFieldWidget(label: 'Email', controller: emailController),
            const SizedBox(
              height: 5,
            ),
            TextFieldWidget(
                showEye: true,
                isObscure: true,
                label: 'Password',
                controller: passwordController),
            const SizedBox(
              height: 2,
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '+63',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8),
                // Adjust the space between the box and the text field
                Expanded(
                  child: TextFieldWidget(
                    inputType: TextInputType.number,
                    label: 'Contact Number',
                    controller: contactNumberController,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            TextFieldWidget(label: 'Address', controller: addressController),
            const SizedBox(
              height: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Purok',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 325,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<String>(
                    underline: const SizedBox(),
                    value: selectedPurok,
                    onChanged: (newValue) {
                      setState(() {
                        selectedPurok = newValue!;
                      });
                    },
                    items: purokOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextWidget(
                            text: value,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Civil Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 325,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<String>(
                    underline: const SizedBox(),
                    value: selectedCivil,
                    onChanged: (newValue1) {
                      setState(() {
                        selectedCivil = newValue1!;
                      });
                    },
                    items: civilOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextWidget(
                            text: value,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Youth-Class',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 325,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<String>(
                    underline: const SizedBox(),
                    value: selectedYouth,
                    onChanged: (newValue2) {
                      setState(() {
                        selectedYouth = newValue2!;
                      });
                    },
                    items: youthOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextWidget(
                            text: value,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Highest School Attainment',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 325,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<String>(
                    underline: const SizedBox(),
                    value: selectedSchool,
                    onChanged: (newValue3) {
                      setState(() {
                        selectedSchool = newValue3!;
                      });
                    },
                    items: schoolOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextWidget(
                            text: value,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Work Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 325,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<String>(
                    underline: const SizedBox(),
                    value: selectedWork,
                    onChanged: (newValue4) {
                      setState(() {
                        selectedWork = newValue4!;
                      });
                    },
                    items: workOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextWidget(
                            text: value,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Are you a voter',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 325,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<String>(
                    underline: const SizedBox(),
                    value: selectedVoter,
                    onChanged: (newValue5) {
                      setState(() {
                        selectedVoter = newValue5!;
                      });
                    },
                    items: voterOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextWidget(
                            text: value,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            ButtonWidget(
              fontSize: 14,
              label: 'Upload proof of residency',
              onPressed: () async {
                await FilePicker.platform
                    .pickFiles(
                  allowMultiple: false,
                  onFileLoading: (p0) {
                    return const CircularProgressIndicator();
                  },
                )
                    .then((value) {
                  setState(
                    () {
                      pickedFile = true;
                      fileName = value!.names[0]!;
                      imageFile = File(value.paths[0]!);
                    },
                  );
                  return null;
                });

                await firebase_storage.FirebaseStorage.instance
                    .ref('Files/$fileName')
                    .putFile(imageFile);
                fileUrl = await firebase_storage.FirebaseStorage.instance
                    .ref('Files/$fileName')
                    .getDownloadURL();
                setState(() {});
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                if (pickedFile) {
                  // First, send OTP
                  _sendOTP();
                  // Show dialog for OTP entry
                } else {
                  showToast('Upload proof of residency');
                }
              },
              child: Text('Sign Up'),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                    text: "Already had an account?",
                    fontSize: 12,
                    color: Colors.black),
                TextButton(
                  onPressed: (() {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  }),
                  child: TextWidget(
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

  register(context) async {
    try {
      print("fname: ${fnameController.text}");
      print("mname: ${mnameController.text}");
      print("lname: ${lnameController.text}");
      print("Sex: $selectedSex");
      print("Age: $calculateAge");
      print("Email: ${emailController.text}");
      print("Number: $contactNumberController.text");
      print("Address: ${addressController.text}");
      print("Purok: $selectedPurok");
      print("Civil: $selectedCivil");
      print("Youth: $selectedYouth");
      print("School: $selectedSchool");
      print("Work: $selectedWork");
      print("Voter: $selectedVoter");

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      int age = calculateAge(birthdate);

      signup(
        fnameController.text,
        mnameController.text,
        lnameController.text,
        selectedSex,
        age,
        birthdate,
        emailController.text,
        contactNumberController.text,
        addressController.text,
        selectedPurok,
        selectedCivil,
        selectedYouth,
        selectedSchool,
        selectedWork,
        selectedVoter,
        imageURL,
        fileUrl,
      );

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      showToast("Registered Successfully!");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LandingScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showToast('The email address is not valid.');
      } else {
        showToast(e.toString());
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}
