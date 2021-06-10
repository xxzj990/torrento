import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:torrento/src/qbittorrent/qbittorrent_interface/qbittorrent_session.dart';

///Singleton Session class to handle cookies
class Session implements IQbitTorrentSession {
  Map<String, String> sessionHeaders = {};

  @override
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    /// headers receives as per the headers arg is sent to the API>
    http.Response response = await http.get(Uri.parse(url), headers: sessionHeaders);
    _updateCookie(response);
    //log('status : ${response.statusCode} , response body : ' + response.body);
    return response;
  }

  @override
  Future<http.Response> post(String url, {Map<String, String>? headers, Map<String, dynamic>? body, Encoding encoding = const Utf8Codec()}) async {
    body?.keys.forEach((key) {
      if (body[key] == null) {
        body.remove(key);
      } else {
        body[key] = body[key].toString();
      }
    });

    http.Response response = await http.post(Uri.parse(url), body: body, headers: sessionHeaders);
    //log('status : ${response.statusCode} , response body : ' + response.body);
    _updateCookie(response);
    return response;
  }

  void _updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      sessionHeaders['cookie'] = (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}
