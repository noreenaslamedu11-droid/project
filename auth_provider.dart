import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart' as user_model;

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Current logged-in user
  firebase_auth.User? get user => _auth.currentUser;
  user_model.User? _user;
  user_model.User? get currentUser => _user;

  AuthProvider() {
    _loadUserFromLocal();
  }

  // LOGIN method - FAST VERSION
  Future<void> signIn(String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create basic user object immediately
      _user = user_model.User(
        id: userCredential.user!.uid,
        email: email,
        role: 'Student', // Default role, will be updated from local/Firebase
        name: '',
        phone: '',
        profilePictureUrl: '',
      );

      // Save basic user to local storage immediately
      await _saveUserToLocal(_user!);
      notifyListeners();

      // Fetch complete user data from Firebase in background (don't await)
      _fetchUserDataInBackground(userCredential.user!.uid);

    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Background method to fetch complete user data
  Future<void> _fetchUserDataInBackground(String uid) async {
    try {
      DatabaseEvent snapshot = await _database.ref('users/$uid').once();
      Map<dynamic, dynamic>? data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        _user = user_model.User.fromMap(uid, Map<String, dynamic>.from(data));
      }

      // Update local storage with complete data
      await _saveUserToLocal(_user!);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching user data in background: $e");
      // Keep the basic user data if Firebase fetch fails
    }
  }

  // SIGNUP method
  Future<void> signUp(String email, String password, String role) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Realtime Database
      await _database
          .ref('users/${userCredential.user!.uid}')
          .set({
        'email': email,
        'role': role,
        'name': '',
        'phone': '',
        'profilePictureUrl': '',
      });

      _user = user_model.User(
        id: userCredential.user!.uid,
        email: email,
        role: role,
        name: '',
        phone: '',
        profilePictureUrl: '',
      );

      // Save to local storage
      await _saveUserToLocal(_user!);

      notifyListeners();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // LOGOUT method
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    await _clearUserFromLocal();
    notifyListeners();
  }

  // GET ROLE method
  Future<String?> getRole() async {
    if (_user == null) return null;
    return _user!.role;
  }

  Future<void> updateUserProfile(String name, String phone, String profilePictureUrl) async {
    try {
      if (_user != null) {
        await FirebaseDatabase.instance.ref('users/${_user!.id}').update({
          'name': name,
          'phone': phone,
          'profilePictureUrl': profilePictureUrl,
        });

        _user = user_model.User(
          id: _user!.id,
          email: _user!.email,
          role: _user!.role,
          name: name,
          phone: phone,
          profilePictureUrl: profilePictureUrl,
        );

        // Save to local storage
        await _saveUserToLocal(_user!);

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating user profile: $e");
      rethrow;
    }
  }

  // Local storage methods
  Future<void> _saveUserToLocal(user_model.User user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('user', userJson);
  }

  Future<void> _loadUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      _user = user_model.User.fromJson(userMap);
      notifyListeners();
    }
  }

  Future<void> _clearUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}
