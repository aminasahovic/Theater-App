import 'dart:convert';

import 'package:etheater_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredstavaProvider with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "Predstava";
  PredstavaProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5241/",
    );
  }
  Future<dynamic> get() async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    var data = jsonDecode(response.body);
    return data;
  }

  bool isValidResponse(Respone response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Unauthorize");
    } else {
      throw new Exception("ERR");
    }
  }

  Map<String, String> createHeaders() {
    String username = Authorization.username ?? "";
    String password = Authorization.password ?? "";
    print(username);

    String basicAuth =
        "Basic ${base64Encode(utf8.encode(("$username:$password")))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
    return headers;
  }
}
