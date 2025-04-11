import 'dart:convert';
import 'package:etheater_admin/core/api_konstante.dart';
import 'package:etheater_admin/models/models.dart'
    show Predstava, PredstavaInsert, Reziser, Zanr;
import 'package:http/http.dart' as http;

class ApiService {
  static const _headers = {
    'accept': 'text/plain',
    'Authorization': 'Basic aHVzZWluOmh1c2Vpbg==',
  };
  Future<List<Predstava>> getPredstave() async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/Predstava');
    final response = await http.get(url, headers: {'accept': 'text/plain'});

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> list = decoded['resultList'];
      return list.map((e) => Predstava.fromJson(e)).toList();
    } else {
      throw Exception('Greška prilikom dohvaćanja podataka.');
    }
  }

  static Future<void> dodajPredstavu(PredstavaInsert predstava) async {
    final response = await http.post(
      Uri.parse('${ApiKonstante.baseUrl}/Predstava'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: json.encode(predstava.toJson()),
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri dodavanju predstave');
    }
  }

  static Future<List<Zanr>> fetchZanrovi() async {
    final response = await http.get(
      Uri.parse('${ApiKonstante.baseUrl}/Zanr'),
      headers: _headers,
    );
    final data = json.decode(response.body);
    return (data['resultList'] as List).map((z) => Zanr.fromJson(z)).toList();
  }

  static Future<List<Reziser>> fetchReziseri() async {
    final response = await http.get(
      Uri.parse('${ApiKonstante.baseUrl}/Reziser'),
      headers: _headers,
    );
    final data = json.decode(response.body);
    return (data['resultList'] as List)
        .map((r) => Reziser.fromJson(r))
        .toList();
  }

  static Future<void> deletePredstava(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/Predstava/$id'),
      headers: _headers,
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri brisanju predstave');
    }
  }
}
