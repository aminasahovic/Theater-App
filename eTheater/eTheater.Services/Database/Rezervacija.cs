using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Rezervacija
{
    public int Id { get; set; }

    public int? KorisnikId { get; set; }

    public int? IzvedbaId { get; set; }

    public int BrojKarata { get; set; }

    public bool? IsKupljeno { get; set; }

    public string? PaymentId { get; set; }

    public bool? IsUsedTicket { get; set; }

    public virtual Izvedba? Izvedba { get; set; }

    public virtual Korisnik? Korisnik { get; set; }
}
