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
        Izvedba,
        IzvedbaInsert,
        IzvedbaPeriodModel,
        IzvedbaUpdateRequest,
        KomentarObavijest,
        KomentarPredstavaDTO,
        KorisniciInsert,
        Korisnik,
        KorisnikById,
        KorisnikUpdateRequest,
        KorisnikVM,
        NovostById,
        Obavijest,
        OdgovorKomentar,
        PagedResult,
        Predstava,
        PredstavaInsert,
        PredstavaLov,
        Repertoar,
        RepertoarIzvedba,
        Reziser,
        Sala,
        TicketSalesReportDTO,
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

  static Future<Korisnik> login(String username, String password) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/Korisnik/login?username=$username&password=$password',
    );

    final response = await http.post(
      url,
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['tipKorisnikaId'] != 4) {
        throw Exception(
          "Pristup je dozvoljen samo ovlaštenim administratorima.",
        );
      }

      return Korisnik.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception("Pogrešno korisničko ime ili lozinka.");
    } else {
      throw Exception("Greška prilikom logovanja: ${response.statusCode}");
    }
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
      return data['id'];
    } else {
      print('Greška prilikom dohvata ID-a: ${response.statusCode}');
      return null;
    }
  }

  Future<PagedResult<Predstava>> getPredstave({
    String? naziv,
    int? zanrId,
    int? reziserId,
    int? godina,
    bool? isActive,
    int page = 1,
    int pageSize = 5,
  }) async {
    final queryParams = {
      if (isActive != null) 'isActive': isActive.toString(),
      if (naziv != null && naziv.isNotEmpty) 'Naziv': naziv,
      if (zanrId != null) 'ZanrId': zanrId.toString(),
      if (reziserId != null) 'ReziserId': reziserId.toString(),
      if (godina != null) 'Godina': godina.toString(),
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Predstava',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: ApiService._createHeaders());

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PagedResult<Predstava>.fromJson(
        jsonData,
        (json) => Predstava.fromJson(json),
      );
    } else {
      throw Exception(
        'Neuspješno dohvaćanje predstava: ${response.statusCode}',
      );
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
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams = {
      if (ime != null && ime.isNotEmpty) 'ImeGTE': ime,
      if (prezime != null && prezime.isNotEmpty) 'PrezimeGTE': prezime,
      if (username != null && username.isNotEmpty) 'KorisnickoIme': username,
      if (tipKorisnikaId != null) 'IsTipKorisnika': tipKorisnikaId.toString(),
      if (isActive != null) 'IsActive': isActive.toString(),
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

  Future<void> updateKorisnik(int id, KorisnikUpdateRequest korisnik) async {
    final response = await http.put(
      Uri.parse('${ApiKonstante.baseUrl}/Korisnik/$id'),
      headers: ApiService._createHeaders(),
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

  Future<PagedResult<Glumac>> getGlumci({
    int page = 1,
    int pageSize = 4,
    String? imePrezime,
  }) async {
    final query = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
      if (imePrezime != null && imePrezime.isNotEmpty) 'ImePrezime': imePrezime,
    };

    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Glumac',
    ).replace(queryParameters: query);

    final response = await http.get(uri, headers: ApiService._createHeaders());

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return PagedResult<Glumac>.fromJson(
        decoded,
        (json) => Glumac.fromJson(json),
      );
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

  Future<List<Reziser>> getReziseri({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    final queryParameters = {
      'Page': '$page',
      'PageSize': '$pageSize',
      if (search != null && search.isNotEmpty) 'ImePrezime': search,
    };

    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Reziser',
    ).replace(queryParameters: queryParameters);

    final response = await http.get(uri, headers: _createHeaders());

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
    String? naslov,
    DateTime? datumObjave,
  }) async {
    final queryParams = {
      'Page': '$page',
      'PageSize': '$pageSize',
      if (naslov != null && naslov.isNotEmpty) 'Naslov': naslov,
      if (datumObjave != null) 'DatumObjave': datumObjave.toIso8601String(),
    };

    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Obavijest',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _createHeaders());

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> list = decoded['resultList'] ?? [];
      final int count = decoded['count'] ?? 0;
      final obavijesti = list.map((e) => Obavijest.fromJson(e)).toList();
      return {'data': obavijesti, 'count': count};
    } else {
      throw Exception('Greška prilikom dohvaćanja obavijesti.');
    }
  }

  static Future<void> dodajNovost(InsertNovosti novost) async {
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
      return true;
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

  Future<PagedResult<Izvedba>> getIzvedbe({
    int? salaId,
    String? nazivPredstave,
    DateTime? datum,
    int page = 1,
    int pageSize = 5,
  }) async {
    final queryParams = {
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
      if (salaId != null) 'SalaId': salaId.toString(),
      if (nazivPredstave != null && nazivPredstave.isNotEmpty)
        'NazivPredstave': nazivPredstave,
      if (datum != null) 'DatumIzvodjenja': datum.toIso8601String(),
    };

    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/getall',
    ).replace(queryParameters: queryParams);

    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      return PagedResult<Izvedba>.fromJson(
        decoded,
        (json) => Izvedba.fromJson(json),
      );
    } else {
      throw Exception('Greška prilikom dohvaćanja izvedbi.');
    }
  }

  Future<List<Sala>> getSale() async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/Sala');
    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> results = decoded['resultList'];
      return results.map((e) => Sala.fromJson(e)).toList();
    } else {
      throw Exception('Greška prilikom dohvaćanja sala.');
    }
  }

  static Future<int> dodajIzvedbu(IzvedbaInsert izvedba) async {
    final response = await http.post(
      Uri.parse('${ApiKonstante.baseUrl}/add'),
      headers: {..._createHeaders(), 'Content-Type': 'application/json'},
      body: json.encode(izvedba.toJson()),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['id'];
    } else {
      final error = json.decode(response.body);
      print(error);
      final message = error['message'] ?? 'Greška pri dodavanju izvedbe.';
      print(message);
      throw Exception(message);
    }
  }

  static Future<PagedResult<PredstavaLov>> getPredstaveLov({
    String? naziv,
    int page = 0,
    int pageSize = 0,
  }) async {
    final queryParameters = <String, String>{};

    if (naziv != null && naziv.isNotEmpty) {
      queryParameters['Naziv'] = naziv;
    }

    if (pageSize > 0) {
      queryParameters['Page'] = page.toString();
      queryParameters['PageSize'] = pageSize.toString();
    }

    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Predstava/GetAllIdNaziv',
    ).replace(queryParameters: queryParameters);

    final response = await http.get(uri, headers: _createHeaders());

    if (response.statusCode == 200) {
      try {
        final decoded = json.decode(response.body);
        return PagedResult<PredstavaLov>.fromJson(
          decoded,
          (json) => PredstavaLov.fromJson(json),
        );
      } catch (e) {
        throw Exception('Greška prilikom parsiranja podataka.');
      }
    } else {
      throw Exception('Greška prilikom dohvaćanja predstava.');
    }
  }

  static Future<bool> deleteIzvedba(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/Izvedba/$id'),
      headers: ApiService._createHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Greška pri brisanju izvedbe');
    }
  }

  static Future<void> updateIzvedba(
    IzvedbaUpdateRequest izvedba,
    int id,
  ) async {
    final body = json.encode(izvedba.toJson());

    final response = await http.put(
      Uri.parse('${ApiKonstante.baseUrl}/Izvedba/$id'),
      headers: {..._createHeaders(), 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Greška pri ažuriranju izvedbe');
    }
  }

  Future<NovostById> getNovostById(int id) async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/Obavijest/$id');
    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      return NovostById.fromJson(json.decode(response.body));
    } else {
      throw Exception("Greška pri dohvaćanju novosti.");
    }
  }

  Future<KorisnikById> getKorisnikById(int id) async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/Korisnik/$id');
    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      return KorisnikById.fromJson(json.decode(response.body));
    } else {
      throw Exception("Greška pri dohvaćanju korisnika.");
    }
  }

  Future<Map<String, dynamic>> getRepertoar({
    int page = 1,
    int pageSize = 6,
    String? naziv,
    DateTime? pocetakDatum,
  }) async {
    final queryParams = {
      'Page': '$page',
      'PageSize': '$pageSize',
      if (naziv != null && naziv.isNotEmpty) 'Naziv': naziv,
      if (pocetakDatum != null) 'PocetakDatum': pocetakDatum.toIso8601String(),
    };

    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Repertoar',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _createHeaders());

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> list = decoded['resultList'] ?? [];
      final int count = decoded['count'] ?? 0;
      final repertoari = list.map((e) => Repertoar.fromJson(e)).toList();
      return {'data': repertoari, 'count': count};
    } else {
      throw Exception('Greška prilikom dohvaćanja repertoara.');
    }
  }

  Future<List<RepertoarIzvedba>> getRepertoarIzvedbe(int repertoarId) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/RepertoarIzvedba/Izvedbe/$repertoarId',
    );
    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pagedResult = PagedResult<RepertoarIzvedba>.fromJson(
        data,
        (json) => RepertoarIzvedba.fromJson(json),
      );
      return pagedResult.resultList;
    } else {
      throw Exception("Greška pri dohvaćanju izvedbi.");
    }
  }

  Future<Predstava> getPredstavaById(int id) async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/Predstava/$id');
    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      return Predstava.fromJson(json.decode(response.body));
    } else {
      throw Exception("Greška pri dohvaćanju predstave.");
    }
  }

  static Future<void> deleteRepertoar(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/Repertoar/$id'),
      headers: ApiService._createHeaders(),
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri brisanju repertoara');
    }
  }

  Future<int?> dodajRepertoar({
    required String naziv,
    required DateTime pocetakDatum,
    required DateTime krajDatum,
  }) async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/Repertoar');
    final response = await http.post(
      url,
      headers: _createHeaders(),
      body: jsonEncode({
        'naziv': naziv,
        'pocetakDatum': pocetakDatum.toIso8601String(),
        'krajDatum': krajDatum.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      return null;
    }
  }

  Future<List<IzvedbaPeriodModel>> getIzvedbeByDatum({
    required DateTime datumOd,
    required DateTime datumDo,
  }) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/Izvedba/period?DatumOd=${datumOd.toIso8601String()}&DatumDo=${datumDo.toIso8601String()}',
    );
    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => IzvedbaPeriodModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<void> dodajRepertoarIzvedba({
    required int repertoarId,
    required int izvedbaId,
  }) async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/RepertoarIzvedba');
    await http.post(
      url,
      headers: _createHeaders(),
      body: jsonEncode({'repertoarId': repertoarId, 'izvedbaId': izvedbaId}),
    );
  }

  Future<void> updateRepertoar(int id, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/Repertoar/$id');
    final response = await http.put(
      url,
      headers: _createHeaders(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Greška pri ažuriranju repertoara.');
    }
  }

  Future<void> deleteRepertoarIzvedba(int id) async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/RepertoarIzvedba/$id');
    final response = await http.delete(url, headers: _createHeaders());

    if (response.statusCode != 200) {
      throw Exception('Greška pri brisanju izvedbe.');
    }
  }

  static Future<PagedResult<KomentarPredstavaDTO>> getKomentariByPredstava(
    int predstavaId, {
    int page = 1,
    int pageSize = 3,
  }) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/KomentarPredstava/ByPredstava?PredstavaId=$predstavaId&Page=$page&PageSize=$pageSize',
    );

    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
        final List<dynamic> list = jsonData['resultList'];
        final int count = jsonData['count'];
        final items =
            list.map((e) => KomentarPredstavaDTO.fromJson(e)).toList();
        return PagedResult(count: count, resultList: items);
      } catch (e) {
        throw Exception('Greška prilikom parsiranja komentara.');
      }
    } else {
      throw Exception('Greška prilikom dohvaćanja komentara.');
    }
  }

  static Future<void> deleteKomentarPredstava(int komentarId) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/KomentarPredstava/$komentarId'),
      headers: _createHeaders(),
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri brisanju komentara');
    }
  }

  Future<Map<String, dynamic>> getKomentariByObavijest({
    required int obavijestId,
    int page = 1,
    int pageSize = 6,
  }) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/KomentarObavijest/GetByObavijest?ObavijestiId=$obavijestId&Page=$page&PageSize=$pageSize',
    );

    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<KomentarObavijest> komentari =
          (data['resultList'] as List)
              .map((json) => KomentarObavijest.fromJson(json))
              .toList();

      return {'data': komentari, 'count': data['count']};
    } else {
      throw Exception('Greška pri dohvatu komentara');
    }
  }

  Future<Map<String, dynamic>> getOdgovoriNaKomentar({
    required int komentariObavijestiId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/OdgovorKomentar/GetByKomentarId?KomentariObavijestiId=$komentariObavijestiId&Page=$page&PageSize=$pageSize',
    );

    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<OdgovorKomentar> odgovori =
          (jsonData['resultList'] as List)
              .map((o) => OdgovorKomentar.fromJson(o))
              .toList();
      return {"count": jsonData['count'], "data": odgovori};
    } else {
      throw Exception("Greška pri dohvatu odgovora.");
    }
  }

  static Future<void> deleteKomentar(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/KomentarObavijest/$id'),
      headers: ApiService._createHeaders(),
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri brisanju komentara');
    }
  }

  static Future<void> deleteOdgovorKomentar(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiKonstante.baseUrl}/OdgovorKomentar/$id'),
      headers: ApiService._createHeaders(),
    );

    if (response.statusCode >= 400) {
      throw Exception('Greška pri brisanju odgovora');
    }
  }

  Future<KorisnikVM> getByIdKorisnik(int id) async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/Korisnik/$id');
    final response = await http.get(url, headers: _createHeaders());

    if (response.statusCode == 200) {
      return KorisnikVM.fromJson(json.decode(response.body));
    } else {
      throw Exception("Greška pri dohvaćanju korisnika.");
    }
  }

  Future<TicketSalesReportDTO> getTicketSalesReport(int izvedbaId) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/Rezervacija/izvjestaj/prodaja/$izvedbaId',
    );
    final response = await http.get(url, headers: _createHeaders());
    if (response.statusCode == 200) {
      return TicketSalesReportDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Greška prilikom dohvata izveštaja: ${response.statusCode}',
      );
    }
  }
}
