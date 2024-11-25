using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Glumac
{
    public int Id { get; set; }

    public string Ime { get; set; } = null!;

    public string Prezime { get; set; } = null!;

    public string? Slika { get; set; }

    public virtual ICollection<GlumacPredstava> GlumacPredstavas { get; set; } = new List<GlumacPredstava>();
}
