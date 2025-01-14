using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class KomentarPrestava
{
    public int Id { get; set; }

    public int? KorisnikId { get; set; }

    public int? PredstavaId { get; set; }

    public int Ocjena { get; set; }

    public DateTime? Datum { get; set; }

    public string? Komentar { get; set; }

    public virtual Korisnik? Korisnik { get; set; }

    public virtual Predstava? Predstava { get; set; }
}
