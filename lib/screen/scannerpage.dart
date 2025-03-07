import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String scannedResult = "";
  bool isLoading = false;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> fetchBookDetails(String isbn) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0) {
          final book = data['items'][0]['volumeInfo'];
          final bookDetails = {
            'title': book['title'],
            'author': book['authors']?.join(', '),
            'cover': book['imageLinks']?['thumbnail'],
            'description': book['description'],
            'isbn': isbn,
          };

          // Navigate back with the book details
          Navigator.pop(context, bookDetails);
          return;
        }
      }
    } catch (e) {
      print('Error fetching book details: $e');
    }

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch book details')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Book Barcode"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String barcode = barcodes.first.rawValue ?? "";
                  setState(() {
                    scannedResult = barcode;
                  });

                  // Fetch book details using the scanned ISBN
                  fetchBookDetails(barcode);
                }
              },
              errorBuilder: (context, error, child) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      Text(
                        'Failed to load camera',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            width: double.infinity,
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text(
                scannedResult.isEmpty ? "Scan a barcode" : "Scanned: $scannedResult",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
