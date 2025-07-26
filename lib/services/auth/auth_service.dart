import 'package:cloud_firestore/cloud_firestore.dart'; // Импорт для Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Импорт для Authentication
import 'package:flutter/material.dart'; // Может быть не строго необходим, но часто используется

class AuthService extends ChangeNotifier { // ChangeNotifier для уведомления слушателей об изменениях
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Экземпляр Firestore

  // Получить текущего пользователя
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Вход в систему
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Регистрация нового пользователя
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Сохраняем информацию о новом пользователе в Firestore
      // Document ID должен быть равен UID пользователя из Authentication
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'createdAt': Timestamp.now(), // Используем Timestamp для времени создания
        // Можно добавить другие поля, например 'username', 'profileImageUrl'
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Выход из системы
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}