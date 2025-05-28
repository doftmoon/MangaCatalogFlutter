import 'package:flutter/cupertino.dart';

import '../core/models/manga.dart';

class GlobalAppState extends ChangeNotifier {
  static final GlobalAppState _instance = GlobalAppState._internal();

  factory GlobalAppState() {
    return _instance;
  }

  GlobalAppState._internal();
  String? _uid;
  String? _role;

  String? get uid => _uid;
  String? get role => _role;

  final List<Manga> recentlyViewedManga = [];
  static const int _maxRecentlyViewed = 5;

  void setUid(String uid) {
    _uid = uid;
    notifyListeners();
  }

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  void addMangaToRecentlyViewed(Manga manga) {
    // 1. Удаляем эту мангу, если она уже есть в списке, чтобы избежать дубликатов
    //    и чтобы она переместилась в начало как самая последняя.
    recentlyViewedManga.removeWhere((item) => item.id == manga.id);

    // 2. Добавляем мангу в начало списка (самая недавняя)
    recentlyViewedManga.insert(0, manga);

    // 3. Если список превышает максимальный размер, удаляем самый старый элемент
    if (recentlyViewedManga.length > _maxRecentlyViewed) {
      recentlyViewedManga.removeLast();
    }

    // 4. Уведомляем слушателей об изменениях
    notifyListeners();

    // Опционально: здесь можно было бы сохранять этот список в SharedPreferences
    // или в Firestore для пользователя, чтобы он сохранялся между сессиями.
    // Пока что он будет храниться только в памяти приложения.
    print(
      "Недавно просмотренные: ${recentlyViewedManga.map((m) => m.title).toList()}",
    );
  }

  void signOut() {
    _uid = null;
    _role = null;
    recentlyViewedManga.clear();
    notifyListeners();
  }
}
