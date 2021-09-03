import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:torrento/src/qbittorrent/qbittorrent_interface/qbittorrent_session.dart';

///Singleton Session class to handle cookies
class Session implements IQbitTorrentSession {
  Map<String, String> sessionHeaders = {}; //'content-type': 'application/x-www-form-urlencoded; charset=utf-8'

  @override
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    var proxyBody = {'url': Uri.encodeFull(url)};

    http.Response response = await http.post(Uri.parse('http://localhost:8080/request'), body: json.encode(proxyBody), headers: sessionHeaders);
    _updateCookie(response);
    return response;
  }

  @override
  Future<http.Response> post(String url, {Map<String, String>? headers, Map<String, dynamic>? body, Encoding encoding = const Utf8Codec()}) async {
    Map<String, dynamic> copyBody = {};
    body?.keys.forEach((key) {
      if (body[key] != null) {
        copyBody[key] = body[key].toString();
      }
    });

    var proxyBody = {'url': Uri.encodeFull(url), 'body': copyBody};

    http.Response response = await http.post(Uri.parse('http://localhost:8080/request'), body: json.encode(proxyBody), headers: sessionHeaders, encoding: encoding);
    _updateCookie(response);
    return response;
  }

  @override
  Future<http.StreamedResponse> postMulti(String url, Map<String, dynamic> fields, List<http.MultipartFile> files) async {

    var request = http.MultipartRequest('POST', Uri.parse('http://localhost:8080/requestMulti'));
    request.fields['url'] = Uri.encodeFull(url);

    //var request = http.MultipartRequest('POST', Uri.parse(url));
    if (fields.isNotEmpty) {
      fields.forEach((key, value) {
        request.fields[key] = '$value';
      });
    }
    if (files.isNotEmpty) {
      files.forEach((element) {
        request.files.add(element);
      });
    }
    request.headers.addAll(sessionHeaders);
    var response = await request.send();
    _updateCookie2(response);
    return response;
  }


  void _updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      sessionHeaders['cookie'] = (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  void _updateCookie2(http.StreamedResponse response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      sessionHeaders['cookie'] = (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}
