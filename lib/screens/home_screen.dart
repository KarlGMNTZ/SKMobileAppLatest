import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:path/path.dart' as path;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sk_app/screens/announcement_dialog.dart';
import 'package:sk_app/screens/auth/login_screen.dart';
import 'package:sk_app/screens/pages/SpecificActivity.dart';
import 'package:sk_app/screens/pages/UserInfoDisplay.dart';
import 'package:sk_app/screens/pages/activities_page.dart';
import 'package:sk_app/screens/pages/announcements_page.dart';
import 'package:sk_app/screens/pages/crowdsourcing_page.dart';
import 'package:sk_app/screens/pages/helpdesk/main_helpdesk_page.dart';
import 'package:sk_app/screens/pages/notif_page.dart';
import 'package:sk_app/screens/pages/registration_page.dart';
import 'package:sk_app/screens/pages/services_page.dart';
import 'package:sk_app/screens/pages/survey_page.dart';
import 'package:sk_app/screens/pages/tabbar.dart';
import 'package:sk_app/services/add_activities.dart';
import 'package:sk_app/utils/colors.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:sk_app/widgets/textfield_widget.dart';

import '../widgets/instruction_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool dialogShown = true; //dili na makita ang anncouncement
  String id = '1';

  @override
  void initState() {
    super.initState();
    getUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!dialogShown) {
        dialogShown = true;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AnnouncementDialog(id: id);
          },
        );
      }
    });
  }

  addUserActivity({required String activity}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      var res = await FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: user.uid)
          .get();
      if (res.docs.isNotEmpty) {
        String fname = res.docs[0].get('fname');
        String lname = res.docs[0].get('lname');
        String userimage = res.docs[0].get('profile');
        await FirebaseFirestore.instance.collection('UserActivities').add({
          "username": "$fname $lname",
          "userimage": userimage,
          "datetime": Timestamp.now(),
          "useraction": activity,
          "userRole": "user",
        });
      } else {
        await FirebaseFirestore.instance.collection('UserActivities').add({
          "username": user.email,
          "userimage":
              'https://firebasestorage.googleapis.com/v0/b/sk-app-56284.appspot.com/o/profilenew.jpg?alt=media&token=7ff9979b-9503-4b55-ae89-feb1065bdff2&_gl=1*1n7fjoj*_ga*MTgxNjUyOTc5NC4xNjk1MTAyOTYz*_ga_CW55HF8NVT*MTY5OTQzNTE4Ni4yMi4xLjE2OTk0MzU0MzcuNTQuMC4w',
          "datetime": Timestamp.now(),
          "useraction": activity,
          "userRole": "user",
        });
      }
    }
  }

  late String idFileName = '';

  late File idImageFile;

  late String idImageURL = '';
  Future<void> uploadImage(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

      idFileName = path.basename(pickedImage.path);
      idImageFile = File(pickedImage.path);

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

        var firebaseStorage;
        await firebaseStorage.FirebaseStorage.instance
            .ref('Document/$idFileName')
            .putFile(idImageFile);
        idImageURL = await firebaseStorage.FirebaseStorage.instance
            .ref('Document/$idFileName')
            .getDownloadURL();

        Navigator.of(context).pop();
        Navigator.of(context).pop();
        addActivityDialog(context, false, '', '');
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

  final box = GetStorage();

  bool hasLoaded = false;

  getUserData() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        box.write('role', doc['role']);
        box.write('fname', doc['fname']);
        box.write('mname', doc['mname']);
        box.write('lname', doc['lname']);
      }

      setState(() {
        hasLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    return hasLoaded
        ? Padding(
            padding: _currentIndex == 1
                ? EdgeInsets.zero
                : const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: _currentIndex == 1
                    ? EdgeInsets.zero
                    : const EdgeInsets.fromLTRB(2, 30, 2, 0),
                child: Stack(
                  children: [
                    Container(
                      height: 1000,
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(245, 199, 177, 100)),
                      child: Image.network(
                        'https://raw.githubusercontent.com/abuanwar072/Meditation-App/master/assets/images/undraw_pilates_gpdb.png',
                        height: 400,
                      ),
                    ),
                    _currentIndex == 1
                        ? Expanded(
                            child: _buildPage(_currentIndex),
                          )
                        : Column(
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Hello!',
                                        style: (Theme.of(context)
                                                .textTheme
                                                .displaySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color.fromARGB(
                                                      235, 38, 43, 123),
                                                )) ??
                                            const TextStyle(
                                                fontWeight: FontWeight.w200,
                                                color: Colors.indigo),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const InstructionsDialog();
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.info,
                                          color: Color.fromARGB(
                                              239, 185, 144, 124),
                                          size: 30,
                                        ),
                                      ),
                                      box.read('role') != 'Admin'
                                          ? IconButton(
                                              onPressed: () async {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const NotifPage(),
                                                  ),
                                                );
                                              },
                                              icon:
                                                  StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('Notif')
                                                    .snapshots(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapshot) {
                                                  if (snapshot.hasError) {
                                                    print(snapshot.error);
                                                    return const Center(
                                                        child: Text('Error'));
                                                  }
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 50),
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.indigo,
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  final data =
                                                      snapshot.requireData;
                                                  return Badge(
                                                    label: TextWidget(
                                                      text: data.docs.length
                                                          .toString(),
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                    child: const Icon(
                                                      Icons.notifications,
                                                      size: 30,
                                                      color: Color.fromARGB(
                                                          239, 185, 144, 124),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : const SizedBox(),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                'Logout Confirmation',
                                                style: TextStyle(
                                                  fontFamily: 'QBold',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: const Text(
                                                'Are you sure you want to Logout?',
                                                style: TextStyle(
                                                  fontFamily: 'QRegular',
                                                ),
                                              ),
                                              actions: <Widget>[
                                                MaterialButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text(
                                                    'Close',
                                                    style: TextStyle(
                                                      fontFamily: 'QRegular',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                MaterialButton(
                                                  onPressed: () async {
                                                    addUserActivity(
                                                        activity: "Logout");
                                                    await FirebaseAuth.instance
                                                        .signOut();
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            LoginScreen(),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Continue',
                                                    style: TextStyle(
                                                      fontFamily: 'QRegular',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.logout,
                                          color: Color.fromARGB(
                                              239, 185, 144, 124),
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              // BODY PAGE
                              Expanded(
                                child: _buildPage(_currentIndex),
                              ),
                            ],
                          ),
                    // You can add additional widgets to the Stack if needed
                  ],
                ),
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();
  DateTime? selectedDateTime; // To store the DateTime
  Timestamp? expirationDate; // To store the Timestamp

  addActivityDialog(context, bool inEdit, String id, String image) {
    if (!inEdit) {
      setState(() {
        nameController.clear();
        descController.clear();
      });
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(
            text: 'Posting Activities',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: SingleChildScrollView(
            // Wrap content in SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    uploadImage('gallery');
                  },
                  child: Container(
                    height: 150,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: idFileName == ''
                          ? null
                          : DecorationImage(
                              image: NetworkImage(
                                idImageURL,
                              ),
                              fit: BoxFit.cover),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldWidget(
                  label: 'Name of Activity',
                  controller: nameController,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldWidget(
                  label: 'Description of Activity',
                  controller: descController,
                  maxLine: 3, // Adjust the number of visible lines
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Date',
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        dateFromPicker(context);
                      },
                      child: SizedBox(
                        width: 325,
                        height: 50,
                        child: TextFormField(
                          enabled: false,
                          style: const TextStyle(
                            fontFamily: 'Regular',
                            fontSize: 14,
                            color: primary,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              Icons.calendar_month_outlined,
                              color: primary,
                            ),
                            hintStyle: const TextStyle(
                              fontFamily: 'Regular',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            hintText: dateController.text,
                            border: InputBorder.none,
                            disabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            errorStyle: const TextStyle(
                              fontFamily: 'Bold',
                              fontSize: 12,
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          controller: dateController,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: TextWidget(
                text: 'Close',
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {
                if (!isDateExpired(dateController.text)) {
                  if (inEdit) {
                    FirebaseFirestore.instance
                        .collection('Activities')
                        .doc(id)
                        .update({
                      'name': nameController.text,
                      'description': descController.text
                    });
                  } else {
                    addActivities(
                      idImageURL,
                      nameController.text,
                      descController.text,
                      dateController.text,
                      expirationDate as Timestamp,
                    );
                  }

                  Navigator.pop(context);
                } else {
                  // Show an error message for expired activities
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: TextWidget(
                        text: 'Error',
                        fontSize: 18,
                        fontFamily: 'Bold',
                      ),
                      content: TextWidget(
                        text:
                            'Selected date is expired. Please select a valid date.',
                        fontSize: 14,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: TextWidget(
                            text: 'OK',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: TextWidget(
                text: 'Post',
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }

  bool isDateExpired(String selectedDate) {
    DateTime currentDate = DateTime.now();
    DateTime selectedDateTime = DateTime.parse(selectedDate);
    return selectedDateTime.isBefore(currentDate);
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildSection([
          SizedBox(height: 10), // Add spacing at the top of the carousel

          Container(
            height: 300, // Adjust the height of the carousel as needed
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Activities')
                  .where('expirationDate',
                      isGreaterThanOrEqualTo: Timestamp.now())
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Center(child: Text('Error'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    ),
                  );
                }

                final data = snapshot.requireData;
                if (data.docs.isEmpty) {
                  return const Center(
                    child: Text('No activities available.'),
                  );
                }
                return Container(
                  height: 250,
                  child: CarouselSlider.builder(
                    itemCount: data.docs.length,
                    itemBuilder:
                        (BuildContext context, int index, int realIndex) {
                      Timestamp expirationDate =
                          data.docs[index]['expirationDate'];

                      // Check if the activity has not expired
                      if (expirationDate.toDate().isAfter(DateTime.now())) {
                        return Card(
                          child: Container(
                            width: 1000,
                            child: ListTile(
                              onTap: () {
                                if (box.read('role') == 'Admin') {
                                  setState(() {
                                    nameController.text =
                                        data.docs[index]['name'];
                                    descController.text =
                                        data.docs[index]['description'];
                                  });

                                  addActivityDialog(
                                    context,
                                    true,
                                    data.docs[index].id,
                                    data.docs[index]['imageUrl'],
                                  );
                                } else if (box.read('role') == 'User') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SpecificActivity(
                                        activityName: data.docs[index]['name'],
                                        activityDescription: data.docs[index]
                                            ['description'],
                                        imageUrl: data.docs[index]['imageUrl'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              contentPadding: EdgeInsets.all(16.0),
                              title: TextWidget(
                                text: data.docs[index]['name'],
                                fontSize: 18,
                                color: Colors.black,
                                fontFamily: 'Bold',
                              ),
                              subtitle: Column(
                                children: [
                                  if (data.docs[index]['imageUrl'] != null)
                                    Image.network(
                                      data.docs[index]['imageUrl'],
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                    ),
                                  const SizedBox(height: 8),
                                  TextWidget(
                                    text: data.docs[index]['description'],
                                    fontSize: 12,
                                    color: Colors.grey,
                                    maxLines: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Activity has expired, don't include it in the carousel
                        return SizedBox.shrink();
                      }
                    },
                    options: CarouselOptions(
                      height: 250,
                      viewportFraction: 0.8,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          _buildGridTile(
            context,
            'Announcements',
            'https://cdn-icons-png.flaticon.com/512/944/944948.png',
            const AnnouncementsPage(),
          ),
          _buildGridTile(
            context,
            'Services',
            'https://cdn-icons-png.flaticon.com/512/9186/9186535.png',
            const ServicesPage(),
          ),
          // ... other grid tiles
        ]);

      case 1:
        return const TabbarView();
      case 2:
        return GridView.count(
          crossAxisCount: 1,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          children: [
            _buildGridTile(
              context,
              'Activities',
              'https://cdn-icons-png.flaticon.com/512/6192/6192771.png',
              const ActivitiesPage(),
            ),

            // ... other grid tiles
          ],
        );
      case 3:
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          children: [
            _buildGridTile(
              context,
              'Survey',
              'https://cdn-icons-png.flaticon.com/512/10266/10266602.png',
              const SurveyPage(),
            ),
            _buildGridTile(
              context,
              'Help Desk',
              'https://cdn-icons-png.flaticon.com/512/5639/5639690.png?ga=GA1.1.472911080.1695727240',
              MainHelpdeskScreen(),
            ),
            // ... other grid tiles
          ],
        );
      case 4:
        return UserInfoDisplay();
      // ... other cases
      default:
        return const SizedBox.shrink();
    }
  }

  void dateFromPicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: primary,
                onPrimary: Colors.white,
                onSurface: Colors.grey,
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050));

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      setState(() {
        dateController.text = formattedDate;
      });
    } else {
      return null;
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home,
              color: Color.fromARGB(239, 235, 158, 120), size: 30),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.campaign_rounded,
            color: Color.fromARGB(239, 235, 158, 120),
            size: 30,
          ),
          label: 'Discover!',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_2_rounded,
              color: Color.fromARGB(239, 235, 158, 120), size: 30),
          label: 'Activity',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.class_outlined,
              color: Color.fromARGB(239, 235, 158, 120), size: 30),
          label: 'Forms',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box_rounded,
              color: Color.fromARGB(239, 235, 158, 120), size: 30),
          label: 'Account',
        ),
      ],
    );
  }

  Widget _buildGridTile(
      BuildContext context, String title, String imageUrl, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => page));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              text: title,
              fontSize: 17,
              color: Colors.black,
            ),
            const SizedBox(height: 10),
            Image.network(imageUrl, height: 50, width: 50),
          ],
        ),
      ),
    );
  }
}

Widget _buildSection(List<Widget> children) {
  return ListView(
    padding: const EdgeInsets.all(10.0),
    children: children,
  );
}
