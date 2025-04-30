class Zanr {
  final int id;
  final String naziv;

  Zanr({required this.id, required this.naziv});

  factory Zanr.fromJson(Map<String, dynamic> json) {
    return Zanr(id: json['id'], naziv: json['naziv']);
  }
}

class Reziser {
  final int id;
  final String ime;
  final String prezime;

  Reziser({required this.id, required this.ime, required this.prezime});

  factory Reziser.fromJson(Map<String, dynamic> json) {
    return Reziser(id: json['id'], ime: json['ime'], prezime: json['prezime']);
  }
}

class Predstava {
  final int id;
  final String naziv;
  final int zanrId;
  final String opis;
  final int trajanje;
  final int godina;
  final String plakat;
  final bool isActive;
  final int reziserId;

  Predstava({
    required this.id,
    required this.naziv,
    required this.zanrId,
    required this.opis,
    required this.trajanje,
    required this.godina,
    required this.plakat,
    required this.isActive,
    required this.reziserId,
  });

  factory Predstava.fromJson(Map<String, dynamic> json) {
    return Predstava(
      id: json['id'],
      naziv: json['naziv'],
      zanrId: json['zanrId'],
      opis: json['opis'],
      trajanje: json['trajanje'],
      godina: json['godina'],
      plakat: json['plakat'],
      isActive: json['isActive'],
      reziserId: json['reziserId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

class PredstavaInsert {
  final String naziv;
  final int zanrId;
  final String opis;
  final int trajanje;
  final int godina;
  final String plakat;
  final bool isActive;
  final int reziserId;

  PredstavaInsert({
    required this.naziv,
    required this.zanrId,
    required this.opis,
    required this.trajanje,
    required this.godina,
    required this.plakat,
    required this.isActive,
    required this.reziserId,
  });

  Map<String, dynamic> toJson() => {
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

class Korisnik {
  final int id;
  final String ime;
  final String prezime;
  final String username;
  final String brojTelefona;
  final String? tipKorisnika;

  Korisnik({
    required this.id,
    required this.ime,
    required this.prezime,
    required this.username,
    required this.brojTelefona,
    this.tipKorisnika,
  });

  factory Korisnik.fromJson(Map<String, dynamic> json) {
    return Korisnik(
      id: json['id'],
      ime: json['ime'],
      prezime: json['prezime'],
      username: json['username'],
      brojTelefona: json['brojTelefona'],
      tipKorisnika: json['tipKorisnika']?['naziv'],
    );
  }
}

class TipKorisnika {
  final int id;
  final String naziv;

  TipKorisnika({required this.id, required this.naziv});

  factory TipKorisnika.fromJson(Map<String, dynamic> json) {
    return TipKorisnika(id: json['id'], naziv: json['naziv']);
  }
}

class KorisniciInsert {
  final String ime;
  final String prezime;
  final String username;
  final String password;
  final String passwordPotvrda;
  final String brojTelefona;
  final bool isActive;
  final int? tipKorisnikaId;
  final String? slika;

  KorisniciInsert({
    required this.ime,
    required this.prezime,
    required this.username,
    required this.password,
    required this.passwordPotvrda,
    required this.brojTelefona,
    required this.isActive,
    required this.tipKorisnikaId,
    this.slika,
  });

  Map<String, dynamic> toJson() => {
    'ime': ime,
    'prezime': prezime,
    'username': username,
    'password': password,
    'passwordPotvrda': passwordPotvrda,
    'brojTelefona': brojTelefona,
    'isActive': isActive,
    'tipKorisnikaId': tipKorisnikaId,
    if (slika != null) 'slika': slika,
  };
}

class Glumac {
  final int id;
  final String ime;
  final String prezime;
  final String slika;

  Glumac({
    required this.id,
    required this.ime,
    required this.prezime,
    required this.slika,
  });

  factory Glumac.fromJson(Map<String, dynamic> json) {
    return Glumac(
      id: json['id'],
      ime: json['ime'],
      prezime: json['prezime'],
      slika: json['slika'],
    );
  }
}

class GlumacPredstavaInsert {
  final int glumacId;
  final int predstavaId;
  final String uloga;

  GlumacPredstavaInsert({
    required this.glumacId,
    required this.predstavaId,
    required this.uloga,
  });

  Map<String, dynamic> toJson() => {
    'glumacId': glumacId,
    'predstavaId': predstavaId,
    'uloga': uloga,
  };
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
      glumacId: json['glumacId'],
      ime: json['ime'],
      prezime: json['prezime'],
      uloga: json['uloga'],
      slika: json['slika'],
    );
  }
}

class InsertGlumac {
  final String ime;
  final String prezime;
  final String slika;

  InsertGlumac({required this.ime, required this.prezime, required this.slika});

  Map<String, dynamic> toJson() {
    return {'ime': ime, 'prezime': prezime, 'slika': slika};
  }

  factory InsertGlumac.fromJson(Map<String, dynamic> json) {
    return InsertGlumac(
      ime: json['ime'],
      prezime: json['prezime'],
      slika: json['slika'],
    );
  }
}

class InsertReziser {
  final String ime;
  final String prezime;

  InsertReziser({required this.ime, required this.prezime});

  Map<String, dynamic> toJson() => {'ime': ime, 'prezime': prezime};
}

class Obavijest {
  final int id;
  final int korisnikId;
  final String naslov;
  final String sadrzaj;
  final DateTime datumObjave;
  final String? slika;

  Obavijest({
    required this.id,
    required this.korisnikId,
    required this.naslov,
    required this.sadrzaj,
    required this.datumObjave,
    this.slika,
  });

  factory Obavijest.fromJson(Map<String, dynamic> json) {
    return Obavijest(
      id: json['id'],
      korisnikId: json['korisnikId'],
      naslov: json['naslov'],
      sadrzaj: json['sadrzaj'],
      datumObjave: DateTime.parse(json['datumObjave']),
      slika: json['slika'],
    );
  }
}

class InsertNovosti {
  int korisnikId;
  String naslov;
  String sadrzaj;
  DateTime datumObjave;
  String slika;

  InsertNovosti({
    required this.korisnikId,
    required this.naslov,
    required this.sadrzaj,
    required this.datumObjave,
    required this.slika,
  });

  Map<String, dynamic> toJson() {
    return {
      'korisnikId': korisnikId,
      'naslov': naslov,
      'sadrzaj': sadrzaj,
      'datumObjave': datumObjave.toIso8601String(),
      'slika': slika ?? "",
    };
  }
}

class UpdateNovosti {
  int korisnikId;
  String naslov;
  String sadrzaj;
  DateTime datumObjave;
  String slika;
  DateTime datumUredjivanja;
  int modifyBy;

  UpdateNovosti({
    required this.korisnikId,
    required this.naslov,
    required this.sadrzaj,
    required this.datumObjave,
    required this.slika,
    required this.datumUredjivanja,
    required this.modifyBy,
  });

  Map<String, dynamic> toJson() => {
    "korisnikId": korisnikId,
    "naslov": naslov,
    "sadrzaj": sadrzaj,
    "datumObjave": datumObjave.toIso8601String(),
    "slika": slika,
    "datumUredjivanja": datumUredjivanja.toIso8601String(),
    "modifyBy": modifyBy,
  };
}

class Izvedba {
  final int id;
  final String nazivPredstave;
  final String predstavaSlika;
  final String salaNaziv;
  final double cijenaKarte;
  final DateTime datumVrijeme;
  final int salaId;
  final int predstavaId;

  Izvedba({
    required this.id,
    required this.nazivPredstave,
    required this.predstavaSlika,
    required this.salaNaziv,
    required this.cijenaKarte,
    required this.datumVrijeme,
    required this.salaId,
    required this.predstavaId,
  });

  factory Izvedba.fromJson(Map<String, dynamic> json) {
    return Izvedba(
      id: json['id'],
      nazivPredstave: json['nazivPredstave'],
      predstavaSlika: json['predstavaSlika'],
      salaNaziv: json['salaNaziv'],
      cijenaKarte: (json['cijenaKarte'] as num).toDouble(),
      datumVrijeme: DateTime.parse(json['datumVrijeme']),
      predstavaId: json['predstavaId'],
      salaId: json['salaId'],
    );
  }
}

class Sala {
  final int id;
  final String naziv;

  Sala({required this.id, required this.naziv});

  factory Sala.fromJson(Map<String, dynamic> json) {
    return Sala(id: json['id'], naziv: json['naziv']);
  }
}

class PagedResult<T> {
  final List<T> resultList;
  final int count;

  PagedResult({required this.resultList, required this.count});

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResult(
      resultList:
          (json['resultList'] as List<dynamic>)
              .map((item) => fromJsonT(item))
              .toList(),
      count: json['count'],
    );
  }
}

class IzvedbaInsert {
  final int predstavaId;
  final int salaId;
  final String datumVrijeme;
  final double cijenaKarte;

  IzvedbaInsert({
    required this.predstavaId,
    required this.salaId,
    required this.datumVrijeme,
    required this.cijenaKarte,
  });

  Map<String, dynamic> toJson() => {
    'predstavaId': predstavaId,
    'salaId': salaId,
    'cijenaKarte': cijenaKarte,
    'datumVrijeme': datumVrijeme,
  };
}

class PredstavaLov {
  final int id;
  final String naziv;

  PredstavaLov({required this.id, required this.naziv});

  factory PredstavaLov.fromJson(Map<String, dynamic> json) {
    return PredstavaLov(id: json['id'], naziv: json['naziv']);
  }
}

class IzvedbaUpdateRequest {
  int predstavaId;
  int salaId;
  DateTime datumVrijeme;
  double cijenaKarte;

  IzvedbaUpdateRequest({
    required this.predstavaId,
    required this.salaId,
    required this.datumVrijeme,
    required this.cijenaKarte,
  });

  Map<String, dynamic> toJson() {
    return {
      'predstavaId': predstavaId,
      'salaId': salaId,
      'datumVrijeme': datumVrijeme.toIso8601String(),
      'cijenaKarte': cijenaKarte,
    };
  }

  factory IzvedbaUpdateRequest.fromJson(Map<String, dynamic> json) {
    return IzvedbaUpdateRequest(
      predstavaId: json['predstavaId'],
      salaId: json['salaId'],
      datumVrijeme: DateTime.parse(json['datumVrijeme']),
      cijenaKarte: json['cijenaKarte'].toDouble(),
    );
  }
}
