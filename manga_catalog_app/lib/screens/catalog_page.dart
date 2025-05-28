import 'package:flutter/material.dart';
import 'package:manga_catalog_app/screens/manga_page.dart';
import 'package:manga_catalog_app/widgets/manga_catalog_card.dart';

import '../core/models/manga.dart';
import '../services/firestore_service.dart';
import '../widgets/filters_drawer.dart';
import '../widgets/manga_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String? selectedType;
  List<String> selectedTags = [];
  double? selectedRate;
  String? searchTitle;
  bool isFilterVisible = false;

  List<String> types = ['Manga', 'Manhua', 'Manhwa', 'Other']; // Пример типов
  List<String> tags = [
    'Adventure',
    'Comedy',
    'Fantasy',
    'Imba',
  ]; // Пример тегов

  void _applyFilters() {
    setState(() {
      isFilterVisible = false; // Скрыть фильтры после применения
    });
  }

  void _resetFilters() {
    setState(() {
      selectedType = null;
      selectedTags.clear();
      selectedRate = null;
      searchTitle = null;
    });
    // Логика для сброса фильтров, если необходимо
  }

  @override
  Widget build(BuildContext context) {
    var crossAxisCount = 3;

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
                  child: Text(
                    'Search',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFilterVisible =
                          !isFilterVisible; // Переключение видимости фильтров
                    }); // Открытие Drawer
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
                  child: Text(
                    'Filters',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
          if (isFilterVisible)
            CompactFilterWidget(
              types: types,
              tags: tags,
              onTypeSelected: (String? type) {
                setState(() {
                  selectedType = type;
                });
              },
              onTagsSelected: (List<String> tags) {
                setState(() {
                  selectedTags = tags;
                });
              },
              stags: selectedTags,
              onRateSelected: (double? rate) {
                setState(() {
                  selectedRate = rate;
                });
              },
              onTitleChanged: (String? title) {
                setState(() {
                  searchTitle = title;
                });
              },
              onApply: _applyFilters,
              onReset: _resetFilters,
            ),
          FutureBuilder<List<Manga>>(
            future: fetchManga(),
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

              List<Manga> filteredMangas =
                  mangas.where((manga) {
                    bool matchesType =
                        selectedType == null || manga.type == selectedType;
                    bool matchesRate =
                        selectedRate == null || manga.rate >= selectedRate!;
                    bool matchesTags =
                        selectedTags.isEmpty ||
                        selectedTags.any((tag) => manga.tags.contains(tag));
                    bool matchesTitle =
                        searchTitle == null ||
                        manga.title.toLowerCase().contains(
                          searchTitle!.toLowerCase(),
                        );

                    return matchesType &&
                        matchesRate &&
                        matchesTags &&
                        matchesTitle;
                  }).toList();

              return SizedBox(
                height: 600,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Количество столбцов
                    childAspectRatio: 0.7, // Соотношение сторон карточки
                  ),
                  itemCount: filteredMangas.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Переход на новый экран MangaPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    MangaPage(manga: filteredMangas[index]),
                          ),
                        );
                      },
                      child: Card(
                        child: Column(
                          children: [
                            Image.network(
                              filteredMangas[index].imageUrl,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                filteredMangas[index].title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(filteredMangas[index].author),
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
      ),
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

Future<List<Manga>> fetchManga() async {
  //QuerySnapshot snapshot =
  //    await FirebaseFirestore.instance.collection('manga').get();
  //return snapshot.docs.map((doc) => Manga.fromFirestore(doc)).toList();
  return await readManga();
}

class MangaGrid extends StatelessWidget {
  final List<Manga> mangas;

  const MangaGrid({super.key, required this.mangas});

  @override
  Widget build(BuildContext context) {
    print(mangas.length);
    return Container(
      height: 400,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Количество колонок
          childAspectRatio: 0.7, // Соотношение сторон карточки
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: mangas.length,
        itemBuilder: (context, index) {
          return MangaCard(manga: mangas[index]);
        },
      ),
    );
  }
}
