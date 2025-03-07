import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailsPage({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool isBookInShelf = false;
  bool isBookInWishlist = false;
  double rating = 0;
  double pagesRead = 0;
  String? shelfDocId;
  String? wishlistDocId;

  @override
  void initState() {
    super.initState();
    _checkBookStatus();
  }

  void _checkBookStatus() async {
    final shelfQuery = await FirebaseFirestore.instance
        .collection('shelf')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: widget.book['id'])
        .get();
    if (shelfQuery.docs.isNotEmpty) {
      setState(() {
        isBookInShelf = true;
        shelfDocId = shelfQuery.docs.first.id;
      });
    }
    final wishlistQuery = await FirebaseFirestore.instance
        .collection('wishlist')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: widget.book['id'])
        .get();
    if (wishlistQuery.docs.isNotEmpty) {
      setState(() {
        isBookInWishlist = true;
        wishlistDocId = wishlistQuery.docs.first.id;
      });
    }
  }

  void _toggleShelf() async {
    if (isBookInShelf) {
      await FirebaseFirestore.instance.collection('shelf').doc(shelfDocId).delete();
      setState(() {
        isBookInShelf = false;
        shelfDocId = null;
      });
    } else {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('shelf').add({
        'userId': userId,
        'bookId': widget.book['id'],
        'volumeInfo': widget.book['volumeInfo'],
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        isBookInShelf = true;
        shelfDocId = docRef.id;
      });
    }
  }

  void _toggleWishlist() async {
    if (isBookInWishlist) {
      await FirebaseFirestore.instance.collection('wishlist').doc(wishlistDocId).delete();
      setState(() {
        isBookInWishlist = false;
        wishlistDocId = null;
      });
    } else {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('wishlist').add({
        'userId': userId,
        'bookId': widget.book['id'],
        'volumeInfo': widget.book['volumeInfo'],
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        isBookInWishlist = true;
        wishlistDocId = docRef.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookInfo = widget.book['volumeInfo'] ?? {};

    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        backgroundColor: Colors.yellow[300],
        title: Text(bookInfo['title'] ?? 'Book Details',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              bookInfo['imageLinks']?['thumbnail'] ??
                  'https://via.placeholder.com/128x192.png?text=No+Image',
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(bookInfo['title'] ?? "Unknown Title",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(bookInfo['authors']?.join(", ") ?? "Unknown Author",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text("Publisher: ${bookInfo['publisher'] ?? 'Unknown'}"),
            Text("Published Date: ${bookInfo['publishedDate'] ?? 'N/A'}"),
            Text("Price: ${bookInfo['saleInfo']?['listPrice']?['amount'] ?? 'N/A'}"),
            Text("For Sale: ${bookInfo['saleInfo']?['isEbook'] == true ? 'Yes' : 'No'}"),
            Text("ISBN: ${bookInfo['industryIdentifiers']?[0]['identifier'] ?? 'N/A'}"),
            const SizedBox(height: 16),
            Text(bookInfo['description'] ?? "No description available.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black)),
            const SizedBox(height: 16),
            Slider(
              value: pagesRead,
              min: 0,
              max: (bookInfo['pageCount'] ?? 100).toDouble(),
              divisions: bookInfo['pageCount'] ?? 100,
              label: "Pages Read: ${pagesRead.toInt()}",
              onChanged: (value) {
                setState(() {
                  pagesRead = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                );
              }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isBookInShelf ? Icons.library_add_check : Icons.library_add,
                    color: isBookInShelf ? Colors.green : Colors.grey,
                  ),
                  onPressed: _toggleShelf,
                ),
                IconButton(
                  icon: Icon(
                    isBookInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isBookInWishlist ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleWishlist,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
