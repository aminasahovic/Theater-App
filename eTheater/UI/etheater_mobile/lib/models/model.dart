import 'package:flutter/foundation.dart';

class PagedResult<T> {
  final List<T> resultList;
  final int count;

  PagedResult({required this.resultList, required this.count});

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawList = (json['resultList'] as List<dynamic>?) ?? [];
    final parsed = <T>[];
    for (final item in rawList) {
      try {
        parsed.add(fromJsonT(item as Map<String, dynamic>));
      } catch (e) {
        debugPrint('PagedResult: preskačem stavku zbog greške: $e\nItem: $item');
      }
    }
    return PagedResult(
      resultList: parsed,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class Predstava {
  final int id;
  final String naziv;
  final int zanrId;
  final String opis;
  final int trajanje;
  final int godina;
  final String? plakat;
  final bool isActive;
  final int reziserId;

  Predstava({
    required this.id,
    required this.naziv,
    required this.zanrId,
    required this.opis,
    required this.trajanje,
    required this.godina,
    this.plakat,
    required this.isActive,
    required this.reziserId,
  });

  factory Predstava.fromJson(Map<String, dynamic> json) {
    return Predstava(
      id: (json['id'] as num?)?.toInt() ?? 0,
      naziv: (json['naziv'] as String?) ?? '',
      zanrId: (json['zanrId'] as num?)?.toInt() ?? 0,
      opis: (json['opis'] as String?) ?? '',
      trajanje: (json['trajanje'] as num?)?.toInt() ?? 0,
      godina: (json['godina'] as num?)?.toInt() ?? 0,
      plakat: json['plakat'] as String?,
      isActive: (json['isActive'] as bool?) ?? false,
      reziserId: (json['reziserId'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'naziv': naziv,
      'zanrId': zanrId,
      'opis': opis,
      'trajanje': trajanje,
      'godina': godina,
      'plakat': plakat,
      'isActive': isActive,
      'reziserId': reziserId,
    };
  }
}

class PredstavaPreporuka {
  final int id;
  final String naziv;
  final int zanrId;
  final String opis;
  final int trajanje;
  final int godina;
  final String? plakat;
  final bool isActive;
  final int reziserId;
  final int izvedbaId;

  PredstavaPreporuka({
    required this.id,
    required this.naziv,
    required this.zanrId,
    required this.opis,
    required this.trajanje,
    required this.godina,
    this.plakat,
    required this.isActive,
    required this.reziserId,
    required this.izvedbaId,
  });

  factory PredstavaPreporuka.fromJson(Map<String, dynamic> json) {
    return PredstavaPreporuka(
      id: (json['id'] as num?)?.toInt() ?? 0,
      naziv: (json['naziv'] as String?) ?? '',
      zanrId: (json['zanrId'] as num?)?.toInt() ?? 0,
      opis: (json['opis'] as String?) ?? '',
      trajanje: (json['trajanje'] as num?)?.toInt() ?? 0,
      godina: (json['godina'] as num?)?.toInt() ?? 0,
      plakat: json['plakat'] as String?,
      isActive: (json['isActive'] as bool?) ?? false,
      reziserId: (json['reziserId'] as num?)?.toInt() ?? 0,
      izvedbaId: (json['izvedbaId'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'naziv': naziv,
      'zanrId': zanrId,
      'opis': opis,
      'trajanje': trajanje,
      'godina': godina,
      'plakat': plakat,
      'isActive': isActive,
      'reziserId': reziserId,
    };
  }
}

class InsertKorisnik {
  String ime;
  String prezime;
  String username;
  String password;
  String passwordPotvrda;
  String email;
  bool isActive;
  String brojTelefona;
  int tipKorisnikaId;

  InsertKorisnik({
    required this.ime,
    required this.prezime,
    required this.username,
    required this.password,
    required this.passwordPotvrda,
    required this.email,
    this.isActive = true,
    required this.brojTelefona,
    this.tipKorisnikaId = 3,
  });

  factory InsertKorisnik.fromJson(Map<String, dynamic> json) {
    return InsertKorisnik(
      ime: json['ime'] ?? '',
      prezime: json['prezime'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      passwordPotvrda: json['passwordPotvrda'] ?? '',
      email: json['email'] ?? '',
      isActive: json['isActive'] ?? true,
      brojTelefona: json['brojTelefona'] ?? '',
      tipKorisnikaId: json['tipKorisnikaId'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ime': ime,
      'prezime': prezime,
      'username': username,
      'password': password,
      'passwordPotvrda': passwordPotvrda,
      'email': email,
      'isActive': isActive,
      'brojTelefona': brojTelefona,
      'tipKorisnikaId': tipKorisnikaId,
    };
  }
}

class Repertoar {
  final int id;
  final DateTime pocetakDatum;
  final DateTime krajDatum;
  final String naziv;

  Repertoar({
    required this.id,
    required this.pocetakDatum,
    required this.krajDatum,
    required this.naziv,
  });

  factory Repertoar.fromJson(Map<String, dynamic> json) {
    return Repertoar(
      id: (json['id'] as num?)?.toInt() ?? 0,
      pocetakDatum: json['pocetakDatum'] != null
          ? DateTime.parse(json['pocetakDatum'] as String)
          : DateTime.now(),
      krajDatum: json['krajDatum'] != null
          ? DateTime.parse(json['krajDatum'] as String)
          : DateTime.now(),
      naziv: (json['naziv'] as String?) ?? '',
    );
  }
}

class IzvedbaPredstava {
  final int repertoarIzvedbaId;
  final int repertoarId;
  final int predstavaId;
  final int izvedbaId;
  final String nazivPredstave;
  final DateTime datumVrijemeIzvedbe;
  final String? plakat;
  final double? cijenaKarte;
  final int salaId;
  final String salaNaziv;

  IzvedbaPredstava({
    required this.repertoarIzvedbaId,
    required this.repertoarId,
    required this.predstavaId,
    required this.izvedbaId,
    required this.nazivPredstave,
    required this.datumVrijemeIzvedbe,
    this.plakat,
    required this.cijenaKarte,
    required this.salaId,
    required this.salaNaziv,
  });

  factory IzvedbaPredstava.fromJson(Map<String, dynamic> json) {
    return IzvedbaPredstava(
      repertoarIzvedbaId: json['repertoarIzvedbaId'] ?? 0,
      repertoarId: json['repertoarId'] ?? 0,
      predstavaId: json['predstavaId'] ?? 0,
      izvedbaId: json['izvedbaId'] ?? 0,
      nazivPredstave: json['nazivPredstave'] ?? '',
      datumVrijemeIzvedbe: DateTime.parse(json['datumVrijemeIzvedbe']),
      plakat: json['plakat'],
      cijenaKarte:
          json['cijenaKarte'] != null
              ? (json['cijenaKarte'] as num).toDouble()
              : 0.0,
      salaId: json['salaId'] ?? 0,
      salaNaziv: json['salaNaziv'] ?? '',
    );
  }
}

class Izvedba {
  int id;
  int predstavaId;
  DateTime datumVrijemeIzvodjenja;
  double cijenaKarte;

  Izvedba({
    required this.id,
    required this.predstavaId,
    required this.datumVrijemeIzvodjenja,
    required this.cijenaKarte,
  });

  factory Izvedba.fromJson(Map<String, dynamic> json) => Izvedba(
    id: (json['id'] as num?)?.toInt() ?? 0,
    predstavaId: (json['predstavaId'] as num?)?.toInt() ?? 0,
    datumVrijemeIzvodjenja: json['datumVrijeme'] != null
        ? DateTime.parse(json['datumVrijeme'] as String)
        : DateTime.now(),
    cijenaKarte: (json['cijenaKarte'] as num?)?.toDouble() ?? 0.0,
  );
}

class GlumacPredstava {
  final int glumacId;
  final String ime;
  final String prezime;
  final String uloga;
  final String? slika;

  GlumacPredstava({
    required this.glumacId,
    required this.ime,
    required this.prezime,
    required this.uloga,
    this.slika,
  });

  factory GlumacPredstava.fromJson(Map<String, dynamic> json) {
    return GlumacPredstava(
      glumacId: (json['glumacId'] as num?)?.toInt() ?? 0,
      ime: (json['ime'] as String?) ?? '',
      prezime: (json['prezime'] as String?) ?? '',
      uloga: (json['uloga'] as String?) ?? '',
      slika: json['slika'] as String?,
    );
  }
}

class KomentarPredstava {
  int id;
  int korisnikId;
  int predstavaId;
  int ocjena;
  String komentar;
  String imeKorisnika;
  String prezimeKorisnika;
  DateTime datum;

  KomentarPredstava({
    required this.id,
    required this.korisnikId,
    required this.predstavaId,
    required this.ocjena,
    required this.komentar,
    required this.imeKorisnika,
    required this.prezimeKorisnika,
    required this.datum,
  });

  factory KomentarPredstava.fromJson(Map<String, dynamic> json) {
    return KomentarPredstava(
      id: (json['id'] as num?)?.toInt() ?? 0,
      korisnikId: (json['korisnikId'] as num?)?.toInt() ?? 0,
      predstavaId: (json['predstavaId'] as num?)?.toInt() ?? 0,
      ocjena: (json['ocjena'] as num?)?.toInt() ?? 0,
      komentar: (json['komentar'] as String?) ?? '',
      imeKorisnika: (json['imeKorisnika'] as String?) ?? '',
      prezimeKorisnika: (json['prezimeKorisnika'] as String?) ?? '',
      datum: json['datum'] != null
          ? DateTime.parse(json['datum'] as String)
          : DateTime.now(),
    );
  }
}

class Novost {
  final int id;
  final int? korisnikId;
  final String naslov;
  final String sadrzaj;
  final DateTime datumObjave;
  final String? slika;

  Novost({
    required this.id,
    this.korisnikId,
    required this.naslov,
    required this.sadrzaj,
    required this.datumObjave,
    this.slika,
  });

  factory Novost.fromJson(Map<String, dynamic> json) {
    return Novost(
      id: (json['id'] as num?)?.toInt() ?? 0,
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      naslov: (json['naslov'] as String?) ?? '',
      sadrzaj: (json['sadrzaj'] as String?) ?? '',
      datumObjave: json['datumObjave'] != null
          ? DateTime.parse(json['datumObjave'] as String)
          : DateTime.now(),
      slika: json['slika'] as String?,
    );
  }
}

class NovostiResponse {
  final int count;
  final List<Novost> resultList;

  NovostiResponse({required this.count, required this.resultList});

  factory NovostiResponse.fromJson(Map<String, dynamic> json) {
    final rawList = (json['resultList'] as List<dynamic>?) ?? [];
    final parsed = <Novost>[];
    for (final e in rawList) {
      try {
        parsed.add(Novost.fromJson(e as Map<String, dynamic>));
      } catch (err) {
        debugPrint('NovostiResponse: preskačem stavku zbog greške: $err\nItem: $e');
      }
    }
    return NovostiResponse(
      count: (json['count'] as num?)?.toInt() ?? 0,
      resultList: parsed,
    );
  }
}

class KomentarObavijest {
  final int id;
  final int obavijestId;
  final int korisnikId;
  final String text;
  final DateTime datum;
  final String imeKorisnika;
  final String prezimeKorisnika;

  KomentarObavijest({
    required this.id,
    required this.obavijestId,
    required this.korisnikId,
    required this.text,
    required this.datum,
    required this.imeKorisnika,
    required this.prezimeKorisnika,
  });

  factory KomentarObavijest.fromJson(Map<String, dynamic> json) {
    return KomentarObavijest(
      id: json['id'] ?? 0,
      obavijestId: json['obavijestId'] ?? 0,
      korisnikId: json['korisnikId'] ?? 0,
      text: json['text'] ?? '',
      datum: DateTime.parse(json['datum']),
      imeKorisnika: json['imeKorisnika'] ?? '',
      prezimeKorisnika: json['prezimeKorisnika'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'obavijestId': obavijestId,
    'korisnikId': korisnikId,
    'text': text,
    'datum': datum.toIso8601String(),
    'imeKorisnika': imeKorisnika,
    'prezimeKorisnika': prezimeKorisnika,
  };
}

class KomentarObavijestResponse {
  final int count;
  final List<KomentarObavijest> resultList;

  KomentarObavijestResponse({required this.count, required this.resultList});

  factory KomentarObavijestResponse.fromJson(Map<String, dynamic> json) {
    return KomentarObavijestResponse(
      count: json['count'] ?? 0,
      resultList:
          (json['resultList'] as List<dynamic>?)
              ?.map((item) => KomentarObavijest.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'count': count,
    'resultList': resultList.map((e) => e.toJson()).toList(),
  };
}

class OdgovorKomentar {
  final int id;
  final int komentariObavijestiId;
  final int korisnikId;
  final String textOdgovora;
  final DateTime datum;
  final String imeKorisnika;
  final String prezimeKorisnika;

  OdgovorKomentar({
    required this.id,
    required this.komentariObavijestiId,
    required this.korisnikId,
    required this.textOdgovora,
    required this.datum,
    required this.imeKorisnika,
    required this.prezimeKorisnika,
  });

  factory OdgovorKomentar.fromJson(Map<String, dynamic> json) {
    return OdgovorKomentar(
      id: (json['id'] as num?)?.toInt() ?? 0,
      komentariObavijestiId: (json['komentariObavijestiId'] as num?)?.toInt() ?? 0,
      korisnikId: (json['korisnikId'] as num?)?.toInt() ?? 0,
      textOdgovora: (json['textOdgovora'] as String?) ?? '',
      datum: json['datum'] != null
          ? DateTime.parse(json['datum'] as String)
          : DateTime.now(),
      imeKorisnika: (json['imeKorisnika'] as String?) ?? '',
      prezimeKorisnika: (json['prezimeKorisnika'] as String?) ?? '',
    );
  }
}

class InsertKomentarObavijest {
  final int obavijestId;
  final int korisnikId;
  final String text;
  final DateTime datum;

  InsertKomentarObavijest({
    required this.obavijestId,
    required this.korisnikId,
    required this.text,
    required this.datum,
  });

  Map<String, dynamic> toJson() => {
    'obavijestId': obavijestId,
    'korisnikId': korisnikId,
    'text': text,
    'datum': datum.toIso8601String(),
  };
}

class InsertOdgovorKomentar {
  final int komentariObavijestiId;
  final int korisnikId;
  final String textOdgovora;
  final DateTime datum;

  InsertOdgovorKomentar({
    required this.komentariObavijestiId,
    required this.korisnikId,
    required this.textOdgovora,
    required this.datum,
  });

  Map<String, dynamic> toJson() => {
    "komentariObavijestiId": komentariObavijestiId,
    "korisnikId": korisnikId,
    "textOdgovora": textOdgovora,
    "datum": datum.toIso8601String(),
  };
}

class InsertKomentarPredstava {
  final int korisnikId;
  final int predstavaId;
  final int ocjena;
  final String komentar;
  final DateTime datum;

  InsertKomentarPredstava({
    required this.korisnikId,
    required this.predstavaId,
    required this.ocjena,
    required this.komentar,
    required this.datum,
  });

  Map<String, dynamic> toJson() => {
    "korisnikId": korisnikId,
    "predstavaId": predstavaId,
    "ocjena": ocjena,
    "datum": datum.toIso8601String(),
    "komentar": komentar,
  };
}

class Korisnik {
  final int id;
  final String ime;
  final String prezime;
  final String username;
  final int tipKorisnikaId;
  final String email;
  final String brojTelefona;

  Korisnik({
    required this.id,
    required this.ime,
    required this.prezime,
    required this.username,
    required this.tipKorisnikaId,
    required this.email,
    required this.brojTelefona,
  });

  factory Korisnik.fromJson(Map<String, dynamic> json) {
    return Korisnik(
      id: json['id'] ?? 0,
      ime: json['ime'] ?? '',
      prezime: json['prezime'] ?? '',
      username: json['username'] ?? '',
      tipKorisnikaId: json['tipKorisnikaId'] ?? 0,
      email: json['email'] ?? '',
      brojTelefona: json['brojTelefona'] ?? '',
    );
  }
}

class KorisnikProfile {
  final int id;
  final String ime;
  final String prezime;
  final String username;
  final int tipKorisnikaId;
  final String email;
  final String brojTelefona;
  final String? slikaProfila;

  KorisnikProfile({
    required this.id,
    required this.ime,
    required this.prezime,
    required this.username,
    required this.tipKorisnikaId,
    required this.email,
    required this.brojTelefona,
    this.slikaProfila,
  });

  factory KorisnikProfile.fromJson(Map<String, dynamic> json) {
    return KorisnikProfile(
      id: json['id'] ?? 0,
      ime: json['ime'] ?? '',
      prezime: json['prezime'] ?? '',
      username: json['username'] ?? '',
      tipKorisnikaId: json['tipKorisnikaId'] ?? 0,
      email: json['email'] ?? '',
      brojTelefona: json['brojTelefona'] ?? '',
      slikaProfila: json['slikaProfila'],
    );
  }
}

class KorisnikUpdateRequest {
  final String ime;
  final String prezime;
  final String brojTelefona;
  final bool status;
  final String email;
  final String? password;
  final String? passwordPotvrda;
  final int tipKorisnikaId;
  final String? slikaProfila;

  KorisnikUpdateRequest({
    required this.ime,
    required this.prezime,
    required this.brojTelefona,
    required this.status,
    required this.email,
    required this.password,
    required this.passwordPotvrda,
    required this.tipKorisnikaId,
    this.slikaProfila,
  });
  Map<String, dynamic> toJson() {
    final data = {
      'ime': ime,
      'prezime': prezime,
      'brojTelefona': brojTelefona,
      'status': status,
      'email': email,
      'tipKorisnikaId': tipKorisnikaId,
      'slikaProfila': slikaProfila,
    };

    if (password != null && password!.isNotEmpty) {
      data['password'] = password!;
      data['passwordPotvrda'] = passwordPotvrda!;
    }

    return data;
  }
}

class IzvedbaSjediste {
  final int id;
  final int izvedbaId;
  final int sjedisteId;
  final bool isSlobodno;

  IzvedbaSjediste({
    required this.id,
    required this.izvedbaId,
    required this.sjedisteId,
    required this.isSlobodno,
  });

  factory IzvedbaSjediste.fromJson(Map<String, dynamic> json) {
    return IzvedbaSjediste(
      id: (json['id'] as num?)?.toInt() ?? 0,
      izvedbaId: (json['izvedbaId'] as num?)?.toInt() ?? 0,
      sjedisteId: (json['sjedisteId'] as num?)?.toInt() ?? 0,
      isSlobodno: (json['isSlobodno'] as bool?) ?? false,
    );
  }
}

class UpdateIzvedbaSjediste {
  final int sjedisteId;
  final int izvedbaId;
  final bool isSlobodno;

  UpdateIzvedbaSjediste({
    required this.sjedisteId,
    required this.izvedbaId,
    required this.isSlobodno,
  });

  Map<String, dynamic> toJson() {
    return {
      'sjedisteId': sjedisteId,
      'izvedbaId': izvedbaId,
      'isSlobodno': isSlobodno,
    };
  }
}

class UpdateSjedisteStatusRequest {
  int izvedbaId;
  int sjedisteId;
  bool isSlobodno;

  UpdateSjedisteStatusRequest({
    required this.izvedbaId,
    required this.sjedisteId,
    required this.isSlobodno,
  });

  Map<String, dynamic> toJson() => {
    "izvedbaId": izvedbaId,
    "sjedisteId": sjedisteId,
    "isSlobodno": isSlobodno,
  };
}

class MojaRezervacija {
  final int id;
  final int predstavaId;
  final String? naziv;
  final DateTime datumVrijemeIzvedbe;
  final String? plakatUrl;
  final String? nazivSale;
  final int brojKarata;
  final bool isKupljeno;
  final bool isUsedTicket;

  MojaRezervacija({
    required this.id,
    required this.predstavaId,
    this.naziv,
    required this.datumVrijemeIzvedbe,
    this.plakatUrl,
    this.nazivSale,
    required this.brojKarata,
    required this.isKupljeno,
    required this.isUsedTicket,
  });

  factory MojaRezervacija.fromJson(Map<String, dynamic> json) {
    return MojaRezervacija(
      id: (json['id'] as num?)?.toInt() ?? 0,
      predstavaId: (json['predstavaId'] as num?)?.toInt() ?? 0,
      naziv: json['naziv'] as String?,
      datumVrijemeIzvedbe: json['datumVrijemeIzvedbe'] != null
          ? DateTime.parse(json['datumVrijemeIzvedbe'] as String)
          : DateTime.now(),
      plakatUrl: json['plakatUrl'] as String?,
      nazivSale: json['nazivSale'] as String?,
      brojKarata: (json['brojKarata'] as num?)?.toInt() ?? 0,
      isKupljeno: json['isKupljeno'] as bool? ?? false,
      isUsedTicket: json['isUsedTicket'] as bool? ?? false,
    );
  }
}

class OdabranoSjediste {
  final int izvedbaId;
  final int sjedisteId;

  OdabranoSjediste({required this.izvedbaId, required this.sjedisteId});

  Map<String, dynamic> toJson() => {
    'izvedbaId': izvedbaId,
    'sjedisteId': sjedisteId,
  };
}

class RezervacijaRequest {
  final int korisnikId;
  final int izvedbaId;
  final int brojKarata;
  final bool isUsedTicket;
  final List<OdabranoSjediste> odabranaSjedista;
  final String? paymentId;

  RezervacijaRequest({
    required this.korisnikId,
    required this.izvedbaId,
    required this.brojKarata,
    required this.odabranaSjedista,
    this.isUsedTicket = false,
    this.paymentId,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "korisnikId": korisnikId,
      "izvedbaId": izvedbaId,
      "brojKarata": brojKarata,
      "isUsedTicket": isUsedTicket,
      "odabranaSjedista": odabranaSjedista.map((s) => s.toJson()).toList(),
    };

    if (paymentId != null && paymentId!.isNotEmpty) {
      data["paymentId"] = paymentId!;
    }

    return data;
  }
}

class Zanr {
  final int id;
  final String naziv;

  Zanr({required this.id, required this.naziv});

  factory Zanr.fromJson(Map<String, dynamic> json) {
    return Zanr(id: json['id'], naziv: json['naziv']);
  }
}
