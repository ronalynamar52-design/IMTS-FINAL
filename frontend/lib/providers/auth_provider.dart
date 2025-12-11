import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as UserModel;

class AuthProvider with ChangeNotifier {
  UserModel.User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  final List<Map<String, dynamic>> _registeredUsers = [];

  UserModel.User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Check if user already exists
      final existingUser = _registeredUsers.firstWhere(
        (user) => user['email'] == userData['email'],
        orElse: () => {},
      );

      if (existingUser.isNotEmpty) {
        _error = 'Email already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Mock registration - in real app this would make API call
      final newUserData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'id_number': userData['id_number'],
        'email': userData['email'],
        'name': userData['name'],
        'department': userData['department'],
        'role': userData['role'],
        'phone': userData['phone'],
        'password': userData['password'], // In real app, this would be hashed
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'last_login': null,
      };

      // Store registered user
      _registeredUsers.add(newUserData);

      // Save registered users to shared preferences for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registered_users', json.encode(_registeredUsers));

      debugPrint('User registered: ${userData['email']} as ${userData['role']}');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password, String? role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      if (role == null) {
        _error = 'Please select your role';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Load registered users from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final registeredUsersJson = prefs.getString('registered_users');
      if (registeredUsersJson != null) {
        _registeredUsers.clear();
        _registeredUsers.addAll(List<Map<String, dynamic>>.from(json.decode(registeredUsersJson)));
      }

      // Find user by email
      final registeredUser = _registeredUsers.firstWhere(
        (user) => user['email'] == email,
        orElse: () => {},
      );

      if (registeredUser.isEmpty) {
        _error = 'Account not found. Please register first.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verify password (in real app, this would be hashed comparison)
      if (registeredUser['password'] != password) {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verify role matches registered role
      if (registeredUser['role'] != role) {
        final registeredRole = registeredUser['role'];
        final roleLabels = {
          'student': 'Student',
          'coordinator': 'Coordinator',
          'supervisor': 'Supervisor',
          'admin': 'Administrator',
        };
        _error = 'Email registered as ${roleLabels[registeredRole] ?? registeredRole}. Please select the correct role.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create user session
      final userData = Map<String, dynamic>.from(registeredUser);
      userData['last_login'] = DateTime.now().toIso8601String();

      _user = UserModel.User.fromJson(userData);
      _token = 'mock_jwt_token_${_user!.id}';

      // Save current user to shared preferences
      await prefs.setString('user', json.encode(userData));
      await prefs.setString('token', _token!);

      // Update registered user data
      final userIndex = _registeredUsers.indexWhere((user) => user['email'] == email);
      if (userIndex != -1) {
        _registeredUsers[userIndex] = userData;
        await prefs.setString('registered_users', json.encode(_registeredUsers));
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final token = prefs.getString('token');

    if (userJson != null && token != null) {
      final userData = json.decode(userJson);
      _user = UserModel.User.fromJson(userData);
      _token = token;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Update user data
      final updatedData = Map<String, dynamic>.from(_user!.toJson())..addAll(updates);
      _user = UserModel.User.fromJson(updatedData);

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(updatedData));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load registered users from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final registeredUsersJson = prefs.getString('registered_users');
      if (registeredUsersJson != null) {
        _registeredUsers.clear();
        _registeredUsers.addAll(List<Map<String, dynamic>>.from(json.decode(registeredUsersJson)));
      }

      // Find current user in registered users
      final userEmail = _user?.email;
      final registeredUser = _registeredUsers.firstWhere(
        (user) => user['email'] == userEmail,
        orElse: () => {},
      );

      if (registeredUser.isEmpty) {
        _error = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verify current password
      if (registeredUser['password'] != currentPassword) {
        _error = 'Current password is incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Update password
      registeredUser['password'] = newPassword;

      // Save updated registered users
      final userIndex = _registeredUsers.indexWhere((user) => user['email'] == userEmail);
      if (userIndex != -1) {
        _registeredUsers[userIndex] = registeredUser;
        await prefs.setString('registered_users', json.encode(_registeredUsers));
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to change password: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Clear user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('token');

      _user = null;
      _token = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
