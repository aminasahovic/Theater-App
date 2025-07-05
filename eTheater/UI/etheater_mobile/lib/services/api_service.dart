import 'dart:convert';
import 'package:etheater_mobile/models/model.dart';
import 'package:http/http.dart' as http;
import '../core/api_konstante.dart';
import '../providers/auth_provider.dart';

class ApiService {
  static Future<PagedResult<Repertoar>> getRepertoar({
    int page = 1,
    int pageSize = 6,
    String? naziv,
    DateTime? pocetakDatum,
    bool? isActive = true,
  }) async {
    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
      if (naziv != null && naziv.isNotEmpty) 'Naziv': naziv,
      if (pocetakDatum != null) 'PocetakDatum': pocetakDatum.toIso8601String(),
      if (isActive != null) 'IsActive': isActive.toString(),
    };

    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Repertoar',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: AuthProvider.authHeaders);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return PagedResult<Repertoar>.fromJson(
        decoded,
        (json) => Repertoar.fromJson(json),
      );
    } else {
      throw Exception('Greška prilikom dohvaćanja repertoara.');
    }
  }

  static Future<dynamic> login(String username, String password) async {
    final credentials = '$username:$password';
    final encoded = base64Encode(utf8.encode(credentials));

    final headers = {
      'Authorization': 'Basic $encoded',
      'Content-Type': 'application/json',
    };

    final url = Uri.parse('${ApiKonstante.baseUrl}/Korisnik/login');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Neispravni kredencijali');
    }
  }

  static Future<bool> registrujKorisnika(InsertKorisnik korisnik) async {
    final response = await http.post(
      Uri.parse('${ApiKonstante.baseUrl}/Korisnik'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(korisnik.toJson()),
    );

    if (response.statusCode >= 400) {
      return false;
    }

    return true;
  }

  static Future<PagedResult<IzvedbaPredstava>> getIzvedbePoRepertoaru(
    int repertoarId, {
    String? naziv,
    int? zanrId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/RepertoarIzvedba/Izvedbe/$repertoarId'
      '?page=$page&pageSize=$pageSize'
      '${naziv != null ? '&naziv=$naziv' : ''}'
      '${zanrId != null ? '&zanrId=$zanrId' : ''}',
    );

    final response = await http.get(uri, headers: AuthProvider.authHeaders);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PagedResult.fromJson(
        data,
        (json) => IzvedbaPredstava.fromJson(json),
      );
    } else {
      throw Exception('Greška prilikom dohvaćanja izvedbi.');
    }
  }

  static Future<Predstava> getPredstava(int id) async {
    final response = await http.get(
      Uri.parse('${ApiKonstante.baseUrl}/Predstava/$id'),
      headers: AuthProvider.authHeaders,
    );
    if (response.statusCode == 200) {
      return Predstava.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Greška pri dohvaćanju predstave');
    }
  }

  static Future<Izvedba> getIzvedba(int izvedbaId) async {
    final response = await http.get(
      Uri.parse('${ApiKonstante.baseUrl}/Izvedba/$izvedbaId'),
      headers: AuthProvider.authHeaders,
    );
    if (response.statusCode == 200) {
      return Izvedba.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Greška pri dohvaćanju izvedbe');
    }
  }

  static Future<List<GlumacPredstava>> getGlumciZaPredstavu(
    int predstavaId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiKonstante.baseUrl}/GlumacPredstava/predstava/$predstavaId/glumci',
      ),
      headers: AuthProvider.authHeaders,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => GlumacPredstava.fromJson(item)).toList();
    } else {
      throw Exception('Greška pri dohvaćanju glumaca');
    }
  }

  static Future<PagedResult<KomentarPredstava>> getKomentariZaPredstavu(
    int predstavaId,
    int page,
    int pageSize,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiKonstante.baseUrl}/KomentarPredstava/ByPredstava?PredstavaId=$predstavaId&Page=$page&PageSize=$pageSize',
      ),
      headers: AuthProvider.authHeaders,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<KomentarPredstava> komentari =
          (jsonData['resultList'] as List)
              .map((item) => KomentarPredstava.fromJson(item))
              .toList();
      return PagedResult<KomentarPredstava>(
        count: jsonData['count'],
        resultList: komentari,
      );
    } else {
      throw Exception('Neuspješno dohvaćanje komentara.');
    }
  }

  static Future<NovostiResponse> getNovosti({
    String? naslov,
    int page = 1,
    int pageSize = 5,
  }) async {
    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Obavijest?Naslov=${naslov ?? ''}&Page=$page&PageSize=$pageSize',
    );

    final response = await http.get(uri, headers: AuthProvider.authHeaders);

    if (response.statusCode == 200) {
      return NovostiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Greška pri dohvaćanju novosti: ${response.statusCode}');
    }
  }

  static Future<KomentarObavijestResponse> getKomentariByObavijest({
    required int obavijestiId,
    required int page,
    required int pageSize,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiKonstante.baseUrl}/KomentarObavijest/GetByObavijest?ObavijestiId=$obavijestiId&Page=$page&PageSize=$pageSize',
      ),
      headers: AuthProvider.authHeaders,
    );

    if (response.statusCode == 200) {
      return KomentarObavijestResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Greška pri dohvaćanju komentara');
    }
  }

  static Future<PagedResult<OdgovorKomentar>> getOdgovoriByKomentarId({
    required int komentarId,
    required int page,
    required int pageSize,
  }) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/OdgovorKomentar/GetByKomentarId?KomentariObavijestiId=$komentarId&Page=$page&PageSize=$pageSize',
    );

    final response = await http.get(url, headers: AuthProvider.authHeaders);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PagedResult<OdgovorKomentar>.fromJson(
        data,
        (json) => OdgovorKomentar.fromJson(json),
      );
    } else {
      throw Exception('Ne mogu učitati odgovore na komentar');
    }
  }

  static Future<KomentarObavijest> addKomentar({
    required int obavijestId,
    required int korisnikId,
    required String text,
  }) async {
    final Map<String, dynamic> body = {
      "obavijestId": obavijestId,
      "korisnikId": korisnikId,
      "text": text,
      "datum": DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      Uri.parse("${ApiKonstante.baseUrl}/KomentarObavijest"),
      headers: AuthProvider.authHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return KomentarObavijest.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Greška pri slanju komentara: ${response.body}");
    }
  }

  static Future<void> postKomentarNaObavijest(
    InsertKomentarObavijest request,
  ) async {
    final uri = Uri.parse('${ApiKonstante.baseUrl}/KomentarObavijest');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...AuthProvider.authHeaders,
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Greška prilikom slanja komentara.');
    }
  }

  static Future<void> postOdgovorNaKomentar(
    InsertOdgovorKomentar odgovor,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiKonstante.baseUrl}/OdgovorKomentar'),
      headers: {
        ...AuthProvider.authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(odgovor.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMessage =
          response.body.isNotEmpty
              ? jsonDecode(response.body)['message'] ?? response.reasonPhrase
              : 'Nepoznata greška';
      throw Exception(
        'Greška prilikom slanja odgovora na komentar: $errorMessage',
      );
    }
  }

  static Future<void> addKomentarPredstava({
    required InsertKomentarPredstava komentar,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiKonstante.baseUrl}/KomentarPredstava"),
      headers: AuthProvider.authHeaders,
      body: jsonEncode(komentar.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Greška pri slanju komentara: ${response.body}");
    }
  }

  static Future<KorisnikProfile> getKorisnikById(int id) async {
    final uri = Uri.parse('${ApiKonstante.baseUrl}/Korisnik/$id');
    final response = await http.get(uri, headers: AuthProvider.authHeaders);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return KorisnikProfile.fromJson(decoded);
    } else {
      throw Exception('Greška prilikom dohvaćanja korisnika.');
    }
  }

  static Future<bool> updateKorisnik(
    int id,
    KorisnikUpdateRequest request,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiKonstante.baseUrl}/Korisnik/$id'),
      headers: AuthProvider.authHeaders,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Neuspješan update korisnika: ${response.statusCode}');
    }
  }

  static Future<List<IzvedbaSjediste>> getSjedistaZaIzvedbu(
    int izvedbaId,
  ) async {
    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/IzvedbaSjediste/ByIzvedba/$izvedbaId',
    );

    final response = await http.get(uri, headers: AuthProvider.authHeaders);

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => IzvedbaSjediste.fromJson(e)).toList();
    } else {
      throw Exception("Greška pri dohvaćanju sjedišta.");
    }
  }

  static Future<void> rezervisiKupovinu(RezervacijaRequest request) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/Rezervacija/novaRezervacija',
    );

    final response = await http.post(
      url,
      headers: AuthProvider.authHeaders,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Greška prilikom rezervacije.');
    }
  }

  static Future<void> updateStatusSjedista(
    UpdateSjedisteStatusRequest request,
    int sjedisteId,
  ) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/IzvedbaSjediste/$sjedisteId',
    );

    final response = await http.put(
      url,
      headers: AuthProvider.authHeaders,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Greška prilikom ažuriranja statusa sjedišta.');
    }
  }

  static Future<PagedResult<MojaRezervacija>> getMojeRezervacije({
    required int korisnikId,
    String? nazivPredstave,
    bool? aktivne,
    bool isUsedTicket = false,
    int page = 1,
    int pageSize = 4,
  }) async {
    final queryParams = <String, String>{
      'KorisnikId': korisnikId.toString(),
      'IsUsedTicket': isUsedTicket.toString(),
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
      if (aktivne != null) 'Aktivne': aktivne.toString(),
      if (nazivPredstave != null && nazivPredstave.isNotEmpty)
        'NazivPredstave': nazivPredstave,
    };
    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Rezervacija/korisnik',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: AuthProvider.authHeaders);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      return PagedResult<MojaRezervacija>.fromJson(
        decoded,
        (json) => MojaRezervacija.fromJson(json),
      );
    } else {
      throw Exception("Greška prilikom dohvata rezervacija");
    }
  }

  static Future<bool> obrisiRezervaciju(int rezervacijaId) async {
    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Rezervacija/obrisi/$rezervacijaId',
    );

    final response = await http.delete(uri, headers: AuthProvider.authHeaders);

    if (response.statusCode == 200) {
      final body = response.body.toLowerCase();
      return body.contains('true');
    } else {
      throw Exception('Greška prilikom brisanja rezervacije.');
    }
  }

  static Future<List<Zanr>> getZanrovi() async {
    final response = await http.get(
      Uri.parse('${ApiKonstante.baseUrl}/Zanr'),
      headers: AuthProvider.authHeaders,
    );
    final data = json.decode(response.body);
    return (data['resultList'] as List).map((z) => Zanr.fromJson(z)).toList();
  }

  static Future<void> useTicket(int rezervacijaId) async {
    final url = Uri.parse(
      '${ApiKonstante.baseUrl}/Rezervacija/use-ticket/$rezervacijaId',
    );

    final response = await http.post(url, headers: AuthProvider.authHeaders);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      final poruka = data['poruka'] ?? 'Greška pri obradi zahtjeva.';
      throw Exception(poruka);
    } else {
      throw Exception('Došlo je do greške. Pokušajte ponovo.');
    }
  }

  static Future<List<PredstavaPreporuka>> getPreporukeZaKorisnika(
    int korisnikId,
  ) async {
    final uri = Uri.parse(
      '${ApiKonstante.baseUrl}/Predstava/GetPreporukuByKorisnikID/$korisnikId',
    );

    final response = await http.get(uri, headers: AuthProvider.authHeaders);
    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      return decoded.map((e) => PredstavaPreporuka.fromJson(e)).toList();
    } else {
      throw Exception('Greška prilikom dohvaćanja preporuka.');
    }
  }

  static Future<void> posaljiPotvrdu({
    required int? korisnikId,
    required String nazivPredstave,
    required DateTime datumPrikazivanja,
    required String sala,
    required int brojKarata,
    required double ukupnaCijena,
    required bool isRezervacija,
  }) async {
    final uri = Uri.parse(
      "${ApiKonstante.baseUrl}/Korisnik/posalji-potvrdu"
      "?korisnikID=$korisnikId"
      "&nazivPredstave=${Uri.encodeComponent(nazivPredstave)}"
      "&datumPrikazivanja=${datumPrikazivanja.toIso8601String()}"
      "&sala=${Uri.encodeComponent(sala)}"
      "&brojKarata=$brojKarata"
      "&ukupnaCijena=$ukupnaCijena"
      "&isRezervacija=$isRezervacija",
    );

    final response = await http.post(uri, headers: AuthProvider.authHeaders);

    if (response.statusCode != 200) {
      throw Exception("Greška prilikom slanja potvrde: ${response.body}");
    }
  }
}
