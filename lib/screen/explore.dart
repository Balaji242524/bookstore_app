import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';
import 'scannerpage.dart';
import 'profilepage.dart';
import 'menu.dart';
import 'book_details_page.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int _selectedIndex = 1;
  List<dynamic> books = [];
  bool isLoading = false;
  bool hasError = false;
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchBooks("Best seller");
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      fetchBooks(searchController.text);
    });
  }

  Future<void> fetchBooks(String query) async {
    if (query.isEmpty) return;
    final url = "https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=40";

    setState(() {
      isLoading = true;
      hasError = false;
      books.clear();
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          books = data['items'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load books");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print("Error fetching books: $e");
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget destination;
    if (index == 0) {
      destination = HomePage();
    } else if (index == 2) {
      destination = ScannerPage();
    } else if (index == 3) {
      destination = ProfilePage();
    } else if (index == 4) {
      destination = MenuPage();
    } else {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  void _navigateToBookDetails(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(book: book, ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore Books!"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by title, author, or ISBN...",
                //TextColorMaterial: MaterialStateProperty.all(Colors.grey),
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                      books.clear();
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
          ? Center(child: Text("Failed to load books. Please try again."))
          : books.isEmpty
          ? Center(child: Text("No books available."))
          : ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index]['volumeInfo'] ?? {};
          final String title = book['title'] ?? "Unknown Title";
          final String authors = book['authors'] != null
              ? (book['authors'] as List).join(', ')
              : "Unknown Author";
          final String? imageUrl = book['imageLinks']?['thumbnail'];

          return GestureDetector(
            onTap: () => _navigateToBookDetails(books[index]),
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: imageUrl != null
                    ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.book, size: 50),
                title: Text(title),
                subtitle: Text(authors),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.yellow[800],
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 40), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
      ),
    );
  }
}
