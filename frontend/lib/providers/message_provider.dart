import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MessageProvider with ChangeNotifier {
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _selectedUser;

  List<Map<String, dynamic>> get conversations => _conversations;
  List<Map<String, dynamic>> get messages => _messages;
  Map<String, dynamic>? get selectedUser => _selectedUser;

  Future<void> loadConversations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/conversations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _conversations = List<Map<String, dynamic>>.from(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
  }

  Future<void> loadMessages(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/messages/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _messages = List<Map<String, dynamic>>.from(data['messages']);
        _selectedUser = data['user'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  void addMessage(Map<String, dynamic> message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _selectedUser = null;
    notifyListeners();
  }
}
