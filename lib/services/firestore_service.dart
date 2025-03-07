import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Adds a book to the Firestore "books" collection
  Future<void> addBookToFirestore(Map<String, dynamic> book) async {
    try {
      await _db.collection('books').add({
        'title': book['volumeInfo']['title'] ?? 'Unknown Title',
        'authors': book['volumeInfo']['authors'] ?? ['Unknown Author'],
        'imageUrl': book['volumeInfo']['imageLinks']?['thumbnail'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Book added successfully!");
    } catch (e) {
      print("Error adding book: $e");
    }
  }

  /// Fetches all books from Firestore
  Stream<QuerySnapshot> getBooksStream() {
    return _db.collection('books').orderBy('timestamp', descending: true).snapshots();
  }
}
