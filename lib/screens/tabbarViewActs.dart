import 'package:flutter/material.dart';
import 'package:sk_app/screens/pages/activities_page.dart';
import 'package:sk_app/screens/pages/helpdesk/evaluate_activities.dart';

class TabbarViewActs extends StatefulWidget {
  const TabbarViewActs({super.key});

  @override
  State<TabbarViewActs> createState() => _TabbarViewActsState();
}

class _TabbarViewActsState extends State<TabbarViewActs> {
  final upperTab = const TabBar(
    indicatorColor: Color.fromARGB(255, 255, 255, 255),
    labelColor: Color.fromARGB(255, 255, 255, 255), // Selected tab text color
    unselectedLabelColor: Colors.white, // Unselected tab text color
    tabs: <Tab>[
      Tab(
        icon: Icon(Icons.list),
        text: "Activities",
      ),
      Tab(
        icon: Icon(Icons.list),
        text: "Evaluate",
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Activity",
            style:
                TextStyle(color: Colors.white), // Set your desired title color
          ),
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          bottom: upperTab,
        ),
        body: const TabBarView(
          children: [
            ActivitiesPage(),
            EvaluateActivities(),
          ],
        ),
      ),
    );
  }
}
