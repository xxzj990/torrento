import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class Session {
  Future<http.Response> get(String url, {Map<String, String> headers});

  Future<http.Response> post(String url, {Map<String, String> headers, Map<String, dynamic> body, Encoding encoding});

  Future<http.StreamedResponse> postMulti(String url, Map<String, dynamic> fields, List<http.MultipartFile> files);
}
