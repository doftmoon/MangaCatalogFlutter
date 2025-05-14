import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/bookmark_page.dart';
import 'screens/catalog_page.dart';
import 'screens/user_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Catalog(),
    );
  }
}

class Catalog extends StatefulWidget {
  const Catalog({super.key});

  @override
  State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = CatalogPage();
      case 1:
        page = BookmarkPage();
      case 2:
        page = UserPage();
      default:
        throw UnimplementedError('no widget');
    }

    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.list_alt), label: 'Catalog'),
            NavigationDestination(
              icon: Icon(Icons.bookmarks_rounded),
              label: 'Bookmarks',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle),
              label: 'Me',
            ),
          ],
          selectedIndex: selectedIndex,
          onDestinationSelected:
              (int index) => {
                setState(() {
                  selectedIndex = index;
                }),
              },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          backgroundColor: Colors.black,
        ),
        body: Expanded(child: Container(color: Colors.black45, child: page)),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}
