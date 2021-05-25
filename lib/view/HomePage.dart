import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:green_heart/view/ActivityView.dart';
import 'package:green_heart/view/HistoryView.dart';
import 'package:green_heart/view/ProfileView.dart';
import 'package:green_heart/view/RecipeFeed/RecipeFeedView.dart';
import 'package:green_heart/view/SettingsView.dart';

class HomePageView extends StatefulWidget {
  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  int _currentIndex = 0;

  List<Widget> _children = [
    RecipeFeedView(),
    ActivityView(),
    ProfileView(),
    HistoryView(),
    SettingsView()
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              elevation: 0.0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Text("Test", style: TextStyle(color: Color(0xFF2D2F30)))),
      backgroundColor: Colors.white,
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 20.0,
        fixedColor: Color(0xFF36DC55),
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.house_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.stacked_line_chart_rounded), label: "Activity"),
          BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
        ],
      ),
    );
  }
}
