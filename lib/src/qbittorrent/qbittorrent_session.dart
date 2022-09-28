import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:torrento/src/qbittorrent/qbittorrent_interface/qbittorrent_session.dart';

const timeout = 30; //s

///Singleton Session class to handle cookies
class Session implements IQbitTorrentSession {
  Map<String, String> sessionHeaders = {}; //'content-type': 'application/x-www-form-urlencoded; charset=utf-8'

  String? proxyHost;

  String get proxy {
    if (proxyHost != null && proxyHost!.isNotEmpty) {
      if (proxyHost!.endsWith('/')) {
        return proxyHost!.substring(0, proxyHost!.length - 1);
      } else {
        return proxyHost!;
      }
    }
    return '';
  }

  @override
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    http.Response response;
    if (proxy.isNotEmpty) {
      var proxyBody = {'url': Uri.encodeFull(url)};
      response = await http.post(Uri.parse('${proxy}/api/request'), body: json.encode(proxyBody), headers: sessionHeaders).timeout(Duration(seconds: timeout));
    } else {
      response = await http.get(Uri.parse(url), headers: sessionHeaders).timeout(Duration(seconds: timeout));
    }
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
    http.Response response;
    if (proxy.isNotEmpty) {
      var proxyBody = {'url': Uri.encodeFull(url), 'body': copyBody};
      response = await http.post(Uri.parse('${proxy}/api/request'), body: json.encode(proxyBody), headers: sessionHeaders, encoding: encoding).timeout(Duration(seconds: timeout));
    } else {
      response = await http.post(Uri.parse(url), body: copyBody, headers: sessionHeaders, encoding: encoding).timeout(Duration(seconds: timeout));
    }
    _updateCookie(response);
    return response;
  }

  @override
  Future<http.StreamedResponse> postMulti(String url, Map<String, dynamic> fields, List<http.MultipartFile> files) async {
    http.MultipartRequest request;
    if (proxy.isNotEmpty) {
      request = http.MultipartRequest('POST', Uri.parse('${proxy}/api/request/multi'));
      request.fields['url'] = Uri.encodeFull(url);
    } else {
      request = http.MultipartRequest('POST', Uri.parse(url));
    }

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
    var response = await request.send().timeout(Duration(seconds: timeout));
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
