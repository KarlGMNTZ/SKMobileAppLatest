import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sk_app/screens/auth/landing_screen.dart';
import 'package:sk_app/screens/auth/login_screen.dart';
import 'package:sk_app/services/signup.dart';
import 'package:sk_app/widgets/button_widget.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:sk_app/widgets/textfield_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import '../../widgets/toast_widget.dart';

bool isValidEmail(String email) {
  // Add your email validation logic here
  // For a simple example, you can use a regular expression
  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
  return emailRegex.hasMatch(email);
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isFieldValid(String value) {
    return value.isNotEmpty;
  }

  bool loading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;

  Future<void> _sendOTP() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+63${contactNumberController.text}',
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
          _showOTPDialog();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: const Duration(seconds: 60),
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
          title: const Text('Enter OTP'),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _verifyAndRegister(enteredOTP);
              },
              child: const Text('Verify'),
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
  final disabilityController = TextEditingController();

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

  String selectedFamilyStatus = 'Parents are living together';
  // Store the selected voter
  List<String> familyStatusOption = [
    'Parents are living together',
    'Both parents are separated',
    'Only monther/father is with you',
  ];

  String selectedFamilyIncome = 'Less than 10,000';
  // Store the selected voter
  List<String> familyIncomeOption = [
    'Less than 10,000',
    '20,000 to 30,000',
    '30,000 to 50,000',
    '50,000 to 75,000',
    '75,000 and above',
  ];

  String selectedSex = 'Male';
  // Store the selected voter
  List<String> sexOptions = [
    'Male',
    'Female',
  ];

  String radioButtonGroupValue = '';
  String radioPWDButtonGroupValue = '';

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
                        gradient: const LinearGradient(
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
                            offset: const Offset(0, 5),
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
            const Center(
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
            TextFieldWidget(
              label: 'First Name',
              hint: 'Enter your first name',
              controller: fnameController,
              isRequred: true, // Indicate that this field is required
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First Name is required';
                }
                return null; // Return null if the validation is successful
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextFieldWidget(
              label: 'Middle Name',
              hint: 'Enter your middle name',
              controller: mnameController,
              isRequred: true, // Indicate that this field is required
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Middle Name is required';
                }
                return null; // Return null if the validation is successful
              },
              // Add any other properties or customization you need
            ),
            const SizedBox(
              height: 10,
            ),
            TextFieldWidget(
              label: 'Last Name',
              hint: 'Enter your last name',
              controller: lnameController,
              isRequred: true, // Indicate that this field is required
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Last Name is required';
                }
                return null; // Return null if the validation is successful
              },
              // Add any other properties or customization you need
            ),
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
                    padding: const EdgeInsets.only(right: 10),
                    isExpanded: true,
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
                    const Icon(Icons.calendar_today, color: Colors.black),
                  ],
                ),
              ),
            ),
            Text(
              'Age: ${calculateAge(birthdate)}',
              style: const TextStyle(
                  fontSize: 16), // Adjust the font size as needed
            ),
            TextFieldWidget(
              label: 'Email',
              hint: 'Enter your email address',
              controller: emailController,
              inputType:
                  TextInputType.emailAddress, // Set the input type for email
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                } else if (!isValidEmail(value)) {
                  return 'Enter a valid email address';
                }
                return null; // Return null if the validation is successful
              },
              // Add any other properties or customization you need
            ),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    '+63',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                // Adjust the space between the box and the text field
                Expanded(
                  child: TextFieldWidget(
                    inputType: TextInputType.number,
                    label: 'Contact Number',
                    controller: contactNumberController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                          10), // Limit the length to 10 digits
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            TextFieldWidget(
              label: 'Address',
              hint: 'Enter your address',
              controller: addressController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Address is required';
                }
                // Add any additional address validation logic here if needed
                return null; // Return null if the validation is successful
              },
              // Add any other properties or customization you need
            ),
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
                    padding: const EdgeInsets.only(right: 10),
                    isExpanded: true,
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
                    padding: const EdgeInsets.only(right: 10),
                    isExpanded: true,
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
                    padding: const EdgeInsets.only(right: 10),
                    isExpanded: true,
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
                    padding: const EdgeInsets.only(right: 10),
                    isExpanded: true,
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
                    padding: const EdgeInsets.only(right: 10),
                    isExpanded: true,
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
                    padding: const EdgeInsets.only(right: 10),
                    isExpanded: true,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Family Status',
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
                    padding: const EdgeInsets.only(right: 10),
                    isExpanded: true,
                    underline: const SizedBox(),
                    value: selectedFamilyStatus,
                    onChanged: (newValue5) {
                      setState(() {
                        selectedFamilyStatus = newValue5!;
                      });
                    },
                    items: familyStatusOption
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
                        text: 'Family Income',
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
                    isExpanded: true,
                    padding: const EdgeInsets.only(right: 10),
                    underline: const SizedBox(),
                    value: selectedFamilyIncome,
                    onChanged: (newValue5) {
                      setState(() {
                        selectedFamilyIncome = newValue5!;
                      });
                    },
                    items: familyIncomeOption
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
              height: 20,
            ),
            const SizedBox(
              child: Text(
                'Are you a Person with Disabilities?',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bold',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                    value: "Yes",
                    groupValue: radioPWDButtonGroupValue,
                    onChanged: (value) {
                      setState(() {
                        radioPWDButtonGroupValue = value!;
                      });
                    }),
                const Text("Yes"),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
                Radio(
                    value: "No",
                    groupValue: radioPWDButtonGroupValue,
                    onChanged: (value) {
                      setState(() {
                        radioPWDButtonGroupValue = value!;
                      });
                    }),
                const Text("No"),
              ],
            ),
            radioPWDButtonGroupValue == "No"
                ? const SizedBox()
                : TextFieldWidget(
                    label: 'Specify Illness/Disabilities',
                    hint: 'Illness/Disabilities',
                    controller: disabilityController,
                    inputType:
                        TextInputType.text, // Set the input type for email

                    // Add any other properties or customization you need
                  ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              child: Text(
                'Areas you are Interested in',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bold',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Radio(
                    value: "Health",
                    groupValue: radioButtonGroupValue,
                    onChanged: (value) {
                      setState(() {
                        radioButtonGroupValue = value!;
                      });
                    }),
                const Text("Health"),
                Radio(
                    value: "Education",
                    groupValue: radioButtonGroupValue,
                    onChanged: (value) {
                      setState(() {
                        radioButtonGroupValue = value!;
                      });
                    }),
                const Text("Education"),
                Radio(
                    value: "Security",
                    groupValue: radioButtonGroupValue,
                    onChanged: (value) {
                      setState(() {
                        radioButtonGroupValue = value!;
                      });
                    }),
                const Text("Security")
              ],
            ),
            Row(
              children: [
                Radio(
                    value: "Governance",
                    groupValue: radioButtonGroupValue,
                    onChanged: (value) {
                      setState(() {
                        radioButtonGroupValue = value!;
                      });
                    }),
                const Text("Governance"),
                Radio(
                    value: "Citizenship",
                    groupValue: radioButtonGroupValue,
                    onChanged: (value) {
                      setState(() {
                        radioButtonGroupValue = value!;
                      });
                    }),
                const Text("Citizenship"),
                Radio(
                    value: "Sports",
                    groupValue: radioButtonGroupValue,
                    onChanged: (value) {
                      setState(() {
                        radioButtonGroupValue = value!;
                      });
                    }),
                const Text("Sports")
              ],
            ),
            Row(
              children: [
                Radio(
                    value: "Economic Empowerment",
                    groupValue: radioButtonGroupValue,
                    onChanged: (value) {
                      setState(() {
                        radioButtonGroupValue = value!;
                      });
                    }),
                const Text(
                  "Economic Empowerment",
                ),
                Radio(
                    value: "Social Inclusion",
                    groupValue: radioButtonGroupValue,
                    onChanged: (value) {
                      setState(() {
                        radioButtonGroupValue = value!;
                      });
                    }),
                const Text(
                  "Social Inclusion",
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
                try {
                  setState(() {
                    loading =
                        true; // Set loading to true when starting the upload
                  });

                  final FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    onFileLoading: (p0) {
                      return const CircularProgressIndicator();
                    },
                  );

                  if (result != null) {
                    setState(() {
                      pickedFile = true;
                      fileName = result.names[0]!;
                      imageFile = File(result.paths[0]!);
                    });

                    await firebase_storage.FirebaseStorage.instance
                        .ref('Files/$fileName')
                        .putFile(imageFile);

                    fileUrl = await firebase_storage.FirebaseStorage.instance
                        .ref('Files/$fileName')
                        .getDownloadURL();

                    // Perform any additional logic with fileUrl if needed

                    setState(() {
                      loading =
                          false; // Set loading to false after a successful upload
                    });
                  } else {
                    // Handle the case when the user cancels the file picking
                    setState(() {
                      loading =
                          false; // Set loading to false in case of cancellation
                    });
                  }
                } catch (error) {
                  // Handle any errors that might occur during the upload
                  print('Error uploading file: $error');
                  setState(() {
                    loading = false; // Set loading to false in case of an error
                  });
                }
              },
            ),
            if (loading) const CircularProgressIndicator(),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                // Check if all required fields are filled
                if (pickedFile &&
                    isFieldValid(fnameController.text) &&
                    isFieldValid(mnameController.text) &&
                    isFieldValid(lnameController.text) &&
                    isFieldValid(contactNumberController.text) &&
                    isFieldValid(addressController.text)) {
                  // All required fields are filled, proceed with the sign-up process

                  // First, send OTP
                  _sendOTP();

                  // Show dialog for OTP entry
                } else {
                  showToast(
                      'Please fill in all required fields and \nupload proof of residency');
                }
              },
              child: const Text('Sign Up'),
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
      print("Family Status: $selectedFamilyStatus");
      print("Family Income: $selectedFamilyIncome");
      print("Areas interested in: $radioButtonGroupValue");
      print("is PWD: $radioPWDButtonGroupValue");
      print("Illness/Disability detail: $disabilityController");

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
          selectedFamilyStatus,
          selectedFamilyIncome,
          radioButtonGroupValue,
          radioPWDButtonGroupValue,
          disabilityController.text);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => const LandingScreen()));
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
      showToast("Registered Successfully!");
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
