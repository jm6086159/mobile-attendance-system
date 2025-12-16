import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/attendance_record.dart';

class ApiService {
  static Future<Map<String, dynamic>> login({String? email, String? empCode, required String password}) async {
    final uri = Uri.parse(ApiConfig.baseUrl + ApiConfig.login);
    final body = jsonEncode({
      if (email != null && email.isNotEmpty) 'email': email,
      if (empCode != null && empCode.isNotEmpty) 'emp_code': empCode,
      'password': password,
    });

    try {
      final res = await http
          .post(uri, headers: {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.acceptHeader: 'application/json'}, body: body)
          .timeout(const Duration(seconds: 20));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return (data is Map<String, dynamic>) ? data : {'success': false, 'message': 'Unexpected response'};
      }
      return {'success': false, 'message': 'Login failed (${res.statusCode})'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<List<AttendanceRecord>> getAttendanceRecords({
    required String token,
    String? email,
    String? empCode,
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, String>{
      if (email != null && email.isNotEmpty) 'email': email,
      if (empCode != null && empCode.isNotEmpty) 'emp_code': empCode,
      if (from != null) 'from': from.toIso8601String().substring(0, 10),
      if (to != null) 'to': to.toIso8601String().substring(0, 10),
    };
    final uri = Uri.parse(ApiConfig.baseUrl + ApiConfig.attendance).replace(queryParameters: params.isEmpty ? null : params);
    final res = await http
        .get(uri, headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        })
        .timeout(const Duration(seconds: 20));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      // Strongly cast to avoid dart2js JSArray<dynamic> issues on web
      final List<Map<String, dynamic>> arr = decoded is List
          ? (decoded as List).cast<Map<String, dynamic>>()
          : (decoded is Map && decoded['data'] is List)
              ? (decoded['data'] as List).cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[];
      return arr.map((m) => AttendanceRecord.fromJson(m)).toList();
        }
    if (res.statusCode == 404) {
      // Treat 'Employee not found' as no data rather than a hard error
      return <AttendanceRecord>[];
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}



