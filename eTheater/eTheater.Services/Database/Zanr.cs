using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Zanr
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public virtual ICollection<Predstava> Predstavas { get; set; } = new List<Predstava>();
}
