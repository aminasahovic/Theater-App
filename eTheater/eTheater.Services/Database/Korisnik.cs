using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Korisnik
{
    public int Id { get; set; }

    public string Ime { get; set; } = null!;

    public string Prezime { get; set; } = null!;

    public string Username { get; set; } = null!;

    public string Password { get; set; } = null!;

    public string? Salt { get; set; }

    public bool? IsActive { get; set; }

    public string? BrojTelefona { get; set; }

    public int? TipKorisnikaId { get; set; }

    public virtual ICollection<KomentarObavijest> KomentarObavijests { get; set; } = new List<KomentarObavijest>();

    public virtual ICollection<KomentarPrestava> KomentarPrestavas { get; set; } = new List<KomentarPrestava>();

    public virtual ICollection<Obavijest> Obavijests { get; set; } = new List<Obavijest>();

    public virtual ICollection<OdgovorKomentar> OdgovorKomentars { get; set; } = new List<OdgovorKomentar>();

    public virtual ICollection<Rezervacija> Rezervacijas { get; set; } = new List<Rezervacija>();

    public virtual TipKorisnik? TipKorisnika { get; set; }
}
