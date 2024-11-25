using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class TipKorisnik
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public virtual ICollection<Korisnik> Korisniks { get; set; } = new List<Korisnik>();
}
