// models.dart

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
  final String plakat; // base64
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
