import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:manga_catalog_app/services/firestore_service.dart';

Future<String?> registerUser(String email, String password) async {
  try {
    fb_auth.UserCredential userCredential = await fb_auth.FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // Записываем информацию о пользователе в Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .set({
          'uid': userCredential.user?.uid,
          'role': 'user', // Базовая роль
        });

    createBookmark(userCredential.user?.uid ?? '');
    return userCredential.user?.uid; // Возвращаем UID
  } catch (e) {
    print(e); // Обработка ошибок
    return null;
  }
}

Future<Map<String, dynamic>?> signInUser(String email, String password) async {
  try {
    fb_auth.UserCredential userCredential = await fb_auth.FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    // Получаем роль пользователя из Firestore
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

    if (userDoc.exists) {
      return {'uid': userCredential.user?.uid, 'role': userDoc['role']};
    }

    return null;
  } catch (e) {
    print(e); // Обработка ошибок
    return null;
  }
}
