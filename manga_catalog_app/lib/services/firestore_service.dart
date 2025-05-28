import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/models/manga.dart';

Future<void> createManga({
  required String title,
  String? imageUrl,
  String? author,
  double? rate,
  int? views,
  String? description,
  String? type,
  List<String>? tags,
}) async {
  try {
    await FirebaseFirestore.instance.collection('manga').add({
      'id': FirebaseFirestore.instance.collection('manga').doc().id,
      'title': title,
      'imageUrl':
          imageUrl ??
          'https://github.com/doftmoon/mangaCovers/blob/master/manga.jpg?raw=true', // Значение по умолчанию
      'author': author ?? 'Unknown',
      'rate': rate ?? 0.0,
      'views': views ?? 0,
      'description': description ?? 'No description provided.',
      'type': type ?? 'Manga',
      'tags': tags ?? [],
    });
  } catch (e) {
    print('Error creating manga: $e');
  }
}

// Чтение всех манг
Future<List<Manga>> readManga() async {
  try {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('manga').get();
    print('Manga count: ${snapshot.docs.length}');
    return snapshot.docs.map((doc) => Manga.fromFirestore(doc)).toList();
  } catch (e) {
    print('Error reading manga: $e');
    return [];
  }
}

// Обновление манги по ID
Future<void> updateManga({
  required String id,
  String? title,
  String? imageUrl,
  String? author,
  double? rate,
  int? views,
  String? description,
  List<String>? tags,
}) async {
  try {
    await FirebaseFirestore.instance.collection('manga').doc(id).update({
      if (title != null) 'title': title,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (author != null) 'author': author,
      if (rate != null) 'rate': rate,
      if (views != null) 'views': views,
      if (description != null) 'description': description,
      if (tags != null) 'tags': tags,
    });
  } catch (e) {
    print('Error updating manga: $e');
  }
}

// Удаление манги по ID
Future<void> deleteManga(String id) async {
  try {
    await FirebaseFirestore.instance.collection('manga').doc(id).delete();
  } catch (e) {
    print('Error deleting manga: $e');
  }
}

Future<void> createBookmark(String userId) async {
  final docRef = FirebaseFirestore.instance.collection('bookmark').doc(userId);
  final docSnapshot = await docRef.get();

  if (!docSnapshot.exists) {
    await docRef.set({'mangaIds': []});
  }
}

Future<List<String>> getBookmarks(String userId) async {
  final docSnapshot =
      await FirebaseFirestore.instance.collection('bookmark').doc(userId).get();
  if (docSnapshot.exists) {
    return List<String>.from(docSnapshot.data()?['mangaIds'] ?? []);
  }
  return [];
}

// Update
Future<void> updateBookmark(String userId, String mangaId) async {
  final docRef = FirebaseFirestore.instance.collection('bookmark').doc(userId);
  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    List<String> mangaIds = List<String>.from(
      docSnapshot.data()?['mangaIds'] ?? [],
    );

    if (mangaIds.contains(mangaId)) {
      // Удалить mangaId
      mangaIds.remove(mangaId);
    } else {
      // Добавить mangaId
      mangaIds.add(mangaId);
    }

    await docRef.update({'mangaIds': mangaIds});
  }
}

class CommentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'comment';

  // Create a comment
  Future<void> addComment(String uid, String mangaId, String text) async {
    await _db.collection(collectionPath).add({
      'id': FirebaseFirestore.instance.collection(collectionPath).doc().id,
      'uid': uid,
      'mangaId': mangaId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(), // Для сортировки
    });
  }

  // Read comments for a specific manga
  Future<List<Map<String, dynamic>>> getComments(String mangaId) async {
    QuerySnapshot snapshot =
        await _db
            .collection(collectionPath)
            .where('mangaId', isEqualTo: mangaId)
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'uid': data['uid'],
        'mangaId': data['mangaId'],
        'text': data['text'],
        'timestamp': data['timestamp'],
      };
    }).toList();
  }

  // Update a comment
  Future<void> updateComment(String commentId, String newText) async {
    await _db.collection(collectionPath).doc(commentId).update({
      'text': newText,
    });
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    await _db.collection(collectionPath).doc(commentId).delete();
  }
}
