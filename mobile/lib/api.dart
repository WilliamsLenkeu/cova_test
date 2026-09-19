import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8080',
);

const _tokenKey = 'jwt';

class Api {
  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
  }

  Future<void> _persistToken(String value) async {
    token = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, value);
  }

  Future<void> logout() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final encoded = body == null ? null : jsonEncode(body);
    final res = switch (method) {
      'POST' => await http.post(uri, headers: _headers, body: encoded),
      'PUT' => await http.put(uri, headers: _headers, body: encoded),
      'DELETE' => await http.delete(uri, headers: _headers),
      _ => await http.get(uri, headers: _headers),
    };
    final data = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(data is Map ? (data['message'] ?? res.statusCode) : res.statusCode);
    }
    return data;
  }

  Future<void> _auth(String path, Map<String, String> body) async {
    final data = await _send('POST', path, body);
    await _persistToken(data['token'] as String);
  }

  Future<void> login(String email, String password) => _auth('/api/auth/login', {
        'email': email,
        'password': password,
      });

  Future<void> register(String name, String email, String password) =>
      _auth('/api/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });

  Future<List<dynamic>> tasks({String? status, String? q}) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (q != null && q.trim().isNotEmpty) params['q'] = q.trim();
    final qs = params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
    return await _send('GET', '/api/tasks$qs') as List<dynamic>;
  }

  Future<void> create(String title, String description, String status) async {
    await _send('POST', '/api/tasks', {
      'title': title,
      'description': description,
      'status': status,
    });
  }

  Future<void> update(int id, String title, String description, String status) async {
    await _send('PUT', '/api/tasks/$id', {
      'title': title,
      'description': description,
      'status': status,
    });
  }

  Future<void> delete(int id) async {
    await _send('DELETE', '/api/tasks/$id');
  }
}
