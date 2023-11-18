import 'package:flutter/material.dart';
import 'package:sk_app/screens/pages/crowdsourcing_page.dart';
import 'package:sk_app/screens/pages/crowdsourcingstatus_page.dart';
import 'package:sk_app/screens/pages/crowsourcingdetails_page.dart';

class TabbarView extends StatefulWidget {
  const TabbarView({super.key});

  @override
  State<TabbarView> createState() => _TabbarViewState();
}

class _TabbarViewState extends State<TabbarView> {
  final upperTab = const TabBar(indicatorColor: Colors.white, tabs: <Tab>[
    Tab(
      icon: Icon(Icons.person),
      text: "Sources",
    ),
    Tab(
      icon: Icon(Icons.list),
      text: "Results",
    ),
    Tab(
      icon: Icon(Icons.badge),
      text: "Status",
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Crowd Sourcing"),
          backgroundColor: Color.fromARGB(255, 20, 20, 20),
          bottom: upperTab,
        ),
        body: const TabBarView(
          children: [
            CroudsourcingPage(),
            CrowSourcingDetailsPage(),
            CrowSourcingStatusPage(),
          ],
        ),
      ),
    );
  }
}
