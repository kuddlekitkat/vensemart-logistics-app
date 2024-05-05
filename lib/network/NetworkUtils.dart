import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import '../utils/Extensions/app_common.dart';
import '../main.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import 'RestApis.dart';

Map<String, String> buildHeaderTokens() {
  Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader: 'no-cache',
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
  };
  if (appStore.isLoggedIn) {
    header.putIfAbsent(HttpHeaders.authorizationHeader,
        () => 'Bearer ${sharedPref.getString(TOKEN)}');
  }
  log(jsonEncode(header));
  return header;
}

Uri buildBaseUrl(String endPoint) {
  Uri url = Uri.parse(endPoint);
  if (!endPoint.startsWith('http')) url = Uri.parse('$mBaseUrl$endPoint');

  log('URL: ${url.toString()}');

  return url;
}

Future<Response> buildHttpResponse(String endPoint,
    {HttpMethod method = HttpMethod.GET, Map? request}) async {
  if (await isNetworkAvailable()) {
    var headers = buildHeaderTokens();
    Uri url = buildBaseUrl(endPoint);

    // print('Header:${headers.toString()}');

    try {
      Response response;

      if (method == HttpMethod.POST) {
        // log('Request: $request');
        response = await http
            .post(
              url,
              headers: headers,
              body: json.encode(request),
            )
            .timeout(Duration(seconds: 20), onTimeout: () => throw 'Timeout');
        // print('Response: ${response.body}');
      } else if (method == HttpMethod.DELETE) {
        response = await delete(url, headers: headers)
            .timeout(Duration(seconds: 20), onTimeout: () => throw 'Timeout');
      } else if (method == HttpMethod.PUT) {
        response = await put(url, body: jsonEncode(request), headers: headers)
            .timeout(Duration(seconds: 20), onTimeout: () => throw 'Timeout');
      } else {
        response = await get(url, headers: headers)
            .timeout(Duration(seconds: 20), onTimeout: () => throw 'Timeout');
      }

      // print("Response: $response");

      // log('Response ($method): ${url.toString()} ${response.statusCode} ${response.body}');

      return response;
    } catch (e) {
      throw 'Something Went Wrong';
    }
  } else {
    throw 'Your internet is not working';
  }
}

//region Common

Future handleResponse(Response response, [bool? avoidTokenError]) async {
  if (!await isNetworkAvailable()) {
    throw 'Your internet is not working';
  }
  if (response.statusCode == 401) {
    if (appStore.isLoggedIn) {
      Map req = {
        'email': sharedPref.getString(USER_EMAIL),
        'password': sharedPref.getString(USER_PASSWORD),
      };

      await logInApi(req).then((value) {
        // throw 'Please try again.';
        // logout
        logout();
      }).catchError((e) {
        logout();
        throw TokenException(e);
      });
    } else {
      throw '';
    }
  }

  if (response.statusCode == 200) {
    var body = json.decode(response.body);
    if (body['status'] == 0) {
      toast(body['message'] ?? 'Something Went Wrong');
    } else {
      return body;
    }
    // return json.decode(response.body);
  } else {
    try {
      var body = json.decode(response.body);
      print(body);
      // throw parseHtmlString(body['message']);
    } on Exception catch (e) {
      log(e);
      throw 'Something Went Wrong';
    }
  }
}

enum HttpMethod { GET, POST, DELETE, PUT }

class TokenException implements Exception {
  final String message;

  const TokenException([this.message = ""]);

  String toString() => "FormatException: $message";
}
