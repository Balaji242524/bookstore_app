# BookShelf App 📚

A Flutter-based mobile application that allows users to explore books, add books to their personal shelf, track reading progress, rate books, and manage a wishlist. The app integrates with Firebase for authentication and Firestore for data storage.

## Features ✨
- **Explore Books**: Browse books from an API and view details.
- **Book Shelf**: Add books to a personal shelf and track progress.
- **Wishlist**: Save books for future reading.
- **Book Details**: View title, author, publisher, publish date, ISBN, price, and availability.
- **User Authentication**: Sign in with Firebase Authentication.
- **Cloud Storage**: Store and retrieve book data from Firebase Firestore.

## Screens 📱
- **Home Page**: Displays books added to the shelf with options to delete.
- **Explore Page**: Fetches books from an external API.
- **Book Details Page**: Shows detailed information about a selected book.
- **Wishlist Page**: Manages books added to the wishlist.
- **Profile Page**: Displays user information.

## Installation 🛠️
1. Clone the repository:
   ```sh
   git clone https://github.com/Balaji242524/bookstore_app.git
   cd bookshelf-app
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Setup Firebase:
    - Create a Firebase project.
    - Enable Firestore Database and Authentication.
    - Download the `google-services.json` file and place it in `android/app/`.
4. Run the app:
   ```sh
   flutter run
   ```

## Firebase Firestore Structure 🔥
```
Firestore Database
|
|-- shelfBooks (Collection)
|   |-- {bookId} (Document)
|       |-- title: String
|       |-- authors: String
|       |-- publisher: String
|       |-- publishDate: String
|       |-- ISBN: String
|       |-- price: Double
|       |-- forSale: Boolean
|       |-- userId: String
|       |-- timestamp: Timestamp
|
|-- wishlist (Collection)
|   |-- {bookId} (Document)
|       |-- title: String
|       |-- authors: String
|       |-- userId: String
```

## Dependencies 📦
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: latest
  firebase_auth: latest
  cloud_firestore: latest
```
---
Developed with ❤️ using Flutter & Firebase.

