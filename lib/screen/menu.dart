import 'package:flutter/material.dart';
import 'explore.dart';
import 'homepage.dart';
import 'scannerpage.dart';
import 'profilepage.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 4; // Default index for Menu

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget destination;
    if (index == 0) {
      destination = HomePage();
    } else if (index == 1) {
      destination = ExplorePage();
    } else if (index == 2) {
      destination = ScannerPage();
    } else if (index == 3) {
      destination = ProfilePage();
    } else {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100], // Set background color
      appBar: AppBar(
        backgroundColor: Colors.yellow[300],
        elevation: 0,
        title: Text("Menu", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Profile Icon
          Container(
            padding: EdgeInsets.all(20),
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
            ),
          ),

          // Menu Options
          Expanded(
            child: ListView(
              children: [
                menuItem("Settings"),
                menuItem("Special offers"),
                menuItem("Reading goals"),
                menuItem("Import & Export"),
                menuItem("Terms and privacy policy"),
                menuItem("Translators"),
                menuItem("Contact us"),
                menuItem("FAQs"),
                menuItem("Support us"),
                menuItem("Follow us"),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.yellow[800],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 40), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
      ),
    );
  }

  // Widget for Menu Item
  Widget menuItem(String title, {bool showProTag = false}) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: showProTag
          ? Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "PRO",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      )
          : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // You can add navigation logic here for each menu item
        print("$title clicked");
      },
    );
  }
}
