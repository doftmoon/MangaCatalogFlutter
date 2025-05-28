import 'package:cloud_firestore/cloud_firestore.dart';

class Manga {
  String id;
  String title;
  String imageUrl; // URL изображения или путь к локальному файлу
  String author;
  double rate;
  int views;
  String description;
  String type;
  List<String> tags;

  Manga({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.rate,
    required this.views,
    required this.description,
    required this.type,
    required this.tags,
  });

  factory Manga.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    print((data['tags'] as List<dynamic>).map((e) => e.toString()).toList());
    return Manga(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      author: data['author'] ?? '',
      rate: data['rate'] ?? '',
      views: data['views'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      tags:
          (data['tags'] as List<dynamic>).map((e) => e.toString()).toList() ??
          [],
    );
  }
}
