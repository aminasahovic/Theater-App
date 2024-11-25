using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Obavijest
{
    public int Id { get; set; }

    public int? KorisnikId { get; set; }

    public string Naslov { get; set; } = null!;

    public string Sadrzaj { get; set; } = null!;

    public DateTime? DatumObjave { get; set; }

    public string? Slika { get; set; }

    public DateTime? DatumUredjivanja { get; set; }

    public int? ModifyBy { get; set; }

    public virtual ICollection<KomentarObavijest> KomentarObavijests { get; set; } = new List<KomentarObavijest>();

    public virtual Korisnik? Korisnik { get; set; }
}
