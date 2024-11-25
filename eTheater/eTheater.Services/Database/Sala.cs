using System;
using System.Collections.Generic;

namespace eTheater.Services.Database;

public partial class Sala
{
    public int Id { get; set; }

    public string Naziv { get; set; } = null!;

    public virtual ICollection<Izvedba> Izvedbas { get; set; } = new List<Izvedba>();

    public virtual ICollection<Sjediste> Sjedistes { get; set; } = new List<Sjediste>();
}
