import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sk_app/services/add_survey.dart';
import 'package:sk_app/widgets/toast_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/text_widget.dart';
import '../../widgets/textfield_widget.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  Map<String, String> surveyAnswers = {};

  final box = GetStorage();
  DateTime? selectedDateTime; // To store the DateTime
  Timestamp? expirationDate; // To store the Timestamp

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final linkController = TextEditingController();

  addSourveyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const TextWidget(
            text: 'Posting Survey',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                  label: 'Name of Survey', controller: nameController),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                  label: 'Description of Survey', controller: descController),
              const SizedBox(
                height: 20,
              ),
              TextFieldWidget(
                  label: 'Google Form Link', controller: linkController),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 1),
                  );

                  if (selectedDate != null) {
                    setState(() {
                      selectedDateTime = selectedDate;
                      expirationDate = Timestamp.fromDate(selectedDate);
                    });
                  }
                },
                child: const Text('Set Expiration Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const TextWidget(
                text: 'Close',
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {
                if (expirationDate != null) {
                  addSurvey(
                    nameController.text,
                    descController.text,
                    linkController.text,
                    Timestamp.fromDate(DateTime.now()),
                    expirationDate as Timestamp,
                  );
                  Navigator.pop(context);
                } else {
                  showToast('Please Enter Expiration Date');
                }
              },
              child: const TextWidget(
                text: 'Post',
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }

  showSurveyDialog(String name, String description, String link) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(
            text: name,
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: Container(
            padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    description,
                    textAlign: TextAlign.justify, // Justify the text
                    softWrap: true, // Enable line wrapping
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await launch(link);
                    } catch (e) {
                      showToast('Error launching the link');
                    }
                    Navigator.pop(
                        context); // Close the dialog after launching the link
                  },
                  child: const Text('Take the survey now'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: box.read('role') == 'Admin'
          ? FloatingActionButton(
              backgroundColor: const Color.fromRGBO(245, 199, 177, 100),
              onPressed: () {
                addSourveyDialog();
              },
              child: const Icon(Icons.add),
            )
          : null,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 199, 177, 100),
        title: const TextWidget(
          text: 'Survey',
          fontSize: 18,
          color: Colors.white,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Surveys').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
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
          final surveys = data.docs.where((doc) {
            final dataMap = doc.data() as Map<String, dynamic>;

            if (dataMap.containsKey('expirationDate')) {
              final expirationDate = dataMap['expirationDate'] as Timestamp;
              final currentTime = Timestamp.now();

              return expirationDate.toDate().isAfter(currentTime.toDate());
            } else {
              return true;
            }
          }).toList();

          return ListView.builder(
            itemCount: surveys.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  child: SizedBox(
                    height: 75,
                    child: ListTile(
                      onTap: () {
                        showSurveyDialog(
                          surveys[index]['name'],
                          surveys[index]['description'],
                          surveys[index]['link'],
                        );
                      },
                      title: TextWidget(
                        text: surveys[index]['name'],
                        fontSize: 18,
                        color: Colors.black,
                        fontFamily: 'Bold',
                      ),
                      subtitle: TextWidget(
                        text: surveys[index]['description'],
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      trailing: const Icon(
                        Icons.open_in_browser,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
