using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Izvedba
{
    public int Id { get; set; }

    public int? PredstavaId { get; set; }

    public int? SalaId { get; set; }

    public DateTime DatumVrijeme { get; set; }

    public decimal CijenaKarte { get; set; }

    public virtual ICollection<IzvedbaSjediste> IzvedbaSjedistes { get; set; } = new List<IzvedbaSjediste>();

    public virtual Predstava? Predstava { get; set; }

    public virtual ICollection<RepertoarIzvedba> RepertoarIzvedbas { get; set; } = new List<RepertoarIzvedba>();

    public virtual ICollection<Rezervacija> Rezervacijas { get; set; } = new List<Rezervacija>();

    public virtual Sala? Sala { get; set; }
}
