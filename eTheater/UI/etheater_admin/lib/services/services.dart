import 'dart:convert';
import 'package:etheater_admin/core/api_konstante.dart';
import 'package:etheater_admin/models/models.dart'
    show
        Glumac,
        GlumacPredstava,
        GlumacPredstavaInsert,
        KorisniciInsert,
        Korisnik,
        Predstava,
        PredstavaInsert,
        Reziser,
        TipKorisnika,
        Zanr;
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

  Future<List<Korisnik>> getKorisnici({int page = 1, int pageSize = 10}) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/Korisnik?Page=$page&PageSize=$pageSize',
    );
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> list = decoded['resultList'];
      return list.map((e) => Korisnik.fromJson(e)).toList();
    } else {
      throw Exception('Greška prilikom dohvaćanja korisnika.');
    }
  }

  static Future<int> dodajPredstavu(PredstavaInsert predstava) async {
    final response = await http.post(
      Uri.parse('${ApiKonstante.baseUrl}/Predstava'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: json.encode(predstava.toJson()),
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri dodavanju predstave');
    }

    final decoded = json.decode(response.body);
    return decoded['id']; // ili zamijeni sa stvarnim ključem ako se zove drugačije
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

  static Future<void> updatePredstava(Predstava predstava) async {
    final response = await http.put(
      Uri.parse('${ApiKonstante.baseUrl}/Predstava/${predstava.id}'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: json.encode(predstava.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška pri ažuriranju predstave');
    }
  }

  Future<List<TipKorisnika>> getTipoviKorisnika() async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/TipKorisnika');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> list = decoded['resultList'];
      return list.map((e) => TipKorisnika.fromJson(e)).toList();
    } else {
      throw Exception('Greška pri dohvaćanju tipova korisnika.');
    }
  }

  static Future<void> dodajKorisnika(KorisniciInsert korisnik) async {
    final response = await http.post(
      Uri.parse('${ApiKonstante.baseUrl}/Korisnik'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(korisnik.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Greška pri dodavanju korisnika: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<void> obrisiKorisnika(int korisnikId) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/Korisnik/$korisnikId'),
      headers: _headers,
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri brisanju predstave');
    }
  }

  Future<(List<Korisnik>, int)> getKorisniciFiltered({
    String? ime,
    String? prezime,
    String? username,
    int? tipKorisnikaId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams = {
      if (ime != null && ime.isNotEmpty) 'ImeGTE': ime,
      if (prezime != null && prezime.isNotEmpty) 'PrezimeGTE': prezime,
      if (username != null && username.isNotEmpty) 'UsernameGTE': username,
      if (tipKorisnikaId != null) 'IsTipKorisnika': tipKorisnikaId.toString(),
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Korisnik',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> list = decoded['resultList'];
      final int count = decoded['count'] ?? 0;

      final korisnici = list.map((e) => Korisnik.fromJson(e)).toList();
      return (korisnici, count);
    } else {
      throw Exception('Greška prilikom dohvaćanja korisnika.');
    }
  }

  Future<void> updateKorisnik(int id, KorisniciInsert korisnik) async {
    final response = await http.put(
      Uri.parse('${ApiKonstante.baseUrl}/Korisnici/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(korisnik.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška prilikom ažuriranja korisnika');
    }
  }

  static Future<List<Glumac>> fetchGlumci() async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/Glumac');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> list = decoded['resultList'];
      return list.map((e) => Glumac.fromJson(e)).toList();
    } else {
      throw Exception('Greška pri dohvatu glumaca');
    }
  }

  static Future<void> dodajGlumcaPredstavi(
    GlumacPredstavaInsert glumacPredstava,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiKonstante.baseUrl}/GlumacPredstava'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: json.encode(glumacPredstava.toJson()),
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri dodavanju glumca predstavi');
    }
  }

  static Future<List<GlumacPredstava>> fetchGlumciZaPredstavu(
    int predstavaId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiKonstante.baseUrl}/GlumacPredstava/predstava/$predstavaId/glumci',
      ),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => GlumacPredstava.fromJson(e)).toList();
    } else {
      throw Exception('Greška prilikom dohvaćanja glumaca za predstavu');
    }
  }
}
