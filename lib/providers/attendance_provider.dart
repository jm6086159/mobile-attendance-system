import 'package:flutter/foundation.dart';
import '../models/attendance_record.dart';
import '../services/api_service.dart';

class AttendanceProvider with ChangeNotifier {
  List<AttendanceRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  List<AttendanceRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> refresh({
    required String token,
    String? email,
    String? empCode,
    DateTime? from,
    DateTime? to,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if ((email == null || email.isEmpty) && (empCode == null || empCode.isEmpty)) {
        _records = [];
        _error = 'No employee identity found. Please sign in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      final list = await ApiService.getAttendanceRecords(
        token: token,
        email: email,
        empCode: empCode,
        from: from,
        to: to,
      );
      _records = list;
    } catch (e) {
      _error = 'Failed to fetch attendance: $e';
    }
    _isLoading = false;
    notifyListeners();
  }
}
