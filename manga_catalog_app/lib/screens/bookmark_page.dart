import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manga_catalog_app/providers/global_state.dart';
import 'package:provider/provider.dart';

import '../core/models/manga.dart';
import '../widgets/manga_catalog_card.dart';
import 'manga_page.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    var crossAxisCount = 3;
    var userId = Provider.of<GlobalAppState>(context, listen: false).uid;

    return Column(
      children: [
        Text(
          'Your bookmarks',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 32),
        FutureBuilder<List<Manga>>(
          future: fetchBookmark(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('No data', style: TextStyle(color: Colors.white)),
              );
            }

            List<Manga> mangas = snapshot.data!;
            return SizedBox(
              height: 600,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Количество столбцов
                  childAspectRatio: 0.7, // Соотношение сторон карточки
                ),
                itemCount: mangas.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Переход на новый экран MangaPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MangaPage(manga: mangas[index]),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Image.network(
                            mangas[index].imageUrl,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              mangas[index].title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(mangas[index].author),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class MangaCards extends StatelessWidget {
  const MangaCards({super.key, required String item});

  @override
  Widget build(BuildContext context) {
    return MangaCardCatalog();
  }
}

Future<List<Manga>> fetchBookmark(String? userId) async {
  if (userId == null) {
    return [];
  }

  List<String> mangaIds = await getMangaIdsFromBookmarks(userId);
  return await readMangaByIds(mangaIds);
}

Future<List<String>> getMangaIdsFromBookmarks(String userId) async {
  final docSnapshot =
      await FirebaseFirestore.instance.collection('bookmark').doc(userId).get();

  if (docSnapshot.exists) {
    return List<String>.from(docSnapshot.data()?['mangaIds'] ?? []);
  }

  return [];
}

Future<List<Manga>> readMangaByIds(List<String> mangaIds) async {
  if (mangaIds.isEmpty) {
    return [];
  }

  try {
    List<Manga> mangas = [];
    for (String mangaId in mangaIds) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('manga')
              .doc(mangaId)
              .get();
      if (doc.exists) {
        mangas.add(Manga.fromFirestore(doc));
      }
    }
    return mangas;
  } catch (e) {
    print('Error reading manga: $e');
    return [];
  }
}
