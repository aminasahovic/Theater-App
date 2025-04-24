import 'dart:convert';
import 'package:etheater_admin/core/api_konstante.dart';
import 'package:etheater_admin/models/models.dart'
    show
        Glumac,
        GlumacPredstava,
        GlumacPredstavaInsert,
        InsertGlumac,
        InsertNovosti,
        InsertReziser,
        KorisniciInsert,
        Korisnik,
        Obavijest,
        Predstava,
        PredstavaInsert,
        Reziser,
        TipKorisnika,
        UpdateNovosti,
        Zanr;
import 'package:etheater_admin/providers/auth_providers.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Map<String, String> _createHeaders() {
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

  Future<int?> getKorisnikId() async {
    final username = AuthProvider.username!;
    final password = AuthProvider.password!;

    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/Korisnik/login?username=$username&password=$password',
    );

    final response = await http.post(url, headers: {'accept': 'text/plain'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id']; // ili data["id"]
    } else {
      print('Greška prilikom dohvata ID-a: ${response.statusCode}');
      return null;
    }
  }

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
    final response = await http.get(url, headers: _createHeaders());

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
      headers: {..._createHeaders(), 'Content-Type': 'application/json'},
      body: json.encode(predstava.toJson()),
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri dodavanju predstave');
    }

    final decoded = json.decode(response.body);
    return decoded['id'];
  }

  static Future<List<Zanr>> fetchZanrovi() async {
    final response = await http.get(
      Uri.parse('${ApiKonstante.baseUrl}/Zanr'),
      headers: ApiService._createHeaders(),
    );
    final data = json.decode(response.body);
    return (data['resultList'] as List).map((z) => Zanr.fromJson(z)).toList();
  }

  static Future<List<Reziser>> fetchReziseri() async {
    final response = await http.get(
      Uri.parse('${ApiKonstante.baseUrl}/Reziser'),
      headers: ApiService._createHeaders(),
    );
    final data = json.decode(response.body);
    return (data['resultList'] as List)
        .map((r) => Reziser.fromJson(r))
        .toList();
  }

  static Future<void> deletePredstava(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/Predstava/$id'),
      headers: ApiService._createHeaders(),
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri brisanju predstave');
    }
  }

  static Future<void> updatePredstava(Predstava predstava) async {
    final response = await http.put(
      Uri.parse('${ApiKonstante.baseUrl}/Predstava/${predstava.id}'),
      headers: {..._createHeaders(), 'Content-Type': 'application/json'},
      body: json.encode(predstava.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška pri ažuriranju predstave');
    }
  }

  Future<List<TipKorisnika>> getTipoviKorisnika() async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/TipKorisnika');
    final response = await http.get(url, headers: ApiService._createHeaders());

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
      headers: {
        ...ApiService._createHeaders(),
        'Content-Type': 'application/json',
      },
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
      headers: ApiService._createHeaders(),
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

    final response = await http.get(uri, headers: ApiService._createHeaders());

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
    final response = await http.get(url, headers: ApiService._createHeaders());

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
      headers: {
        ...ApiService._createHeaders(),
        'Content-Type': 'application/json',
      },
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
      headers: ApiService._createHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => GlumacPredstava.fromJson(e)).toList();
    } else {
      throw Exception('Greška prilikom dohvaćanja glumaca za predstavu');
    }
  }

  Future<List<Glumac>> getGlumci({int page = 1, int pageSize = 10}) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/Glumac?Page=$page&PageSize=$pageSize',
    );
    final response = await http.get(url, headers: ApiService._createHeaders());

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> list = decoded['resultList'];
      return list.map((e) => Glumac.fromJson(e)).toList();
    } else {
      throw Exception('Greška prilikom dohvaćanja glumaca.');
    }
  }

  static Future<void> dodajGlumca(InsertGlumac glumac) async {
    final response = await http.post(
      Uri.parse('${ApiKonstante.baseUrl}/Glumac'),
      headers: {
        ...ApiService._createHeaders(),
        'Content-Type': 'application/json',
      },
      body: json.encode(glumac.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška prilikom dodavanja glumca');
    }
  }

  static Future<void> updateGlumac(int id, InsertGlumac glumac) async {
    final response = await http.put(
      Uri.parse('${ApiKonstante.baseUrl}/Glumac/$id'),
      headers: {
        ...ApiService._createHeaders(),
        'Content-Type': 'application/json',
      },
      body: json.encode(glumac.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška prilikom ažuriranja glumca');
    }
  }

  static Future<void> deleteGlumac(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/Glumac/$id'),
      headers: ApiService._createHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška prilikom brisanja glumca');
    }
  }

  Future<List<Reziser>> getReziseri({int page = 1, int pageSize = 10}) async {
    final response = await http.get(
      Uri.parse(
        '${ApiKonstante.baseUrl}/Reziser?Page=$page&PageSize=$pageSize',
      ),
      headers: ApiService._createHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reziseri = List<Reziser>.from(
        data['resultList'].map((r) => Reziser.fromJson(r)),
      );
      return reziseri;
    } else {
      throw Exception('Greška pri učitavanju režisera');
    }
  }

  Future<void> dodajRezisera(InsertReziser reziser) async {
    final response = await http.post(
      Uri.parse('${ApiKonstante.baseUrl}/Reziser'),
      headers: {
        ...ApiService._createHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(reziser.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška pri dodavanju režisera');
    }
  }

  Future<void> updateReziser(int id, InsertReziser reziser) async {
    final response = await http.put(
      Uri.parse('${ApiKonstante.baseUrl}/Reziser/$id'),
      headers: {
        ...ApiService._createHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(reziser.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška pri ažuriranju režisera');
    }
  }

  Future<void> obrisiRezisera(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/Reziser/$id'),
      headers: ApiService._createHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška pri brisanju režisera');
    }
  }

  Future<Map<String, dynamic>> getObavijesti({
    int page = 1,
    int pageSize = 6,
    required String search,
  }) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/Obavijest?Page=$page&PageSize=$pageSize',
    );
    final response = await http.get(url, headers: ApiService._createHeaders());

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // Logiraj odgovor za provjeru
      print("API odgovor: ${decoded}");

      // Provjerimo da li 'resultList' postoji
      final List<dynamic> list = decoded['resultList'] ?? [];
      final int count = decoded['count'] ?? 0;

      final obavijesti = list.map((e) => Obavijest.fromJson(e)).toList();
      return {'data': obavijesti, 'count': count};
    } else {
      throw Exception('Greška prilikom dohvaćanja obavijesti.');
    }
  }

  static Future<void> dodajNovost(InsertNovosti novost) async {
    print("Slanje novosti: ${json.encode(novost.toJson())}");
    final response = await http.post(
      Uri.parse('${ApiKonstante.baseUrl}/Obavijest'),
      headers: _createHeaders(),
      body: json.encode(novost.toJson()),
    );

    if (response.statusCode >= 400) {
      throw Exception("Greška pri dodavanju novosti");
    }
  }

  Future<Korisnik?> getLogovaniKorisnik() async {
    final username = AuthProvider.username!;
    final password = AuthProvider.password!;

    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/Korisnik/login?username=$username&password=$password',
    );

    final response = await http.post(
      url,
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Korisnik.fromJson(data);
    } else {
      print(
        'Greška prilikom dohvata logovanog korisnika: ${response.statusCode}',
      );
      return null;
    }
  }

  static Future<bool> deleteNovost(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/Obavijest/$id'),
      headers: ApiService._createHeaders(),
    );

    if (response.statusCode == 200) {
      return true; // Obavijest je uspješno obrisana
    } else {
      throw Exception('Greška pri brisanju obavijesti');
    }
  }

  static Future<void> updateNovost(int id, UpdateNovosti novost) async {
    final response = await http.put(
      Uri.parse('${ApiKonstante.baseUrl}/Obavijest/$id'),
      headers: {..._createHeaders(), 'Content-Type': 'application/json'},
      body: json.encode(novost.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška pri ažuriranju obavijesti');
    }
  }
}
