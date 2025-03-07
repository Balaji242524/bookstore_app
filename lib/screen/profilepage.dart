import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart'; // Import HomePage

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String name = "Enter your name!";
  String bio = "Book lover | Avid reader | Flutter enthusiast";
  String profilePicUrl = "https://www.w3schools.com/howto/img_avatar.png"; // Default avatar

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  void _getUserDetails() {
    _user = _auth.currentUser;
    if (_user != null) {
      setState(() {
        name = _user!.displayName ?? "Enter your name!";
      });
    }
  }

  void _editProfile() {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController bioController = TextEditingController(text: bio);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  hintText: "Enter your name!",
                ),
              ),
              TextField(
                controller: bioController,
                decoration: InputDecoration(labelText: "Bio"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  name = nameController.text;
                  bio = bioController.text;
                });

                // Update Firebase Auth profile name
                if (_user != null) {
                  await _user!.updateDisplayName(name);
                  await _user!.reload();
                  _getUserDetails();
                }

                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pop(context); // Go back to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100], // Background color
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.yellow[300], // Changed AppBar color
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ); // Navigate back to HomePage
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profilePicUrl),
              ),
              SizedBox(height: 15),
              Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(_user?.email ?? "No email found", style: TextStyle(fontSize: 16, color: Colors.grey)),
              SizedBox(height: 10),
              Text(bio, style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout),
                label: Text("Logout", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
