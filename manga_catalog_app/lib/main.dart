import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:manga_catalog_app/firebase_options.dart';
import 'package:manga_catalog_app/providers/global_state.dart';
import 'package:manga_catalog_app/screens/login_page.dart';
import 'package:provider/provider.dart';

import 'screens/bookmark_page.dart';
import 'screens/catalog_page.dart';
import 'screens/user_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalAppState(),
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
      title: 'Manga Catalog',
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
        page = AuthWrapper(page: BookmarkPage());
      case 2:
        page = AuthWrapper(page: UserPage());
      default:
        throw UnimplementedError('no widget');
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black26,
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
          backgroundColor: Colors.black54,
        ),
        body: Expanded(child: Container(child: page)),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key, required this.page});

  final Widget page;

  @override
  Widget build(BuildContext context) {
    print(GlobalAppState().uid);
    if (GlobalAppState().uid == null) {
      return AuthAsker();
    } else {
      return page;
    }
  }
}

class AuthAsker extends StatelessWidget {
  const AuthAsker({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You haven\'t signed in yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => LoginPage()),
              ); // Используем Navigator для перехода на страницу логина
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
            ),
            child: Text(
              'Sign in',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
