using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class KomentarObavijest
{
    public int Id { get; set; }

    public int? ObavijestId { get; set; }

    public int? KorisnikId { get; set; }

    public string Text { get; set; } = null!;

    public DateTime? Datum { get; set; }

    public virtual Korisnik? Korisnik { get; set; }

    public virtual Obavijest? Obavijest { get; set; }

    public virtual ICollection<OdgovorKomentar> OdgovorKomentars { get; set; } = new List<OdgovorKomentar>();
}
