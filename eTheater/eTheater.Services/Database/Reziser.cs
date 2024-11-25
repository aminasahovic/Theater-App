using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Reziser
{
    public int Id { get; set; }

    public string Ime { get; set; } = null!;

    public string Prezime { get; set; } = null!;

    public virtual ICollection<Predstava> Predstavas { get; set; } = new List<Predstava>();
}
