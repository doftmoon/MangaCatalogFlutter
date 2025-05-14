import 'package:flutter/material.dart';

class MangaCardCatalog extends StatelessWidget {
  const MangaCardCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.asset('boxer.jpg'),
          SizedBox(height: 8),
          Text('Type'),
          Text('Title'),
          Row(),
        ],
      ),
    );
  }
}
