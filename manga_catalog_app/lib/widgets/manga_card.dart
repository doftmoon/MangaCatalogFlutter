import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/models/manga.dart';

class MangaCard extends StatelessWidget {
  final Manga manga;

  const MangaCard({Key? key, required this.manga}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(manga.imageUrl, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              manga.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Автор: ${manga.author}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Рейтинг: ${manga.rate}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Просмотры: ${manga.views}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              manga.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 6,
              children:
                  manga.tags.map((tag) {
                    return Chip(label: Text(tag));
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
