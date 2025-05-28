import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manga_catalog_app/providers/global_state.dart';
import 'package:manga_catalog_app/screens/manga_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import 'add_manga_page.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recentlyViewed = GlobalAppState().recentlyViewedManga;
    return Center(
      child: Column(
        children: [
          Text(
            'User Page',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'User: ${Provider.of<GlobalAppState>(context).uid}',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Role: ${Provider.of<GlobalAppState>(context).role}',
            style: TextStyle(color: Colors.white),
          ),
          ElevatedButton(
            onPressed: signOut,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.grey[800]),
            ),
            child: Text('Sign out', style: TextStyle(color: Colors.white)),
          ),
          if (GlobalAppState().uid != null)
            ElevatedButton(
              onPressed: () => downloadBookmarks(GlobalAppState().uid ?? ''),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.grey[800]),
              ),
              child: Text(
                'Download bookmarks',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (GlobalAppState().role == 'admin' ||
              GlobalAppState().role == 'editor')
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMangaPage()),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.grey[800]),
              ),
              child: Text('Add manga', style: TextStyle(color: Colors.white)),
            ),
          if (recentlyViewed.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No history records.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            Expanded(
              // Используй Expanded, если ListView находится внутри Column
              child: ListView.builder(
                itemCount: recentlyViewed.length,
                itemBuilder: (context, index) {
                  final manga = recentlyViewed[index];
                  final visitOrder =
                      index + 1; // Номер порядка посещения (1 - самое недавнее)

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Row(
                        mainAxisSize:
                            MainAxisSize.min, // Чтобы Row занимал минимум места
                        children: [
                          Text(
                            '$visitOrder.',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 50, // Фиксированная ширина для изображения
                            height: 70, // Фиксированная высота для изображения
                            child:
                                manga.imageUrl.isNotEmpty
                                    ? Image.network(
                                      manga.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        );
                                      },
                                      loadingBuilder: (
                                        BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                          ),
                                        );
                                      },
                                    )
                                    : const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                    ),
                          ),
                        ],
                      ),
                      title: Text(
                        manga.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(manga.author),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MangaPage(manga: manga),
                          ),
                        );
                        print('Нажата манга: ${manga.title}');
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> signOut() async {
  FirebaseAuth.instance.signOut();
  GlobalAppState().signOut();
}

Future<void> downloadBookmarks(String uid) async {
  // Получаем закладки пользователя
  final bookmarksSnapshot =
      await FirebaseFirestore.instance.collection('bookmark').doc(uid).get();

  if (bookmarksSnapshot.exists) {
    final data = bookmarksSnapshot.data();
    final List<String> mangaIds = List<String>.from(data!['mangaIds'] ?? []);

    // Формируем текст для сохранения в файл
    StringBuffer content = StringBuffer();
    content.writeln('uid: $uid');
    content.writeln('bookmarks:');
    content.writeln('[');

    // Получаем информацию о каждой манге
    for (String mangaId in mangaIds) {
      final mangaSnapshot =
          await FirebaseFirestore.instance
              .collection('manga')
              .doc(mangaId)
              .get();

      if (mangaSnapshot.exists) {
        final mangaData = mangaSnapshot.data();
        content.writeln('  $mangaId: {');
        content.writeln('    title: ${mangaData!['title']},');
        content.writeln('    author: ${mangaData['author']},');
        content.writeln('    rate: ${mangaData['rate']},');
        content.writeln('    views: ${mangaData['views']},');
        content.writeln('    description: ${mangaData['description']},');
        content.writeln('  },');
      }
    }

    content.writeln(']');

    // Получаем путь к папке Downloads
    final directory = await getExternalStorageDirectory();
    final downloadsPath = directory?.path ?? '';
    final filePath = p.join(downloadsPath, 'bookmarks_$uid.txt');

    // Создаем файл и записываем данные
    final file = File(filePath);
    await file.writeAsString(content.toString());

    print('Bookmarks downloaded to: $filePath');
  } else {
    print('No bookmarks found for user: $uid');
  }
}
