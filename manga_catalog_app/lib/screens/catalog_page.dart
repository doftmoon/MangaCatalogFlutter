import 'package:flutter/material.dart';
import 'package:manga_catalog_app/widgets/manga_catalog_card.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    var crossAxisCount = 3;
    final List<String> items = List.generate(20, (index) => 'item $index');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ElevatedButton(onPressed: () {}, child: Text('fafaf')),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(onPressed: () {}, child: Text('dadad')),
            ),
          ],
        ),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return MangaCards(item: items[index]);
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
