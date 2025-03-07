import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'explore.dart';
import 'scannerpage.dart';
import 'menu.dart';
import 'profilepage.dart';
import 'book_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deleteBook(String bookId) async {
    await FirebaseFirestore.instance.collection('shelf').doc(bookId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        backgroundColor: Colors.yellow[300],
        elevation: 0,
        title: Center(
          child: Image.asset('assets/shelf-banner.png', height: 70),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.blue[900],
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: "Books"),
            Tab(text: "Shelves"),
            Tab(text: "Ratings"),
            Tab(text: "Wishlist"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBooksTab(),
          const Center(child: Text("Shelves Tab")),
          const Center(child: Text("Ratings Tab")),
          _buildWishlistTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.yellow[800],
        backgroundColor: Colors.yellow[300],
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 40), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
      ),
    );
  }

  Widget _buildBooksTab() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('shelf')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyShelf();
        }

        final books = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final bookData = book.data() as Map<String, dynamic>;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: Image.network(
                  bookData['volumeInfo']['imageLinks']?['thumbnail'] ?? 'https://via.placeholder.com/128x192.png?text=No+Image',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(bookData['volumeInfo']['title'] ?? "Unknown Title", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(bookData['volumeInfo']['authors']?[0] ?? "Unknown Author"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBook(book.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailsPage(book: bookData),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWishlistTab() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Your wishlist is empty.", style: TextStyle(color: Colors.grey)));
        }

        final wishlistBooks = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: wishlistBooks.length,
          itemBuilder: (context, index) {
            final book = wishlistBooks[index];
            final bookData = book.data() as Map<String, dynamic>;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: Image.network(
                  bookData['volumeInfo']['imageLinks']?['thumbnail'] ?? 'https://via.placeholder.com/128x192.png?text=No+Image',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(bookData['volumeInfo']['title'] ?? "Unknown Title", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(bookData['volumeInfo']['authors']?[0] ?? "Unknown Author"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeFromWishlist(book.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailsPage(book: bookData),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _removeFromWishlist(String bookId) async {
    await FirebaseFirestore.instance.collection('wishlist').doc(bookId).delete();
  }

  Widget _buildEmptyShelf() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/empty-shelf1.jpg', width: 200),
          const SizedBox(height: 20),
          const Text("Your shelf is empty", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExplorePage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ScannerPage()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
    } else if (index == 4) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MenuPage()));
    }
  }
}
