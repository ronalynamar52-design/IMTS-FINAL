import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class AttendanceProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _attendanceLogs = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get attendanceLogs => _attendanceLogs;

  Future<bool> submitDailyLog({
    required String date,
    required String timeIn,
    required String timeOut,
    required String logText,
    PlatformFile? file,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock submission - in real app this would make API call
      final logEntry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'date': date,
        'time_in': timeIn,
        'time_out': timeOut,
        'log_text': logText,
        'file_name': file?.name,
        'submitted_at': DateTime.now().toIso8601String(),
      };

      _attendanceLogs.add(logEntry);
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

  Future<List<Map<String, dynamic>>> fetchAttendanceLogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - in real app this would fetch from API
      _attendanceLogs = [
        {
          'id': '1',
          'date': '2024-12-10',
          'time_in': '09:00',
          'time_out': '17:30',
          'log_text': 'Regular working day',
          'file_name': null,
        }
      ];

      _isLoading = false;
      notifyListeners();
      return _attendanceLogs;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
