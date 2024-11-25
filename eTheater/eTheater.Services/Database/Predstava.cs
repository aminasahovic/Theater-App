using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Predstava
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public int? ZanrId { get; set; }

    public string? Opis { get; set; }

    public int? Trajanje { get; set; }

    public int? Godina { get; set; }

    public string? Plakat { get; set; }

    public bool? IsActive { get; set; }

    public int? ReziserId { get; set; }

    public virtual ICollection<GlumacPredstava> GlumacPredstavas { get; set; } = new List<GlumacPredstava>();

    public virtual ICollection<Izvedba> Izvedbas { get; set; } = new List<Izvedba>();

    public virtual ICollection<KomentarPrestava> KomentarPrestavas { get; set; } = new List<KomentarPrestava>();

    public virtual Reziser? Reziser { get; set; }

    public virtual Zanr? Zanr { get; set; }
}
