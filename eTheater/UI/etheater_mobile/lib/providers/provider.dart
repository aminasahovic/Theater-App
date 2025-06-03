import 'dart:convert';
import 'package:etheater_mobile/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Provider {
  static String? _baseUrl;
  Provider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5241/",
    );
  }

  Future<dynamic> get() async {
    var url = "${_baseUrl}Glumac";
    var uri = Uri.parse(url);
    print("url:::::: $url");
    var response = await http.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw new Exception("Unknow exception");
    }
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Unathorized");
    } else {
      throw new Exception("Something bad happeend, please try again!");
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username!;
    String password = AuthProvider.password!;

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    return headers;
  }
}
