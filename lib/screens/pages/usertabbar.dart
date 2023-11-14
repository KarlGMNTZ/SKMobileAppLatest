import 'package:flutter/material.dart';
import 'package:sk_app/screens/pages/crowdsourcingstatus_page.dart';
import 'package:sk_app/screens/pages/crowsourcingdetails_page.dart';
import 'package:sk_app/screens/pages/helpdeskstatus_page.dart';
import 'package:sk_app/screens/pages/user_activities_evaluated.dart';
import 'package:sk_app/screens/pages/user_activities_joined.dart';
import 'package:sk_app/screens/pages/user_helpdesk_submitted.dart';

class UsertabView extends StatefulWidget {
  const UsertabView({super.key});

  @override
  State<UsertabView> createState() => _UsertabViewState();
}

class _UsertabViewState extends State<UsertabView> {
  final upperTab = const TabBar(indicatorColor: Colors.white, tabs: <Tab>[
    Tab(
      icon: Icon(Icons.person),
      text: "Activity Joined",
    ),
    Tab(
      icon: Icon(Icons.list),
      text: "Helpdesk",
    ),
    Tab(
      icon: Icon(Icons.badge),
      text: "Evaluation",
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Your Engagements"),
          backgroundColor: const Color.fromARGB(255, 247, 218, 202),
          bottom: upperTab,
        ),
        body: const TabBarView(
          children: [
            ActivitiesJoined(),
            HelpDeskSubmitted(),
            ActivitiesEvaluated(),
          ],
        ),
      ),
    );
  }
}
