using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class OdgovorKomentar
{
    public int Id { get; set; }

    public int? KomentariObavijestiId { get; set; }

    public int? KorisnikId { get; set; }

    public string TextOdgovora { get; set; } = null!;

    public DateTime? Datum { get; set; }

    public virtual KomentarObavijest? KomentariObavijesti { get; set; }

    public virtual Korisnik? Korisnik { get; set; }
}
